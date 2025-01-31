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

struct Model: Codable {
    let type: String
    let vocab: [String: Int]
}

struct TokenizerConfig: Codable {
    let version: String
    let truncation: String?
    let padding: String?
    let addedTokens: [AddedToken]
    let model: Model

    enum CodingKeys: String, CodingKey {
        case version, truncation, padding, addedTokens = "added_tokens", model
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
    print("Chemin du fichier tokenizer.json : \(tokenToIdURL.path)")

    do {
        let data = try Data(contentsOf: tokenToIdURL)
        let tokenizerConfig = try JSONDecoder().decode(TokenizerConfig.self, from: data)
        var tokenToId = [String: Int]()
        for token in tokenizerConfig.addedTokens {
            tokenToId[token.content] = token.id
        }
        tokenToId.merge(tokenizerConfig.model.vocab) { (current, _) in current }
        return Tokenizer(tokenToId: tokenToId)
    } catch let generalError {
        print("Error reading or decoding JSON: \(generalError.localizedDescription)")
        throw generalError
    }
}
