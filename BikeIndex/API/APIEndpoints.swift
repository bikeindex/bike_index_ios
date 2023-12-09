//
//  APIEndpoints.swift
//  BikeIndex
//
//  Created by Jack on 12/3/23.
//

import Foundation
import OSLog

//struct BikeIndexV3 {
fileprivate let api = "api"
fileprivate let v3 = "v3"

struct EmptyPost: Postable {}

enum OAuth: APIEndpoint {
    /// https://bikeindex.org/documentation/api_v3#ref_oauth
    case token(queryItems: [URLQueryItem])

    // MARK: -

    var method: HttpMethod {
        .post
    }

    var requestModel: (Encodable.Type)? {
        EmptyPost.self
    }

    var responseModel: Decodable.Type {
        OAuthToken.self
    }

    var path: [String] {
        ["oauth", "token"]
    }

    func request(for config: EndpointConfigurationProvider) -> URLRequest {
        var url = config.host.appending(components: path)
        switch self {
        case .token(let queryItems):
            url.append(queryItems: queryItems)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
}

enum Organizations: APIEndpoint {
    case `self`(form: Postable)

    var path: [String] {
        [api, v3, "organizations"]
    }

    var method: HttpMethod {
        .post
    }

    var requestModel: (Encodable.Type)? {
        EmptyPost.self
    }

    var responseModel: Decodable.Type {
        OAuthToken.self
    }

    func request(for config: EndpointConfigurationProvider) -> URLRequest {
        URLRequest(url: config.host)
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

    var requestModel: (Encodable.Type)? {
        EmptyPost.self
    }

    var responseModel: Decodable.Type {
        OAuthToken.self
    }

    func request(for config: EndpointConfigurationProvider) -> URLRequest {
        URLRequest(url: config.host)
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

    var requestModel: (Encodable.Type)? {
        EmptyPost.self
    }

    var responseModel: Decodable.Type {
        OAuthToken.self
    }

    func request(for config: EndpointConfigurationProvider) -> URLRequest {
        var url = config.host.appending(components: path)
        return URLRequest(url: url)
    }
}

enum Me: APIEndpoint {
    case `self` // v3/me
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

    var requestModel: (Encodable.Type)? {
        EmptyPost.self
    }

    var responseModel: Decodable.Type {
        switch self {
        case .self:
            return AuthenticatedUserResponse.self
        case .bikes:
            return [Bike].self
        }
    }

    func request(for config: EndpointConfigurationProvider) -> URLRequest {
        var url = config.host.appending(components: path)
        switch self {
        case .`self`:
            Logger.api.info("hi")
        case .bikes:
            Logger.api.info("hi")
        }
        return URLRequest(url: url)
    }
}

enum Manufacturers: APIEndpoint {
    case all
    case get(identifier: BikeId) // aka v3/manufacturers/{id}, also available with no parameter

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

    var requestModel: (Encodable.Type)? {
        EmptyPost.self
    }

    var responseModel: Decodable.Type {
        OAuthToken.self
    }

    func request(for config: EndpointConfigurationProvider) -> URLRequest {
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

    var requestModel: (Encodable.Type)? {
        EmptyPost.self
    }

    var responseModel: Decodable.Type {
        OAuthToken.self
    }

    func request(for config: EndpointConfigurationProvider) -> URLRequest {
        URLRequest(url: config.host)
    }
}
