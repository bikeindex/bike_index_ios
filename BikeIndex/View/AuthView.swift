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

typealias AuthCompletion = (Token?, Error?) -> Void
typealias InnerAuthCompletion = ASWebAuthenticationSession.CompletionHandler

struct AuthView: View {
    /// api client for performing auth
    @Environment(Client.self) var client

    var body: some View {
        NavigationStack {
            AuthContent { url, error in
                guard let url else {
                    return
                }
                client.accept(authCallback: url)
            }
            .environment(client)
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
            .navigationTitle("Please sign in")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    AuthView()
        .environment(try! Client())
}

struct AuthContent: UIViewControllerRepresentable {
    typealias UIViewControllerType = AuthHarness
    var completion: InnerAuthCompletion
    @Environment(Client.self) var client

    func makeUIViewController(context: Context) -> AuthHarness {
        AuthHarness(client: client, completion: completion)
    }

    func updateUIViewController(_ uiViewController: AuthHarness, context: Context) {
    }
}

class AuthHarness: UIViewController {
    var client: Client
    var controller: AuthenticationController?
    var completion: InnerAuthCompletion
    var webView = WKWebView()

    init(client: Client, completion: @escaping InnerAuthCompletion) {
        self.client = client
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        #if DEBUG
        // Very helpful during local development to have visual confirmation the site is loading
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        webView.load(URLRequest(url: client.configuration.host))
        #endif

        guard let scene = view.window?.windowScene else {
            return
        }

        self.controller = AuthenticationController(anchor: ASPresentationAnchor(windowScene: scene),
                                                   completion: completion)
        self.controller?.authenticate(client: client)
    }
}

final class AuthenticationController: NSObject {
    let anchor: ASPresentationAnchor
    let completion: InnerAuthCompletion

    init(anchor: ASPresentationAnchor, completion: @escaping InnerAuthCompletion) {
        self.anchor = anchor
        self.completion = completion
    }

    func authenticate(client: Client) {
        var url = client.configuration.host.appending(path: "oauth/authorize")

        let queryItems: [URLQueryItem] = [
            ("client_id", client.configuration.clientId),
            ("response_type", "code"),
            ("redirect_uri", client.configuration.redirectUri),
            ("scope", client.configuration.oauthScopes.queryItem)
        ].map { (item: QueryItemTuple) in
            URLQueryItem(name: item.name, value: item.value)
        }
        url.append(queryItems: queryItems)

        let callback = client.configuration.redirectUri.trimmingCharacters(in: .alphanumerics.inverted)
        let session = ASWebAuthenticationSession(url: url,
                                                 callbackURLScheme: callback,
                                                 completionHandler: completion)

        // emphemeral = false allows the session to stay in safari
        session.prefersEphemeralWebBrowserSession = false

        session.presentationContextProvider = self

        session.start()
    }
}

extension AuthenticationController: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return anchor
    }
}
