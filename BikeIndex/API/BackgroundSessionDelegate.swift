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
    func imageUploadCompletion(_ result: Result<Data, Error>, bikeIdentifier: Int? = nil) {
        do {
            switch result {
            case .success(let data):
                let imageResponseContainer = try JSONDecoder().decode(ImageResponseContainer.self, from: data)
                let image = imageResponseContainer.image
                Logger.model.debug("\(#function) Image upload successful")
                guard let bikeIdentifier else {
                    Logger.model.error("\(#function) Bike identifier is nil. Can't save bike image to context")
                    return
                }
                Logger.model.debug("\(#function) Bike identifier is \(bikeIdentifier)")

                // Get bike model from data
                guard let context = container?.mainContext else {
                    Logger.model.error("\(#function) Bike model container is nil. Can't save bike image to context")
                    return
                }
                guard let bikeModel = try context.fetch(FetchDescriptor<Bike>(predicate: #Predicate { $0.identifier == bikeIdentifier })).first else {
                    Logger.model.error("\(#function) Failed to fetch bike with ID \(bikeIdentifier) from context")
                    return
                }

                // Save to context
                Logger.model.debug("\(#function) Saving uploaded image to bike model context")
                bikeModel.largeImage = image.large
                bikeModel.thumb = image.thumb
                context.insert(bikeModel)
                try context.save()
            case .failure(let failure):
                Logger.model.error(
                    "\(#function) Failed to upload image after bike registration: \(failure)"
                )
            }
        } catch {
            Logger.model.error("\(#function) Error: \(error)")
        }
    }
}

extension BackgroundSessionDelegate: URLSessionDelegate {
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: (any Error)?) {
        // TODO: Handle
        Logger.api.debug("\(#function) error.debugDescription")
    }

    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async { [self] in
            Logger.api.debug("\(#function) session \(session), thread: \(Thread.current), isMain: \(Thread.isMainThread)")
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
                Logger.api.error("\(#function) error: \(error), thread: \(Thread.current), isMain: \(Thread.isMainThread)")
                imageUploadCompletion(.failure(error))
                return
            }
            guard let data else {
                Logger.api.error("\(#function) data is nil, thread: \(Thread.current), isMain: \(Thread.isMainThread)")
                imageUploadCompletion(.failure(BackgroundSessionError.noData))
                return
            }
            do {
                try (task.response as? HTTPURLResponse)?.validate(with: data)
            } catch {
                Logger.api.debug("\(#function) response is invalid: \(task.response), thread: \(Thread.current), isMain: \(Thread.isMainThread)")
                imageUploadCompletion(.failure(error))
                return
            }
            Logger.api.debug("\(#function) posted data \(data), thread: \(Thread.current), isMain: \(Thread.isMainThread)")
            Logger.api.debug("\(#function) task.originalRequest?.url: \(task.originalRequest?.url ?? "")")
            let idString = task.originalRequest?.url?.pathComponents[4]
            Logger.api.debug("\(#function) ID: \(idString ?? "nil")")
            Logger.api.debug("\(#function) calling completion handler")
            guard let idString, let id = Int(idString) else {
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
