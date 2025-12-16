//
//  DebugDataView.swift
//  BikeIndex
//
//  Created by Jack on 1/1/25.
//

import SwiftData
import SwiftUI

#if DEBUG
struct DebugDataView: View {
    @Query var authenticatedUsers: [AuthenticatedUser]
    @Query var users: [User]
    @Query var bikes: [Bike]
    @Query var manufacturers: [AutocompleteManufacturer]

    var body: some View {
        Form {
            // MARK: - AuthenticatedUsers
            DataModelDebugView(models: authenticatedUsers) { authUser in
                Text("ID: \(authUser.identifier)")
                Text("User [UUID]: \(authUser.user?.persistentModelID.storeIdentifier ?? "Empty")")
                Text("Bikes [ID]: \(String(describing: authUser.bikes.map(\.identifier)))")
            }

            // MARK: - Users
            DataModelDebugView(models: users) { user in
                Text("Email: \(user.email)")
                Text("UUID: \(user.persistentModelID.storeIdentifier ?? "Empty")")
                Text("Username: \(user.name)")
                Text("Additional Emails: \(String(describing: user.additionalEmails))")
                Text("Created At: \(user.createdAt.description)")
                Text("Image: \(String(describing: user.image))")
                Text("Twitter: \(String(describing: user.twitter))")
            }

            // MARK: - Bikes
            DataModelDebugView(models: bikes) { bike in
                Text("ID: \(bike.identifier, format: .number.grouping(.never))")
                Text("Owner [UUID]: \(bike.owner?.persistentModelID.storeIdentifier ?? "Empty")")
                Text("Auth Owner [ID]: \(bike.authenticatedOwner?.identifier ?? "Empty")")
                Text("Description: \(bike.bikeDescription ?? "")")
                Text("Frame Model: \(String(describing: bike.frameModel))")
                Text("Color Primary: \(bike.frameColorPrimary))")
                if let frameColorSecondary = bike.frameColorSecondary {
                    Text("Frame Color Secondary: \(frameColorSecondary))")
                }
                if let frameColorTertiary = bike.frameColorTertiary {
                    Text("Frame Color Tertiary: \(frameColorTertiary))")
                }
                Text("Frame Colors: \(bike.frameColors)")
                Text("Manufacturer Name: \(bike.manufacturerName)")
                if let year = bike.year {
                    Text("Year: \(year))")
                }
                Text("Type Of Cycle: \(bike.typeOfCycle)")
                Text("Type Of Propulsion: \(bike.typeOfPropulsion)")
                if let serial = bike.serial {
                    Text("Serial: \(serial))")
                }
                Text("Status: \(bike.status)")
                if let stolenCoordinates = bike.stolenCoordinates {
                    Text("Stolen Coordinates: \(stolenCoordinates))")
                }
                if let stolenLocation = bike.stolenLocation {
                    Text("Stolen Location: \(stolenLocation))")
                }
                if let dateStolen = bike.dateStolen {
                    Text("Date Stolen: \(dateStolen))")
                }
                if let largeImage = bike.largeImage {
                    Text("Large Image: \(largeImage))")
                }
                if let thumb = bike.thumb {
                    Text("Thumb: \(thumb))")
                }
                Text("Url: \(bike.url)")
                if let apiUrl = bike.apiUrl {
                    Text("Api Url: \(apiUrl))")
                }
                Text("Public Images: \(bike.publicImages)")
                Text("--")
                Text("Created At: \(bike.createdAt)")
                Text("Updated At: \(bike.updatedAt)")
                Text(
                    "Full Public Images: \(bike.fullPublicImages.map { $0.full.absoluteString }.joined())"
                )
            }

            // MARK: - AutocompleteManufacturers
            DataModelDebugView(models: manufacturers) { manufacturer in
                Text("ID: \(manufacturer.identifier)")
                Text("Text: \(manufacturer.text)")
                Text("Category: \(manufacturer.category)")
                Text("Slug: \(manufacturer.slug)")
                Text("Priority: \(manufacturer.priority)")
                Text("Search ID: \(manufacturer.searchId)")
            }
        }
    }
}

struct DataModelDebugView<Model: PersistentModel, Content: View>: View {
    var models: [Model]

    @ViewBuilder
    var content: (Model) -> Content

    var body: some View {
        Section {
            LazyVGrid(columns: Array(repeating: GridItem(), count: 1)) {
                ForEach(models) { item in
                    GridRow {
                        VStack(alignment: .leading) {
                            content(item)
                        }.frame(
                            minWidth: 0,
                            maxWidth: .infinity,
                            minHeight: 0,
                            maxHeight: .infinity,
                            alignment: .topLeading
                        )
                    }
                }
            }
        } header: {
            Text("^[\(models.count) \(Model.displayName)](inflect: true)")
        }
    }
}

#Preview {
    do {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let mockContainer = try ModelContainer(
            for: Bike.self, User.self, AuthenticatedUser.self,
            AutocompleteManufacturer.self, FullPublicImage.self,
            configurations: config
        )

        return DebugDataView()
            .modelContainer(mockContainer)
    } catch {
        return Text(error.localizedDescription)
    }
}

extension PersistentModel {
    public static var displayName: String {
        String(describing: self)
            .titleCase()
    }
}

extension String {
    // Attribution: https://stackoverflow.com/a/50202999/
    func titleCase() -> String {
        return
            self
            .replacingOccurrences(
                of: "([A-Z])",
                with: " $1",
                options: .regularExpression,
                range: range(of: self)
            )
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .capitalized  // If input is in llamaCase
    }
}
#endif
