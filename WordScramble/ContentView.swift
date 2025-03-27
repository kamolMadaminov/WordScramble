//
//  ContentView.swift
//  WordScramble
//
//  Created by Kamol Madaminov on 27/03/25.
//

import SwiftUI

struct ContentView: View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    
    @State private var score = 0
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)
                }
                Section("Score") {
                    Text("Your score is: \(score)")
                }
                Section("Words used") {
                    ForEach(usedWords, id: \.self) { word in
                        HStack{
                            Image(systemName: "\(word.count).circle")
                            Text (word)
                        }
                    }
                }
            }
            .navigationTitle (rootWord)
            .onSubmit (addNewWord)
            .onAppear(perform: startGame)
            .alert(errorTitle, isPresented: $showError) { } message: {
                Text(errorMessage)
            }
            .toolbar{
                Button("Restart"){
                    startGame()
                }
            }
        }
    }
    
    func addNewWord(){
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespaces)
        guard !answer.isEmpty else { return }
        guard isOriginal(word: answer) else {
            showingError(title: "Word used already", message: "Be more original!")
            return
        }
        guard isPossible(word: answer) else {
            showingError(title: "Not a valid word", message: "Words must be in the current word list.")
            return
        }
        guard isReal(word: answer) else {
            showingError(title: "Not a real word", message: "Words must be the real world.")
            return
        }
        guard isMoreThanThreeLetters(word: answer) else {
            showingError(title: "Too short!", message: "Words must be longer than three letters.")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)
            score += 1
        }
        newWord = ""
    }
    
    func startGame(){
        usedWords.removeAll()
        score = 0
        if let startWordURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            if let startWord = try? String(contentsOf: startWordURL) {
                let allWords = startWord.components(separatedBy: .newlines)
                rootWord = allWords.randomElement( ) ?? "Word"
                return
            }
        }
        
        fatalError("Couldn't load start.txt file with words")
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word) && word != rootWord
    }
    
    func isPossible(word: String) -> Bool {
        var tempword = rootWord
        
        for letter in word {
            if let pos = tempword.firstIndex(of: letter){
                tempword.remove(at: pos)
            } else {
                return false
            }
        }
        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let mispelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "eng")
        
        return mispelledRange.location == NSNotFound
    }
    
    func isMoreThanThreeLetters(word: String) -> Bool {
        word.count >= 3
    }
    
    func showingError(title: String, message: String){
        errorTitle = title
        errorMessage = message
        showError = true
    }
}

#Preview {
    ContentView()
}
