//
//  ContentView.swift
//  WordScramble
//
//  Created by Hari's Mac on 21.02.2025.
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
                            Image(systemName: "\(word.count).circle.fill")
                            Text(word)
                        }
                        
                    }
                }
                Section{
                    Text("score : \(score)")
                }
            }
            .navigationTitle(rootWord)
            .onSubmit(addNewWord)
            // When the ContentView has appeared -> start the game!
            .onAppear(perform: startGame)
            .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Reset") {
                startGame()
                }
            }
        }
            .alert(errorTitle, isPresented: $showingError) {
                
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
            
        }
        
        
        
    }
    
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        guard answer.count > 0 else { return }
        
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        // extra validation to come
        // Ye to comment me h ye h normal aur niche h with default animation
        //        usedWords.insert(answer, at: 0)
        withAnimation {
            usedWords.insert(answer, at: 0)
            score = score + 10
        }
        // newword ko reset krna h after har baar ek word push krne k baad
        newWord = ""
    }
    
    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL, encoding: .utf8) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")

                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"

                // If we are here everything has worked, so we can exit
                return
            }
        }

        // If were are *here* then there was a problem – trigger a crash and report the error
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
}

#Preview {
    ContentView()
}
