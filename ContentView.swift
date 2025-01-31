//
//  ContentView.swift
//  llama-mchip
//
//  Created by Jossua Figueiras on 26/01/2025.
//
import SwiftUI
import CoreML

struct ContentView: View {
    @State private var generatedText: String = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if !generatedText.isEmpty {
                Text("Texte généré :")
                Text(generatedText)
                    .padding()
            } else if let error = errorMessage {
                Text("Erreur : \(error)")
            } else {
                Text("Aucun texte généré")
            }
            
            Button(action: generateText) {
                Text("Générer du texte")
            }
            .padding()
        }
    }

    
    func generateText() {
        var tokenizer: Tokenizer?
        do{
            tokenizer = try loadTokenizer()
            print("Tokenizer load successfully");
        }catch{
            print("Error : Failed to load Tokenizer : \(error.localizedDescription)")
        }
        if let tokenizer = tokenizer {
            let text = "<|begin_of_text|> Hello world <|end_of_text|>"
            let encodedTokens = textToTokens(text: text, using: tokenizer)
            print("Texte encodé en tokens: \(encodedTokens)")
            let decodedText = tokenToText(tokenids: encodedTokens, using: tokenizer)
                    print("Tokens décodés en texte: \(decodedText)")
                }
    }
    func textToTokens(text: String, using tokenizer: Tokenizer) -> [Int]{
        let tokens = text.split(separator: " ")
        var tokenIds=[Int]()
        for token in tokens{
            if let id=tokenizer.tokenToId[String(token)]{
                tokenIds.append(id)
            }else{
                print("Error token \(token) not found")
            }
        }
        return tokenIds;
    }
    func tokenToText(tokenids: [Int], using tokenizer: Tokenizer)-> String{
        return tokenizer.decode(tokenids);
    }
}
#Preview {
    ContentView()
}
