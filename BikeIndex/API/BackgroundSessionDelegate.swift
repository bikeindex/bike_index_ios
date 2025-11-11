//
//  BackgroundSessionDelegate.swift
//  BikeIndex
//
//  Created by Milo Wyner on 11/11/25.
//

import Foundation
import OSLog
import SwiftData

enum BackgroundSessionError: Error {
    case noData
}

/// Used by ``Client`` to handle background uploads.
final class BackgroundSessionDelegate: NSObject {
    @MainActor var appDelegateCompletionHandler: (() -> Void)?
    @MainActor private var data: Data?
    private let container = try? ModelContainer(for: Bike.self)

    @MainActor
    private func imageUploadCompletion(_ result: Result<Data, Error>, bikeIdentifier: Int? = nil) {
        do {
            switch result {
            case .success(let data):
                let imageResponseContainer = try JSONDecoder().decode(ImageResponseContainer.self, from: data)
                let image = imageResponseContainer.image
                guard let bikeIdentifier else {
                    Logger.api.error("\(#function) Bike identifier is nil. Can't save bike image to context")
                    return
                }
                Logger.api.debug("\(#function) Image upload successful for bike with ID: \(bikeIdentifier)")

                // Get bike model from data
                guard let context = container?.mainContext else {
                    Logger.api.error("\(#function) Bike model container is nil. Can't save bike image to context")
                    return
                }
                guard let bikeModel = try context.fetch(FetchDescriptor<Bike>(predicate: #Predicate { $0.identifier == bikeIdentifier })).first else {
                    Logger.api.error("\(#function) Failed to fetch bike with ID \(bikeIdentifier) from context")
                    return
                }

                // Save to context
                bikeModel.largeImage = image.large
                bikeModel.thumb = image.thumb
                context.insert(bikeModel)
                try context.save()
                Logger.api.debug("\(#function) Saved uploaded image to bike model context")
            case .failure(let failure):
                Logger.api.error(
                    "\(#function) Failed to save uploaded image after bike registration: \(failure)"
                )
            }
        } catch {
            Logger.api.error("\(#function) Error: \(error)")
        }
    }
}

extension BackgroundSessionDelegate: URLSessionDelegate {
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: (any Error)?) {
        Logger.api.error("\(#function) Error: \(error)")
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async { [self] in
            guard let appDelegateCompletionHandler else {
                Logger.api.error("\(#function) appDelegateCompletionHandler is nil")
                return
            }
            Logger.api.debug("\(#function) appDelegateCompletionHandler called")
            appDelegateCompletionHandler()
        }
    }
}

extension BackgroundSessionDelegate: URLSessionTaskDelegate {
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: (any Error)?) {
        Task { @MainActor in
            if let error {
                Logger.api.error("\(#function) Error: \(error)")
                imageUploadCompletion(.failure(error))
                return
            }
            guard let data else {
                Logger.api.error("\(#function) data is nil")
                imageUploadCompletion(.failure(BackgroundSessionError.noData))
                return
            }
            do {
                try (task.response as? HTTPURLResponse)?.validate(with: data)
            } catch {
                Logger.api.error("\(#function) Task response is invalid: \(task.response)")
                imageUploadCompletion(.failure(error))
                return
            }
            // TODO: Find a more reliable way to do this (in case the API path format changes)
            // Get bike ID from request path
            let idString = task.originalRequest?.url?.pathComponents[4]
            guard let idString, let id = Int(idString) else {
                Logger.api.error("\(#function) Failed to get bike ID from request path")
                imageUploadCompletion(.failure(BackgroundSessionError.noData))
                return
            }
            imageUploadCompletion(.success(data), bikeIdentifier: id)
        }
    }

}

extension BackgroundSessionDelegate: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        Task { @MainActor in
            Logger.api.debug("\(#function) data: \(data)")
            self.data = data
        }
    }

}
