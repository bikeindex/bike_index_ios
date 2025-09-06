//
//  APIEndpoints.swift
//  BikeIndex
//
//  Created by Jack on 12/3/23.
//

import Foundation
import OSLog

private let api = "api"
private let v3 = "v3"

/// Convenience default empty object endpoints that will not provide any request model.
struct EmptyPost: Postable {}

struct EmptyResponse: ResponseDecodable {}

/// Endpoints related to authorization.
/// https://bikeindex.org/documentation/api_v3#ref_oauth
enum OAuth: APIEndpoint {
    /// Invoked first of all networking in a web authentication session before any authorized action can occur.
    case authorize(queryItems: [URLQueryItem])

    /// Invoked second of all networking _using the `code` result_ from the ``OAuth.authorize`` response.
    case token(queryItems: [URLQueryItem])

    /// POST https://bikeindex.org/oauth/token?grant_type=refresh_token&client_id={app_id}&refresh_token={refresh_token}
    /// -- https://bikeindex.org/documentation/api_v3#ref_refresh_tokens
    case refresh(queryItems: [URLQueryItem])

    case logout

    // MARK: -

    var method: HttpMethod {
        switch self {
        case .authorize, .token, .refresh:
            .post
        case .logout:
            .get
        }
    }

    /// Technically oauth/token does require authorization but the token is not available from ClientConfiguration.
    /// oauth/token _provides_ the access token to ClientConfiguration
    var authorized: Bool {
        false
    }

    /// Normally this would have contents, but because authorization occurs first the request contents require stateful involvement from Client
    var requestModel: Encodable? {
        nil
    }

    var responseModel: ResponseDecodable.Type {
        switch self {
        case .authorize, .token, .refresh:
            OAuthToken.self
        case .logout:
            EmptyResponse.self
        }
    }

    var path: [String] {
        switch self {
        case .authorize:
            return ["oauth", "authorize"]
        case .token, .refresh:
            return ["oauth", "token"]
        case .logout:
            return ["logout"]
        }
    }

    func request(for config: HostProvider) -> URLRequest {
        var url = config.host.appending(components: path)
        switch self {
        case .authorize(let queryItems):
            url.append(queryItems: queryItems)
        case .token(let queryItems):
            url.append(queryItems: queryItems)
        case .refresh(let queryItems):
            assert(queryItems.contains(where: { $0.name == "grant_type" }))
            assert(queryItems.contains(where: { $0.name == "refresh_token" }))
            assert(queryItems.contains(where: { $0.name == "client_id" }))
            url.append(queryItems: queryItems)
        case .logout:
            break
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
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
            [api, v3, "search"]
        case .count:
            [api, v3, "search", "count"]
        case .close_serials:
            [api, v3, "search", "close_serials"]
        case .serials_containing:
            [api, v3, "search", "serials_containing"]
        case .external_registries:
            [api, v3, "search", "external_registries"]
        }
    }

    var method: HttpMethod {
        .post
    }

    var authorized: Bool { false }

    var requestModel: Encodable? {
        nil
    }

    var responseModel: ResponseDecodable.Type {
        OAuthToken.self
    }

    func request(for config: HostProvider) -> URLRequest {
        URLRequest(url: config.host)
    }
}

enum Bikes: APIEndpoint {
    /// Add a new bike to the index via `POST v3/bikes`
    case postBikes(form: BikeRegistration)
    /// Fetch bike details via `GET v3/bikes/{id}`
    case bikes(identifier: BikeId)
    /// Update a bike (must be owned by this user) via `PUT v3/bikes/{id}`
    case putBikes(identifier: BikeId, form: Postable)
    case check_if_registered
    case recover(identifier: BikeId)
    case image(identifier: BikeId)
    case images(identifier: BikeId, imageIdentifier: String)
    case send_stolen_notification(identifier: BikeId)

    var path: [String] {
        switch self {
        case .putBikes(let identifier, _):
            [api, v3, "bikes", identifier]
        case .bikes(let identifier):
            [api, v3, "bikes", identifier]
        case .postBikes:
            [api, v3, "bikes"]
        case .check_if_registered:
            [api, v3, "bikes", "check_if_registered"]
        case .recover(let identifier):
            [api, v3, "bikes", identifier, "recover"]
        case .image(let identifier):
            [api, v3, "bikes", identifier, "image"]
        case .images(let bikeIdentifier, let imageIdentifier):
            [api, v3, "bikes", bikeIdentifier, "images", imageIdentifier]
        case .send_stolen_notification(let identifier):
            [api, v3, "bikes", identifier, "send_stolen_notification"]
        }
    }

    var method: HttpMethod {
        .post
    }

    var authorized: Bool { true }

    var requestModel: Encodable? {
        switch self {
        case .postBikes(let form):
            return form
        default:
            return nil
        }
    }

    var responseModel: ResponseDecodable.Type {
        switch self {
        case .postBikes:
            return SingleBikeResponseContainer.self
        default:
            return EmptyResponse.self
        }
    }

    func request(for config: HostProvider) -> URLRequest {
        let url = config.host.appending(components: path)
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }
}

enum Me: APIEndpoint {
    case `self`  // v3/me
    case bikes

    var path: [String] {
        switch self {
        case .`self`:
            [api, v3, "me"]
        case .bikes:
            [api, v3, "me", "bikes"]
        }
    }

    var method: HttpMethod {
        .post
    }

    var authorized: Bool { true }

    var requestModel: Encodable? {
        nil
    }

    var responseModel: ResponseDecodable.Type {
        switch self {
        case .self:
            return AuthenticatedUserResponse.self
        case .bikes:
            return MultipleBikeResponseContainer.self
        }
    }

    func request(for config: HostProvider) -> URLRequest {
        let url = config.host.appending(components: path)
        return URLRequest(url: url)
    }
}

enum Autocomplete: APIEndpoint {
    case manufacturer(query: String)

    var path: [String] {
        switch self {
        case .manufacturer:
            [api, "autocomplete"]
        }
    }

    var method: HttpMethod {
        .get
    }

    var authorized: Bool { false }

    var requestModel: Encodable? {
        nil
    }

    var responseModel: ResponseDecodable.Type {
        switch self {
        case .manufacturer:
            AutocompleteManufacturerContainerResponse.self
        }
    }

    func request(for config: HostProvider) -> URLRequest {
        var url = config.host.appending(components: path)

        if case .manufacturer(let query) = self {
            url.append(queryItems: [
                URLQueryItem(name: "per_page", value: "10"),
                URLQueryItem(name: "categories", value: "frame_mnfg"),
                URLQueryItem(name: "q", value: query),
            ])
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        return request
    }

}

enum Manufacturers: APIEndpoint {
    case all
    case get(identifier: BikeId)  // aka v3/manufacturers/{id}, also available with no parameter

    var path: [String] {
        switch self {
        case .all:
            [api, v3, "manufacturers"]
        case .get(let identifier):
            [api, v3, "manufacturers", identifier]
        }
    }

    var method: HttpMethod {
        .post
    }

    var authorized: Bool { false }

    var requestModel: Encodable? {
        nil
    }

    var responseModel: ResponseDecodable.Type {
        fatalError()
    }

    func request(for config: HostProvider) -> URLRequest {
        URLRequest(url: config.host)
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
            [api, v3, "selection", "colors"]
        case .component_types:
            [api, v3, "selection", "component_types"]
        case .cycle_types:
            [api, v3, "selection", "cycle_types"]
        case .frame_materials:
            [api, v3, "selection", "frame_materials"]
        case .front_gear_types:
            [api, v3, "selection", "front_gear_types"]
        case .rear_gears_types:
            [api, v3, "selection", "rear_gears_types"]
        case .handlebar_types:
            [api, v3, "selection", "handlebar_types"]
        case .propulsion_types:
            [api, v3, "selection", "propulsion_types"]
        case .wheel_sizes:
            [api, v3, "selection", "wheel_sizes"]
        }
    }

    var method: HttpMethod {
        .post
    }

    var requestModel: Encodable? {
        return nil
    }

    var authorized: Bool { true }

    var responseModel: ResponseDecodable.Type {
        fatalError()
    }

    func request(for config: HostProvider) -> URLRequest {
        URLRequest(url: config.host)
    }
}
