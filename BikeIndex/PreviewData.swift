//
//  PreviewData.swift
//  BikeIndex
//
//  Created by Jack on 1/13/24.
//

import Foundation

final class PreviewData {
    static func load<Model: Decodable>(filename: String) throws -> Model? {
        guard let path = Bundle.main.path(forResource: filename, ofType: "json") else {
            return nil
        }

        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let instance = try JSONDecoder().decode(Model.self, from: data)
        return instance
    }
}
