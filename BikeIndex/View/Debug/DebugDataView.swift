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
                Text("Description: \(bike.bikeDescription)")
                Text("Frame Model: \(bike.frameModel)")
                Text("Color Primary: \(String(describing: bike.frameColorPrimary))")
                Text("Frame Color Secondary: \(frameColorSecondary)")
                Text("Frame Color Tertiary: \(frameColorTertiary)")
                Text("Frame Colors: \(frameColors)")
                Text("Manufacturer Name: \(manufacturerName)")
                Text("Year: \(year)")
                Text("Type Of Cycle: \(typeOfCycle)")
                Text("Type Of Propulsion: \(typeOfPropulsion)")
                Text("Serial: \(serial)")
                Text("Status: \(status)")
                Text("Stolen Coordinates: \(stolenCoordinates)")
                Text("Stolen Coordinate Latitude: \(stolenCoordinateLatitude)")
                Text("Stolen Coordinate Longitude: \(stolenCoordinateLongitude)")
                Text("Stolen Location: \(stolenLocation)")
                Text("Date Stolen: \(dateStolen)")
                Text("Large Image: \(largeImage)")
                Text("Thumb: \(thumb)")
                Text("Url: \(url)")
                Text("Api Url: \(apiUrl)")
                Text("Public Images: \(publicImages)")
            }

            // MARK: - Organizations
            DataModelDebugView(models: organizations) { organization in
                Text("Name: \(organization.name)")
                Text("ID: \(organization.identifier)")
                Text("Slug: \(organization.slug)")
                Text("Admin?: \(organization.userIsOrganizationAdmin.description)")
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
            Text("\(models.count) of \(Model.self)")
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
