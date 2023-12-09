//
//  API.swift
//  BikeIndex
//
//  Created by Jack on 11/19/23.
//

import Foundation
import OSLog
import URLEncodedForm

/// Type to represent any API response model that is
/// 1) deocded
/// 2) stored to SwiftData
//public typealias PersistentDecodable = PersistentModel & Decodable


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
public typealias Postable = Encodable

protocol APIEndpoint {
    /// Array of path components to-be concatenated to the URL
    var path: [String] { get }
    var method: HttpMethod { get }

    /// Does this endpoint require authorization? True for yes, false for no / public
    var authorized: Bool { get }

    var requestModel: (any Encodable.Type)? { get }
    var responseModel: any Decodable.Type { get }

    func request(for config: EndpointConfigurationProvider) -> URLRequest
}

/// API client to perform networking operations regardless of external state
final class API {
    var configuration: EndpointConfigurationProvider
    private(set) var session: URLSession

    init(configuration: EndpointConfigurationProvider, session: URLSession = URLSession.shared) {
        self.configuration = configuration
        self.session = session
    }

    @MainActor
    /// SwiftData response
    /// - Parameters:
    ///   - endpoint:
    /// - Returns: <#description#>
    func get(_ endpoint: APIEndpoint) async -> Result<(any Decodable), Error> {
        var request = endpoint.request(for: configuration)
        if endpoint.authorized, let accessToken = configuration.accessToken {
            request.url?.append(queryItems: [URLQueryItem(name: "access_token", value: accessToken)])
        }

        do {
            let (data, response) = try await session.data(for: request)
            try (response as? HTTPURLResponse)?.validate(with: data)

            Logger.api.debug("\(type(of: self)).\(#function) fetched \(String(describing: request.url))")
            Logger.api.debug("\(type(of: self)).\(#function) \tfetched response \(String(describing: response))")
            Logger.api.debug("\(type(of: self)).\(#function) \tfetched data \(String(data: data, encoding: .utf8).unsafelyUnwrapped)")

            return Result {
                try JSONDecoder().decode(endpoint.responseModel, from: data)
            }
        } catch {
            Logger.api.error("\(#function) failed to fetch \(String(describing: request.url)) with error \(error)")
            return .failure(error)
        }
    }

    /// Endpoint
    func post(_ endpoint: APIEndpoint) async -> Result<(any Decodable), Error> {
        let request = endpoint.request(for: configuration)

        do {
            let (data, response) = try await session.data(for: request)
            try (response as? HTTPURLResponse)?.validate(with: data)

            Logger.api.debug("\(#function) posted data \(data)")
            Logger.api.debug("\(#function) posted data with response \(response)")

            return Result {
                try JSONDecoder().decode(endpoint.responseModel, from: data)
            }
        } catch {
            Logger.api.error("\(#function) failed to fetch \(String(describing: request.url))) with error \(error)")
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

extension HTTPURLResponse {
    public enum APIError: Error {
        case cacheHit
        case clientError(code: Int, data: Data?)
    }

    @discardableResult
    func validate(with data: Data?) throws -> Bool {
        if statusCode == 304 {
            throw APIError.cacheHit
        }
        if statusCode >= 400, statusCode <= 499 {
            throw APIError.clientError(code: statusCode, data: data)
        }
        return true
    }
}
