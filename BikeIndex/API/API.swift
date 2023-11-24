//
//  API.swift
//  BikeIndex
//
//  Created by Jack on 11/19/23.
//

import Foundation
import OSLog
import URLEncodedForm

//struct GenericResponseModel: Decodable {
//    let // how to decode json top-level object into dictionary?
//}

struct Endpoint {
    let url: URL
    let query: [URLQueryItem]
    let formBody: Encodable? = nil
    let method: HttpMethod

    var request: URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
}

protocol EndpointProvider {
    var value: Endpoint { get }
}

enum MeEndpoint: EndpointProvider {
    case me(config: EndpointConfigurationProvider)

    var url: URL {
        return URL(string: "https://bikeindex.org").unsafelyUnwrapped
    }

    var method: HttpMethod {
        return .get
    }

    var value: Endpoint {
        switch self {
        default:
            Endpoint(url: url, 
                     query: [],
                     method: method)
        }
    }
}

actor API {
    private(set) var session = URLSession.shared

    // TODO: Clean this shit up.
    // how to inline generics?
    func get<TModel: Decodable>(_ endpoint: EndpointProvider) async -> TModel {
        guard case .me(let config) = endpoint as? MeEndpoint else {
            fatalError()
        }

        var url = endpoint.value.url.appendingPathComponent("api/v3/me")
        url.append(queryItems: [
            URLQueryItem(name: "access_token", value: config.accessToken)
        ])

        let request = URLRequest(url: url)

        do {
            let (data, response) = try await session.data(for: request)

            Logger.api.debug("\(#function) fetched \(url)")
            Logger.api.debug("\(#function) \tfetched resposne \(String(describing: response))")
            Logger.api.debug("\(#function) \tfetched data \(String(data: data, encoding: .utf8).unsafelyUnwrapped)")

            func parseJson<T: Decodable>(data: Data, type: T.Type) -> T? {
                do {
                    return try JSONDecoder().decode(type.self, from: data)
                } catch {
                    print("JSON decode error:", error)
                    return nil
                }
            }

            let modelDirect = try JSONDecoder().decode(TModel.self, from: data)

            return modelDirect
        } catch {
            Logger.api.error("\(#function) failed to fetch \(url) with error \(error.localizedDescription)")
            fatalError()
        }
    }

    /// Endpoint
    func post(_ endpoint: EndpointProvider, _ model: Encodable, response responseModel: Decodable) async -> Data {
        guard let formBody = endpoint.value.formBody else {
            assertionFailure()
            return Data()
        }

        var request = URLRequest(url: endpoint.value.url)

        do {
            request.httpBody = try URLEncodedFormEncoder().encode(formBody)
        } catch {

        }

//        Logger.api.debug("\(#function) fetched \(url)")
//        Logger.api.debug("\(#function) \tfetched resposne \(String(describing: response))")
//        Logger.api.debug("\(#function) \tfetched data \(String(data: data, encoding: .utf8))")

        return Data()
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
