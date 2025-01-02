//
//  DebugDataView.swift
//  BikeIndex
//
//  Created by Jack on 1/1/25.
//

import SwiftUI
import SwiftData

#if DEBUG
struct DebugDataView: View {
    @Query var authenticatedUsers: [AuthenticatedUser]
    @Query var users: [User]
    @Query var bikes: [Bike]
    @Query var organizations: [Organization]
    @Query var manufacturers: [AutocompleteManufacturer]

    var body: some View {
        Form {
            // MARK: - AuthenticatedUsers
            Section {
                ForEach(authenticatedUsers) { authUser in
                    VStack(alignment: .leading) {
                        Text("ID: \(authUser.identifier)")
                        Text("User [UUID]: \(authUser.user?.persistentModelID.storeIdentifier ?? "Empty")")
                        Text("Bikes [ID]: \(String(describing: authUser.bikes.map(\.identifier)))")
                    }
                }
            } header: {
                Text("Authenticated Users")
            }

            // MARK: - Users
            Section {
                LazyVGrid(columns: Array(repeating: GridItem(), count: users.count)) {
                    ForEach(users) { user in
                        GridRow {
                            VStack(alignment: .leading) {
                                Text("Email: \(user.email)")
                                Text("UUID: \(user.persistentModelID.storeIdentifier ?? "Empty")")
                                Text("Username: \(user.name)")
                                Text("Additional Emails: \(String(describing: user.additionalEmails))")
                                Text("Created At: \(user.createdAt.description)")
                                Text("Image: \(String(describing: user.image))")
                                Text("Twitter: \(String(describing: user.twitter))")
                            }
                        }
                    }
                }
            } header: {
                Text("Users")
            }

            // MARK: - Bikes
            Section {
                LazyVGrid(columns: Array(repeating: GridItem(), count: bikes.count)) {
                    ForEach(bikes) { bike in
                        GridRow {
                            VStack(alignment: .leading) {
                                Text("ID: \(bike.identifier, format: .number.grouping(.never))")
                                Text("Owner [UUID]: \(bike.owner?.persistentModelID.storeIdentifier ?? "Empty")")
                                Text("Auth Owner [ID]: \(bike.authenticatedOwner?.identifier ?? "Empty")")
                                Text("Description: \(bike.bikeDescription)")
                                Text("Frame Model: \(bike.frameModel)")
                                Text("Color Primary: \(String(describing: bike.frameColorPrimary))")
                                // TODO: Continue Bike fields...
                            }
                        }
                    }
                }
            } header: {
                Text("Bikes")
            }

        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let mockContainer = try ModelContainer(
            for: Bike.self, User.self, AuthenticatedUser.self, Organization.self, AutocompleteManufacturer.self,
            configurations: config
        )

        return DebugDataView()
            .modelContainer(mockContainer)
    } catch {
        return Text(error.localizedDescription)
    }
}
#endif
