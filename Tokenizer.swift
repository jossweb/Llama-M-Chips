//
//  Tokenizer.swift
//  llama-mchip
//
//  Created by Jossua Figueiras on 26/01/2025.
//
import Foundation

struct AddedToken: Codable {
    let id: Int
    let content: String
    let singleWord: Bool
    let lstrip: Bool
    let rstrip: Bool
    let normalized: Bool
    let special: Bool

    enum CodingKeys: String, CodingKey {
        case id, content, lstrip, normalized, rstrip, singleWord = "single_word", special
    }
}

struct TokenizerConfig: Codable {
    let version: String
    let truncation: String?
    let padding: String?
    let addedTokens: [AddedToken]

    enum CodingKeys: String, CodingKey {
        case version, truncation, padding, addedTokens = "added_tokens"
    }
}

struct Tokenizer {
    let tokenToId: [String: Int]
    let idToToken: [Int: String]

    init(tokenToId: [String: Int]) {
        self.tokenToId = tokenToId
        self.idToToken = Dictionary(uniqueKeysWithValues: tokenToId.map { ($1, $0) })
    }

    func decode(_ tokenIds: [Int]) -> String {
        return tokenIds.compactMap { idToToken[$0] }.joined(separator: " ")
    }
}

func loadTokenizer() throws -> Tokenizer {
    print("Get Tokenizer")
    guard let tokenToIdURL = Bundle.main.url(forResource: "tokenizer", withExtension: "json") else {
        print("Chemin du fichier tokenizer.json non trouvé")
        throw NSError(domain: "Tokenizer", code: 1, userInfo: [NSLocalizedDescriptionKey: "Fichier tokenizer.json non trouvé"])
    }
    
    // Afficher le chemin complet dans la console
    print("Chemin du fichier tokenizer.json : \(tokenToIdURL.path)")

    do {
        // Lire les données du fichier
        let data = try Data(contentsOf: tokenToIdURL)
        // Afficher la taille des données pour vérifier qu'elles ne sont pas vides
        print("Taille des données lues : \(data.count) octets")
        
        // Afficher les données sous forme de chaîne pour débogage
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Contenu du fichier JSON : \(jsonString.prefix(1000))...") // Afficher les 1000 premiers caractères
        }
        
        // Décoder les données JSON
        let tokenizerConfig = try JSONDecoder().decode(TokenizerConfig.self, from: data)
        
        // Créez un dictionnaire de tokenToId à partir des tokens ajoutés
        var tokenToId = [String: Int]()
        for token in tokenizerConfig.addedTokens {
            tokenToId[token.content] = token.id
        }

        return Tokenizer(tokenToId: tokenToId)
    } catch let DecodingError.dataCorrupted(context) {
        print("Data corrupted: \(context.debugDescription)")
        throw context.underlyingError ?? NSError(domain: "Tokenizer", code: 2, userInfo: [NSLocalizedDescriptionKey: "Data corrupted"])
    } catch let DecodingError.keyNotFound(key, context) {
        print("Key '\(key)' not found: \(context.debugDescription)")
        throw context.underlyingError ?? NSError(domain: "Tokenizer", code: 3, userInfo: [NSLocalizedDescriptionKey: "Key not found"])
    } catch let DecodingError.typeMismatch(type, context) {
        print("Type '\(type)' mismatch: \(context.debugDescription)")
        throw context.underlyingError ?? NSError(domain: "Tokenizer", code: 4, userInfo: [NSLocalizedDescriptionKey: "Type mismatch"])
    } catch let DecodingError.valueNotFound(value, context) {
        print("Value '\(value)' not found: \(context.debugDescription)")
        throw context.underlyingError ?? NSError(domain: "Tokenizer", code: 5, userInfo: [NSLocalizedDescriptionKey: "Value not found"])
    } catch let generalError {
        print("Error reading or decoding JSON: \(generalError.localizedDescription)")
        throw generalError
    }
}
