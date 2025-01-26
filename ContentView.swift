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
        do {
            // Charger le tokenizer
            let tokenizer = try loadTokenizer()

            // Afficher la configuration du tokenizer pour débogage
            print("Tokenizer loaded successfully: \(tokenizer.tokenToId)")

            // Créez une instance du modèle
            let model = try Llama_3_2_3B_Instruct(configuration: .init())
            
            // Préparez les données d'entrée
            let inputIds = try MLMultiArray(shape: [1, 1], dataType: .int32)
            inputIds[0] = 1  // ID de démarrage pour la génération de texte

            let causalMask = try MLMultiArray(shape: [1, 1, 1, 1], dataType: .float16)
            causalMask[0] = 1.0  // Masque causal pour la génération de texte

            // Créez l'état nécessaire pour la génération de texte
            let modelState = model.makeState()
            
            // Créez l'entrée du modèle
            let input = Llama_3_2_3B_InstructInput(inputIds: inputIds, causalMask: causalMask)

            // Faites la prédiction pour générer du texte
            let prediction = try model.prediction(input: input, using: modelState)
            
            // Utilisez les résultats de la prédiction
            if let logits = prediction.logits as? MLMultiArray {
                // Convertir les logits en texte généré
                generatedText = convertLogitsToText(logits, tokenizer: tokenizer)
            }
        } catch {
            errorMessage = "Erreur lors de la génération de texte : \(error.localizedDescription)"
        }
    }

    func convertLogitsToText(_ logits: MLMultiArray, tokenizer: Tokenizer) -> String {
        // Exemple de décodage greedy
        var tokenIds: [Int] = []
        
        // Suppose que les logits sont de dimensions [1, 1, vocab_size]
        for i in 0..<logits.count {
            // Trouver l'index du token avec la probabilité la plus élevée
            let maxIndex = logits[i].doubleValue
            tokenIds.append(Int(maxIndex))
        }
        
        // Convertir les tokens en texte
        return tokenizer.decode(tokenIds)
    }
}
#Preview {
    ContentView()
}
