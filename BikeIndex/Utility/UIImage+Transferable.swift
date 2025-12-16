//
//  UIImage+Transferable.swift
//  BikeIndex
//
//  Created by Milo Wyner on 10/9/25.
//

import SwiftUI
import UIKit

enum TransferError: Error {
    case importFailed
}

extension UIImage: @retroactive Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            guard let uiImage = UIImage(data: data) else {
                throw TransferError.importFailed
            }
            return uiImage
        }
    }
}
