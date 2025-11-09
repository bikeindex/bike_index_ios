//
//  API.swift
//  BikeIndex
//
//  Created by Jack on 11/19/23.
//

import Foundation
import OSLog
import URLEncodedForm
import UIKit

/// URL's appending(components: String...) variadic function cannot accept arrays (splatting) so use reduce instead
extension URL {
    func appending(components: [String]) -> Self {
        return components.reduce(self) { partialResult, path in
            partialResult.appending(path: path)
        }
    }
}

/// API  usage of URL component Bike.{id} is string-backed
public typealias BikeId = String

/// Internal type to signify that POSTs use an Encodable type
typealias Postable = Encodable & Sendable
typealias ResponseDecodable = Decodable & Sendable

protocol APIEndpoint: Sendable {
    /// Array of path components to-be concatenated to the URL
    var path: [String] { get }

    var method: HttpMethod { get }

    /// Does this endpoint require authorization? True for yes, false for no / public
    var authorized: Bool { get }

    var requestModel: Encodable? { get }
    var responseModel: any ResponseDecodable.Type { get }

    var formType: FormType? { get }

    func request(for config: HostProvider) -> URLRequest
}

extension APIEndpoint {
    var formType: FormType? { nil }
}

/// API client to perform networking operations with only essential state.
extension Client {
    func get(_ endpoint: APIEndpoint) async -> Result<(any ResponseDecodable), Error> {
//        if let appDelegate = UIApplication.shared.delegate {
//            print("UIApplicationDelegate exists")
//            if let customDelegate = appDelegate as? AppDelegate {
//                print("UIApplicationDelegate is AppDelegate")
//            }
//        } else {
//            print("UIApplicationDelegate doesn't exist")
//        }
        var request = endpoint.request(for: configuration.hostProvider)
        if endpoint.authorized, let accessToken {
            request.url?.append(queryItems: [URLQueryItem(name: "access_token", value: accessToken)]
            )
        }

        do {
            let (data, response) = try await session.data(for: request)
            try (response as? HTTPURLResponse)?.validate(with: data)

            Logger.api.debug(
                "\(type(of: self)).\(#function) fetched \(String(reflecting: request.url?.absoluteString ?? "nil url"))"
            )
            Logger.api.debug(
                "\(type(of: self)).\(#function) fetched response \(String(reflecting: response))")
            Logger.api.debug(
                "\(type(of: self)).\(#function) fetched data \(String(data: data, encoding: .utf8) ?? "<failed to stringify data>")"
            )

            return Result {
                try JSONDecoder().decode(endpoint.responseModel, from: data)
            }
        } catch {
            Logger.api.error(
                "\(#function) failed to fetch \(String(describing: request.url)) with error \(error)"
            )
            return .failure(error)
        }
    }

    func post<T: Decodable>(_ endpoint: APIEndpoint) async -> Result<T, Error> {
        var request = endpoint.request(for: configuration.hostProvider)
        if endpoint.authorized, let accessToken {
            request.url?.append(queryItems: [URLQueryItem(name: "access_token", value: accessToken)]
            )
        }

        // Prepare HTTP body contents
        do {
            guard let requestModel = endpoint.requestModel else {
                Logger.api.error(
                    "\(#function) Failed to find model for POST body encoding for endpoint \(String(reflecting: endpoint))"
                )
                return .failure(APIError.postMissingContents(endpoint: endpoint).error)
            }
            guard let formType = endpoint.formType else {
                Logger.api.error(
                    "\(#function) Failed to find form type for POST endpoint \(String(reflecting: endpoint))"
                )
                return .failure(APIError.postMissingContents(endpoint: endpoint).error)
            }

            switch formType {
            case .formURLEncoded:
                request.httpBody = try URLEncodedFormEncoder().encode(requestModel)
            case .multipartFormData:
                // TODO: Refactor into something like URLEncodedFormEncoder or import Swift package for multipart forms

                // Get file data from request model
                guard let fileData = requestModel as? Data else {
                    Logger.api.error(
                        "\(#function) Failed to get data from model for multipart POST endpoint \(String(reflecting: endpoint))"
                    )
                    return .failure(APIError.postMissingContents(endpoint: endpoint).error)
                }

                // Set content type to multipart/form-data
                let boundary = UUID().uuidString
                request.setValue(
                    "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

                // Create multipart form data
                var body = Data()
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append(
                    "Content-Disposition: form-data; name=\"file\"; filename=\"\("bike.jpg")\"\r\n"
                        .data(using: .utf8)!)
                body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
                body.append(fileData)
                body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

                request.httpBody = body
            }
        } catch {
            Logger.api.error("\(#function) Failed to encode POST body with \(error)")
            return .failure(error)
        }

        // Send POST request
        do {
            let (data, response) = try await session.data(for: request)
            try (response as? HTTPURLResponse)?.validate(with: data)

            Logger.api.debug("\(#function) posted data \(data)")
            Logger.api.debug("\(#function) posted data with response \(response)")

            return Result {
                if let result = try JSONDecoder().decode(endpoint.responseModel, from: data) as? T {
                    return result
                } else {
                    throw APIError.failedToDecodedExpectedModelType(response)
                }
            }
        } catch {
            Logger.api.error(
                "\(#function) failed to fetch \(String(describing: request.url))) with error \(error)"
            )
            return .failure(error)
        }
    }

    func postInBackground(_ endpoint: APIEndpoint, completion: @escaping (Result<Data, Error>) -> Void) {
        var request = endpoint.request(for: configuration.hostProvider)
        if endpoint.authorized, let accessToken {
            request.url?.append(queryItems: [URLQueryItem(name: "access_token", value: accessToken)]
            )
        }

        guard let requestModel = endpoint.requestModel else {
            Logger.api.error(
                "\(#function) Failed to find model for POST body encoding for endpoint \(String(reflecting: endpoint))"
            )
            completion(.failure(APIError.postMissingContents(endpoint: endpoint).error))
            return
        }
        guard let formType = endpoint.formType else {
            Logger.api.error(
                "\(#function) Failed to find form type for POST endpoint \(String(reflecting: endpoint))"
            )
            completion(.failure(APIError.postMissingContents(endpoint: endpoint).error))
            return
        }

        // Prepare HTTP body contents
        do {
            switch formType {
            case .formURLEncoded:
                request.httpBody = try URLEncodedFormEncoder().encode(requestModel)
            case .multipartFormData:
                // TODO: Refactor into something like URLEncodedFormEncoder or import Swift package for multipart forms

                // Get file data from request model
                guard let fileData = requestModel as? Data else {
                    Logger.api.error(
                        "\(#function) Failed to get data from model for multipart POST endpoint \(String(reflecting: endpoint))"
                    )
                    completion(.failure(APIError.postMissingContents(endpoint: endpoint).error))
                    return
                }

                // Set content type to multipart/form-data
                let boundary = UUID().uuidString
                request.setValue(
                    "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

                // Create multipart form data
                var body = Data()
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append(
                    "Content-Disposition: form-data; name=\"file\"; filename=\"\("bike.jpg")\"\r\n"
                        .data(using: .utf8)!)
                body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
                body.append(fileData)
                body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

                request.httpBody = body
            }
        } catch {
            Logger.api.error("\(#function) Failed to encode POST body with \(error)")
            completion(.failure(error))
        }

        // Send POST request
        do {
            // Save body to temporary file. Required for uploading in background. See: https://developer.apple.com/documentation/Foundation/downloading-files-in-the-background#Comply-with-background-transfer-limitations
            let tempDirectory = FileManager.default.temporaryDirectory
            let tempFileURL = tempDirectory.appendingPathComponent(UUID().uuidString)
            guard let httpBody = request.httpBody else {
                Logger.api.error("\(#function) Could not find POST HTTP body")
                throw APIError.postMissingContents(endpoint: endpoint)
            }
            try httpBody.write(to: tempFileURL)
            request.httpBody = nil
            let uploadTask = backgroundSession.uploadTask(with: request, fromFile: tempFileURL)
            uploadTask.resume()
            Logger.api.debug("\(#function) submitted background POST request for \(request.url ?? "nil")")
        } catch {
            Logger.api.error(
                "\(#function) failed to fetch \(String(describing: request.url))) with error \(error)"
            )
            completion(.failure(error))
        }
    }
}

enum HttpMethod: String {
    case get = "GET"
    case head = "HEAD"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case connect = "CONNECT"
    case options = "OPTIONS"
    case trace = "TRACE"
    case patch = "PATCH"
}

enum FormType {
    case formURLEncoded
    case multipartFormData
}

extension HTTPURLResponse {
    /// HTTP 304 "Not Modified"
    /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/304
    var cacheHit: Bool {
        statusCode == 304
    }

    /// HTTP 400 to 499 codes are Client Error Responses
    /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status#client_error_responses
    var clientError: Bool {
        statusCode >= 400 && statusCode < 500
    }

    @discardableResult
    func validate(with data: Data?) throws -> Bool {
        if cacheHit {
            throw APIError.cacheHit
        }
        if clientError {
            throw APIError.clientError(code: statusCode, data: data)
        }
        return true
    }
}
