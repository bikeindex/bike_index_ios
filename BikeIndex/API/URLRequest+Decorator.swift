//
//  URLRequest+Decorator.swift
//  BikeIndex
//
//  Created by Jack on 12/13/25.
//

import Foundation

extension URLRequest {
    func validateMethodMatch(_ method: HttpMethod) -> URLRequest {
        assert(HttpMethod(rawValue: self.httpMethod ?? "") == method)
        return self
    }

    func addAppVersion() -> URLRequest {
        var request = self
        if let version = AppVersionInfo().marketingVersion {
            request.addValue(version, forHTTPHeaderField: "X-IOS-VERSION")
        }
        return request
    }

    func add(accessToken: String?, requiresAuthorization: Bool) -> URLRequest {
        var request = self
        if requiresAuthorization, let accessToken {
            let accessTokenQueryItem = URLQueryItem(name: "access_token", value: accessToken)
            request.url?.append(queryItems: [accessTokenQueryItem])
        }
        return request
    }
}
