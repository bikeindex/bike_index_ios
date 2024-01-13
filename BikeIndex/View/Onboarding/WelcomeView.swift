//
//  WelcomeView.swift
//  BikeIndex
//
//  Created by Jack on 1/1/24.
//

import SwiftUI
import WebViewKit

// MARK: - Use Case Buttons

enum UseCaseButtons: CaseIterable, Identifiable {
    var id: Self { self }

    case bikeShops
    case cities
    case schools
    case communityGroups

    func action(on base: URL) -> URL {
        switch self {
        case .bikeShops:
            base.appending(path: "for_bike_shops")
        case .cities:
            base.appending(path: "for_cities")
        case .schools:
            base.appending(path: "for_schools")
        case .communityGroups:
            base.appending(path: "for_community_groups")
        }
    }

    var title: String {
        switch self {
        case .bikeShops:
            "Bike Shops"
        case .cities:
            "Cities"
        case .schools:
            "Schools"
        case .communityGroups:
            "Community Groups"
        }
    }
}

// MARK: - Message Content

struct WelcomeMessageModel {
    let title: String
    let subheadline: String?
    let iconName: ActionIconResource?
}

enum WelcomeMessages: CaseIterable, Identifiable {
    case registerStep1
    case alertStep2
    case respondStep3
    case retrieveStep4

    var id: Self { self }

    var content: WelcomeMessageModel {
        switch self {
        case .registerStep1:
            return WelcomeMessageModel(title: "Register Your Bike", subheadline: "It's simple. Submit your name, bike manufacturer, serial number, and component information to enter your bike into the most widely used bike registry on the planet.", iconName: .register)
        case .alertStep2:
            return WelcomeMessageModel(title: "Alert the Community", subheadline: "If your bike goes missing, mark it as lost or stolen to notify the entire Bike Index community and its partners.", iconName: .alert)
        case .respondStep3:
            return WelcomeMessageModel(title: "The community responds", subheadline: "A user or partner encounters your bike, uses Bike Index to identify it, and contacts you.", iconName: .responds)
        case .retrieveStep4:
            return WelcomeMessageModel(title: "You Get your Bike Back", subheadline: "With the help of the Bike Index community and its partners, you have the information necessary to recover your lost or stolen bike at no cost to you. It's what we do.", iconName: .recover)
        }
    }
}

struct WelcomeMessageView: View {
    var message: WelcomeMessages

    var body: some View {
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
}

// MARK: -

/// Pair with ``AuthView`` for a complete login experience
struct WelcomeView: View {
    @Environment(Client.self) var client
    @Environment(\.colorScheme) var colorScheme

    @State var selectedUseCase: UseCaseButtons?

    var body: some View {
        ScrollView {
            VStack {
                Text("Over $23,757,653 Worth of Bikes Recovered")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 12)
                Text("Bike Registration that works")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)

                Spacer()
                ForEach(UseCaseButtons.allCases) { useCase in
                    Button(action: {
                        selectedUseCase = useCase
                    }, label: {
                        Text("for \(useCase.title)")
                            .padding(.leading, 4)
                        Spacer()
                    })
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, minHeight: 40)
                    .tint(.white)
                    .background(colorScheme == .light ? .black : .secondary)
                    .padding(.horizontal, 8)
                }
                Spacer()
                ForEach(WelcomeMessages.allCases) { message in
                    WelcomeMessageView(message: message)
                        .padding()
                }
                Spacer()
            }
        }
        .navigationDestination(item: $selectedUseCase) { useCase in
            WebView(url: useCase.action(on: client.configuration.host))
        }
        .toolbarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbarBackground(colorScheme == .light ? .black : .blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        WelcomeView()
            .environment(try! Client())
            .navigationTitle("Welcome to Bike Index")
    }
}
