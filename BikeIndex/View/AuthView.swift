//
//  TestViewController.swift
//  BikeIndex
//
//  Created by Jack on 11/18/23.
//

import UIKit
import SwiftUI
import AuthenticationServices
import WebKit

fileprivate extension ClientConfiguration {
    var authorizeUrl: URL {
        var url = host.appending(path: "oauth/authorize")

        let queryItems: [URLQueryItem] = [
            ("client_id", clientId),
            ("response_type", "code"),
            ("redirect_uri", redirectUri),
            ("scope", oauthScopes.queryItem)
        ].map { (item: QueryItemTuple) in
            URLQueryItem(name: item.name, value: item.value)
        }
        url.append(queryItems: queryItems)
        return url
    }
}

struct WelcomeMessage {
    let title: String
    let subheadline: String?
    let iconName: ActionIconResource?
}

enum WelcomeMessages: CaseIterable, Identifiable {
    case headline
    case explanation
    case registerStep1
    case alertStep2
    case respondStep3
    case retrieveStep4

    var id: Self { self }

    var content: WelcomeMessage {
        switch self {
        case .headline:
            return WelcomeMessage(title: "Bike registration that works", subheadline: "Over $23,757,653 Worth of Bikes Recovered", iconName: nil)
        case .explanation:
            return WelcomeMessage(title: "How does it work?", subheadline: nil, iconName: nil)
        case .registerStep1:
            return WelcomeMessage(title: "Register Your Bike", subheadline: "It's simple. Submit your name, bike manufacturer, serial number, and component information to enter your bike into the most widely used bike registry on the planet.", iconName: .register)
        case .alertStep2:
            return WelcomeMessage(title: "Alert the Community", subheadline: "If your bike goes missing, mark it as lost or stolen to notify the entire Bike Index community and its partners.", iconName: .alert)
        case .respondStep3:
            return WelcomeMessage(title: "The community responds", subheadline: "A user or partner encounters your bike, uses Bike Index to identify it, and contacts you.", iconName: .recover)
        case .retrieveStep4:
            return WelcomeMessage(title: "You Get your Bike Back", subheadline: "With the help of the Bike Index community and its partners, you have the information necessary to recover your lost or stolen bike at no cost to you. It's what we do.", iconName: .responds)
        }
    }
}

struct AuthView: View {
    @Environment(\.webAuthenticationSession) private var webAuthenticationSession

    /// api client for performing auth
    @Environment(Client.self) var client

    var body: some View {
        NavigationStack {
            List(WelcomeMessages.allCases) { message in
                VStack {
                    Text(message.content.title)
                        .font(.headline)
                    HStack {
                        if let subheadline = message.content.subheadline {
                            Text(subheadline)
                        }
                        Spacer()
                        if let icon = message.content.iconName?.image {
                            Image(uiImage: icon)
                                .resizable()
                                .aspectRatio(1.0, contentMode: .fit)
                                .frame(width: 75, height: 75)
                        }
                    }
                }
            }
            Button(action: {
                Task {
                    let urlWithToken = try await webAuthenticationSession.authenticate(
                        using: client.configuration.authorizeUrl,
                        callbackURLScheme: client.configuration.redirectUri.trimmingCharacters(in: .alphanumerics.inverted),
                        preferredBrowserSession: .shared)
                    await client.accept(authCallback: urlWithToken)
                }
            }, label: {
                Label("Sign in and get started", systemImage: "person.crop.circle.dashed")
                    .font(.title2)

            })
#if DEBUG
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("Settings", systemImage: "gear")
                    }
                }
            }
#endif
            .navigationTitle("Welcome to Bike Index")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AuthView()
        .environment(try! Client())
}
