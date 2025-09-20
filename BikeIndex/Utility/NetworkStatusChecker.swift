//
//  Checker.swift
//  BikeIndex
//
//  Created by Jack on 6/21/25.
//

import Network
import SwiftData
import SwiftUI
import WebKit
import WebViewKit

extension NWPath.Status {
    var displayTitle: String {
        switch self {
        case .satisfied:
            "Satisfied"
        case .unsatisfied:
            "Unsatisfied"
        case .requiresConnection:
            "Requires Connection"
        @unknown default:
            "UNKNOWN"
        }
    }
}

@Observable @MainActor
class NetworkStatusChecker {
    static let shared = NetworkStatusChecker()

    private let pathMonitor = NWPathMonitor()

    private(set) var status: NWPath.Status = .requiresConnection

    var presentOfflineMode: Bool = false

    init() {
        pathMonitor.start(queue: .main)
        pathMonitor.pathUpdateHandler = { path in
            Task {
                await self.update(status: path.status)
            }
        }
    }

    func update(status: NWPath.Status) {
        self.status = status
        self.presentOfflineMode = status == .unsatisfied
    }
}
