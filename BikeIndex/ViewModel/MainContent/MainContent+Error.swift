//
//  MainContent+Error.swift
//  BikeIndex
//
//  Created by Jack on 12/26/24.
//

import Foundation

extension MainContentPage.ViewModel {
    /// Some errors in ViewModel are app-specific, others come from SwiftData.
    /// Represent both kinds of errors in this concrete type for SwiftUI.alert to utilize.
    public enum Error: LocalizedError {
        case failed(message: String)
        case swiftError(Swift.Error)

        var errorDescription: String? {
            switch self {
            case .swiftError(let error):
                return error.localizedDescription
            case .failed(let message):
                return message
            }
        }

        var failureReason: String? {
            switch self {
            case .swiftError(let error):
                return (error as NSError).localizedFailureReason
            case .failed(_):
                return nil
            }
        }

        var recoverySuggestion: String? {
            switch self {
            case .swiftError(let error):
                return (error as NSError).localizedRecoverySuggestion
            case .failed(_):
                return nil
            }
        }

        var helpAnchor: String? {
            switch self {
            case .swiftError(let error):
                return (error as NSError).helpAnchor
            case .failed(_):
                return nil
            }
        }
    }
}
