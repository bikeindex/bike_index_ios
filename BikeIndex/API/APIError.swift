//
//  APIError.swift
//  BikeIndex
//
//  Created by Jack on 3/22/25.
//

import Foundation

struct APIErrorMessage: Decodable {
    var error: String
}

enum APIError: Error, LocalizedError {
    case cacheHit
    case clientError(code: Int, data: Data?)
    case postMissingContents(endpoint: APIEndpoint)
    case failedToDecodedExpectedModelType(URLResponse)

    var errorDescription: String? {
        switch self {
        case .cacheHit:
            "Cache Hit"
        case .clientError(let code, let data):
            // Decode JSON of format: `{ "error": "" }`
            if let data, let message = try? JSONDecoder().decode(APIErrorMessage.self, from: data) {
                "\(code) \(message.error)"
            } else {
                "\(code) - Failed to decode error message."
            }
        case .postMissingContents(let endpoint):
            "Could not POST, missing contents for \(endpoint)"
        case .failedToDecodedExpectedModelType(let response):
            "Failed to decode expected model type from response: \(response)"
        }
    }

    var error: Error {
        self
    }
}
