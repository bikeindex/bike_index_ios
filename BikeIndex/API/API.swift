//
//  API.swift
//  BikeIndex
//
//  Created by Jack on 11/19/23.
//

import Foundation
import OSLog
import URLEncodedForm

/// URL's appending(components: String...) varidic function cannot accept arrays (splatting) so use reduce instead
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
public protocol Postable: Encodable, Sendable {}

protocol APIEndpoint: Sendable {
    /// Array of path components to-be concatenated to the URL
    var path: [String] { get }

    var method: HttpMethod { get }

    /// Does this endpoint require authorization? True for yes, false for no / public
    var authorized: Bool { get }

    var requestModel: Encodable? { get }
    var responseModel: any Decodable.Type { get }

    func request(for config: EndpointConfigurationProvider) -> URLRequest
}

/// API client to perform networking operations regardless of external state
@MainActor
final class API {
    var configuration: EndpointConfigurationProvider
    private(set) var session: URLSession

    init(configuration: EndpointConfigurationProvider, session: URLSession = URLSession.shared) {
        self.configuration = configuration
        self.session = session
    }

    func get(_ endpoint: APIEndpoint) async -> Result<(any Decodable), Error> {
        var request = endpoint.request(for: configuration)
        if endpoint.authorized, let accessToken = configuration.accessToken {
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

    /// Endpoint
    func post(_ endpoint: APIEndpoint) async -> Result<(any Decodable), Error> {
        var request = endpoint.request(for: configuration)
        if endpoint.authorized, let accessToken = configuration.accessToken {
            request.addValue(accessToken, forHTTPHeaderField: "access_token")
        }

        do {
            guard let requestModel = endpoint.requestModel else {
                Logger.api.error(
                    "\(#function) Failed to find model for POST body encoding for endpoint \(String(reflecting: endpoint))"
                )
                return .failure(APIError.postMissingContents(endpoint: endpoint))
            }
            request.httpBody = try URLEncodedFormEncoder().encode(requestModel)
        } catch {
            Logger.api.error("\(#function) Failed to encode POST body with \(error)")
            return .failure(error)
        }

        do {
            let (data, response) = try await session.data(for: request)
            try (response as? HTTPURLResponse)?.validate(with: data)

            Logger.api.debug("\(#function) posted data \(data)")
            Logger.api.debug("\(#function) posted data with response \(response)")

            return Result {
                try JSONDecoder().decode(endpoint.responseModel, from: data)
            }
        } catch {
            Logger.api.error(
                "\(#function) failed to fetch \(String(describing: request.url))) with error \(error)"
            )
            return .failure(error)
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

enum APIError: Error {
    case cacheHit
    case clientError(code: Int, data: Data?)
    case postMissingContents(endpoint: APIEndpoint)
}

extension HTTPURLResponse {

    var cacheHit: Bool {
        statusCode == 304
    }

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
