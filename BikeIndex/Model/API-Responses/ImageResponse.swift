//
//  ImageResponse.swift
//  BikeIndex
//
//  Created by Milo Wyner on 10/8/25.
//

import Foundation

struct ImageResponseContainer: Decodable {
    let image: ImageResponse
}

struct ImageResponse: Decodable {
    let id: Int?
    let name: String?
    let full: URL?
    let large: URL?
    let medium: URL?
    let thumb: URL?
}
