//
//  URLRequest+Decorator.swift
//  BikeIndex
//
//  Created by Jack on 12/13/25.
//

import Foundation

extension URLRequest {
    func addAppVersion() -> URLRequest {
        var request = self
        if let version = AppVersionInfo().marketingVersion {
            request.addValue(version, forHTTPHeaderField: "X-IOS-VERSION")
        }
        return request
    }

    func add(accessToken: String?, for endpoint: APIEndpoint) -> URLRequest {
        var request = self
        if endpoint.authorized, let accessToken {
            let accessTokenQueryItem = URLQueryItem(name: "access_token", value: accessToken)
            request.url?.append(queryItems: [accessTokenQueryItem])
        }
        return request
    }
}
