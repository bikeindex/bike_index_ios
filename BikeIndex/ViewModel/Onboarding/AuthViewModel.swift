//
//  AuthViewModel.swift
//  BikeIndex
//
//  Created by Jack on 3/19/25.
//

import Foundation
import SwiftUI

extension AuthView {
    @MainActor @Observable
    final class ViewModel {
        /// Control presenting a modal sheet for app authorization
        var displaySignIn = false

        /// Object to intercept authentication events from the sign-in webview and forward them to Client
        /// ``AuthenticationNavigator/client`` must be connected at runtime so that AuthNavigator can update ``Client``
        /// with authorization events.
        let authNavigator = AuthenticationNavigator()

        /// AuthView may push to a Debug view (debug builds only)
        var topLevelPath = NavigationPath()

        // MARK: - NavigationPath

        enum Nav: Identifiable {
            var id: Self { self }

            case debugSettings
            case help
        }
    }
}
