//
//  ContentView.swift
//  WordScramble
//
//  Created by Toni Mijatovic on 24/05/2023.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0
    
    var body: some View {
    
        NavigationView {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .autocapitalization(.none)
                }
                
                Section {
                    ForEach(usedWords, id: \.self) { word in
                        HStack {
                            Image(systemName: "\(word.count).circle")
                            Text(word)
                        }
                    }
                }
                Section {
                    Text("Score: \(score)")
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            .toolbar {
                ToolbarItem() {
                       Button("Reset game") {
                           startGame()
                       }
                   }
               }
        }
    }
    
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard shorterThanThree(word: answer) else {
            wordError(title: "Word is too short", message: "You need to enter more than 3 characters for your word")
            return
        }
        
        guard isStartWord(word: answer) else {
            wordError(title: "Word is our start word", message: "You need to enter a different word, you used our startword.")
            return
        }
        
        guard isOriginal(word: answer) else{
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else{
            wordError(title: "Word not possible", message: "You cant spell that word from '\(rootWord)'")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
        }
        score = score + (usedWords.count * answer.count)
        newWord = ""
    }
    
    func startGame() {
            if let startWordsURL = Bundle.main.url(forResource: "start",        withExtension: "txt"){
                if let startWords = try? String(contentsOf: startWordsURL) {
                let allWords = startWords.components(separatedBy: "\n")
                    rootWord = allWords.randomElement() ?? "silkworm"
                    return
            }
        }
        fatalError("Could not load start.txt from bundle.")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }
        
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        
        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    
    func shorterThanThree(word: String) -> Bool {
        print(word.count)
        return word.count > 3
    }
    
    func isStartWord(word: String) -> Bool {
        return word != rootWord
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

