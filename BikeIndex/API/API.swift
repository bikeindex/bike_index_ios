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
    let path: APIEndpoint
    let config: EndpointConfigurationProvider

    var request: URLRequest {
        let request = URLRequest(url: config.host
            .appending(components: path.path)
            .appending(queryItems: [URLQueryItem(name: "accessToken", value: config.accessToken)])
//            .appending(queryItems: query)
        )
//        request.httpMethod = method.rawValue
//    encodingPostForm: if method == .post {
//            guard let formBody else {
//                Logger.api.info("Failed to configure POST request to \(url) for lack of encodable form body.")
//                break encodingPostForm
//            }
//            do {
//                request.httpBody = try URLEncodedFormEncoder().encode(formBody)
//            } catch {
//                Logger.api.info("Failed to configure POST request to \(url) with body because of encoding failure \(error)")
//            }
//        }
        return request
    }

    /*

     API Specification:

     protocol APIEndpoint: {
        var path
        var HttpMethod
     }

     enum Search: APIEndpoint: {





     let query: [URLQueryItem] = []
     let formBody: Encodable? = nil





     */
}

/// URL's appending(components: String...) varidic function cannot accept arrays (called splatting) so use reduce instead
extension URL {
    func appending(components: [String]) -> Self {
        return components.reduce(self) { partialResult, path in
            partialResult.appending(path: path)
        }
    }
}

/// API usage of Bike.id is string-backed
public typealias BikeId = String

protocol APIEndpoint {
    var path: [String] { get }
//    var method: HttpMethod { get }
}

public typealias Postable = Encodable

struct BikeIndexV3 {
    static let v3 = "v3"

    enum Organizations: APIEndpoint {
        case `self`(form: Postable)

        var path: [String] {
            [v3, "organizations"]
        }
    }

    enum Search: APIEndpoint {
        case `self`
        case count
        case close_serials
        case serials_containing
        case external_registries

        var path: [String] {
            switch self {
            case .`self`:
                [v3, "search"]
            case .count:
                [v3, "search", "count"]
            case .close_serials:
                [v3, "search", "close_serials"]
            case .serials_containing:
                [v3, "search", "serials_containing"]
            case .external_registries:
                [v3, "search", "external_registries"]
            }
        }
    }

    enum Bikes: APIEndpoint {
        case postBikes(form: Postable)
        case bikes(identifier: BikeId) // aka v3/bikes/{id} also available with no parameter
        case putBikes(identifier: BikeId, form: Postable) // aka v3/bikes/{id} also available with no parameter
        case check_if_registered
        case recover(identifier: BikeId)
        case image(identifier: BikeId)
        case images(identifier: BikeId, imageIdentifier: String)
        case send_stolen_notification(identifier: BikeId)

        var path: [String] {
            switch self {
            case .putBikes(let identifier, _):
                [v3, "bikes", identifier]
            case .bikes(let identifier):
                [v3, "bikes", identifier]
            case .postBikes:
                [v3, "bikes"]
            case .check_if_registered:
                [v3, "bikes", "check_if_registered"]
            case .recover(let identifier):
                [v3, "bikes", identifier, "recover"]
            case .image(let identifier):
                [v3, "bikes", identifier, "image"]
            case .images(let bikeIdentifier, let imageIdentifier):
                [v3, "bikes", bikeIdentifier, "images", imageIdentifier]
            case .send_stolen_notification(let identifier):
                [v3, "bikes", identifier, "send_stolen_notification"]
            }
        }
    }

    enum Me: APIEndpoint {
        case `self` // v3/me
        case bikes
        
        var path: [String] {
            switch self {
                case .`self`:
                [v3, "me"]
            case .bikes:
                [v3, "me", "bikes"]
            }
        }
    }

    enum Manufacturers: APIEndpoint {
        case all
        case get(identifier: BikeId) // aka v3/manufacturers/{id}, also available with no parameter

        var path: [String] {
            switch self {
            case .all:
                [v3, "manufacturers"]
            case .get(let identifier):
                [v3, "manufacturers", identifier]
            }
        }
    }

    enum Selections: APIEndpoint {
        case colors
        case component_types
        case cycle_types
        case frame_materials
        case front_gear_types
        case rear_gears_types
        case handlebar_types
        case propulsion_types
        case wheel_sizes
        
        var path: [String] {
            switch self {
            case .colors:
                [v3, "selection", "colors"]
            case .component_types:
                [v3, "selection", "component_types"]
            case .cycle_types:
                [v3, "selection", "cycle_types"]
            case .frame_materials:
                [v3, "selection", "frame_materials"]
            case .front_gear_types:
                [v3, "selection", "front_gear_types"]
            case .rear_gears_types:
                [v3, "selection", "rear_gears_types"]
            case .handlebar_types:
                [v3, "selection", "handlebar_types"]
            case .propulsion_types:
                [v3, "selection", "propulsion_types"]
            case .wheel_sizes:
                [v3, "selection", "wheel_sizes"]
            }
        }
    }
}

//protocol EndpointProvider {
//    var value: Endpoint { get }
//}

//enum MeEndpoint: EndpointProvider {
//    case me
//
//    var url: URL {
//        return URL(string: "https://bikeindex.org").unsafelyUnwrapped
//    }
//
//    var method: HttpMethod {
//        return .get
//    }
//
//    var value: Endpoint {
//        switch self {
//        default:
//            Endpoint(url: url, 
//                     query: [],
//                     method: method)
//        }
//    }
//
//}

actor API {
    private(set) var session = URLSession.shared

    // TODO: Clean this shit up.
    // how to inline generics?
    func get<TModel: Decodable>(_ endpoint: Endpoint) async -> TModel? {
//        guard case .me(let config) = endpoint as? MeEndpoint else {
//            fatalError()
//        }

//        var url = endpoint.value.url.appendingPathComponent("api/v3/me")
//        url.append(queryItems: [
//            URLQueryItem(name: "access_token", value: config.accessToken)
//        ])

        let request = endpoint.request

        do {
            let (data, response) = try await session.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 304 {
                    return nil
                }
            }

            Logger.api.debug("\(#function) fetched \(String(describing: endpoint.request.url))")
            Logger.api.debug("\(#function) \tfetched response \(String(describing: response))")
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
            Logger.api.error("\(#function) failed to fetch \(String(describing: endpoint.request.url)) with error \(error)")
            return nil
        }
    }

    /// Endpoint
    func post(_ endpoint: Endpoint, _ model: Encodable, response responseModel: Decodable) async -> Data {
        let request = endpoint.request

        do {
            let (data, response) = try await session.data(for: request)
            Logger.api.debug("\(#function) posted data \(data)")
            Logger.api.debug("\(#function) posted data with response \(response)")
            return data
        } catch {
            Logger.api.error("\(#function) failed to fetch \(String(describing: endpoint.request.url)) with error \(error)")
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
