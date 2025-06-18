//
//  BikeDetailOfflineView.swift
//  BikeIndex
//
//  Created by Jack on 5/26/25.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

struct DetailCell: View {
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .detailTitle()
            Text(subtitle ?? "empty")
        }
        .frame(
            maxWidth: .infinity,
            alignment: .leading
        )
        .padding([.leading, .bottom], 6)
    }
}

struct DetailTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.secondary)
    }
}

extension View {
    public func detailTitle() -> some View {
        modifier(DetailTitleModifier())
    }
}

extension DetailCell {
    init(title: String, subtitle: Int?) {
        self.title = title
        if let subtitle {
            self.subtitle = String(subtitle)
        } else {
            self.subtitle = "empty"
        }
    }
}

/// Display the details for a bike from the local cache.
struct BikeDetailOfflineView: View {
    @Environment(Client.self) var client

    /// Query is only returns arrays and we'll pick the only element.
    @Query private var bikeQuery: [Bike]

    init(bikeIdentifier: Bike.BikeIdentifier) {
        _bikeQuery = Query(
            filter: #Predicate<Bike> { model in
                model.identifier == bikeIdentifier
            })
    }

    private var bike: Bike? {
        return bikeQuery.count == 1 ? bikeQuery.first : nil
    }

    var body: some View {
        if let bike {
            Form {
                ScrollView {
                    Section {
                        if let description = bike.bikeDescription {
                            VStack(alignment: .leading) {
                                Text(description)
                                    .lineLimit(nil)
                                    .multilineTextAlignment(.leading)
                                    .frame(alignment: .topLeading)
                                    .border(.red)
                            }
                            .border(.orange)
                        }
                        DetailCell(
                            title: "Serial Number",
                            subtitle: bike.serial)
                        // TODO: Tap status -> scroll to more details
                        DetailCell(
                            title: "Status",
                            subtitle: bike.statusString)
                        DetailCell(
                            title: "Manufacturer",
                            subtitle: bike.manufacturerName)
                        DetailCell(
                            title: "Frame",
                            subtitle: bike.frameModel)
                        DetailCell(
                            title: "Year",
                            subtitle: bike.year)
                        Text("Frame size")
                        Text("Frame Material")
                        Text("QR Stickers")
                        Text("Created/updated at")
                        // TODO: Change FrameColorsView implementation from circles to labels with tokens, ex: [<GREEN background, white text "green">, <RED background, white text "RED>] to be explicit
                        FrameColorsView(bike: bike)
                    } header: {
                        // TODO: Make BikeDetailHeroPhotos edge-to-edge
                        // TODO: Make BikeDetailHeroPhotos open larger photos full screen
                        BikeDetailHeroPhotos(bike: bike)
                            .shadow(radius: 4, x: 0.5, y: 2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .border(.red)

                        ScrollView(.horizontal) {
                            HStack {
                                Button("Edit Bike", action: {})
                                Button("List for sale", action: {})
                                Button("Mark bike stolen", action: {})
                                Button("Add group or organization", action: {})
                                Button("Transfer ownership", action: {})
                                Button("Hide or delete registration", action: {})
                            }
                            .padding([.leading, .trailing], 8)
                        }
                        .scrollIndicators(.hidden)
                        .buttonStyle(.bordered)
                    }
                    .frame(alignment: .leading)
                    .headerProminence(.increased)

                    Section {
                        DetailCell(
                            title: "Type",
                            subtitle: bike.typeOfCycle.name)
                        DetailCell(
                            title: "Propulsion",
                            subtitle: bike.typeOfPropulsion.name)
                        Text(bike.largeImage?.absoluteString ?? "large image")
                        Text(bike.publicImages.joined(separator: "\n"))
                    }

                    Section {
                        StolenBikeDetailsView(bike: bike)
                    } footer: {
                        Text("Editing is not available in offline mode.")
                            .font(.caption2)
                    }
                }
            }
            .formStyle(.columns)
            .headerProminence(.increased)

            //            .listStyle(.grouped)
            //            .listStyle(.inset)
            .navigationTitle(bike.title)
        } else {
            ContentUnavailableView(
                "Bike not found",
                systemImage: "questionmark.diamond")
        }
    }

}

#Preview {
    let container = try! ModelContainer(
        for: Bike.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    NavigationStack {
        BikeDetailOfflineView(bikeIdentifier: 20348)
            .environment(try! Client())
            .modelContainer(container)
    }
    .onAppear {
        do {
            let mockResponse = try PreviewData.loadMultipleBikeResponseMock()
            print("Found mock response \(mockResponse)")
            if let responseBike = mockResponse.bikes.first {
                let bike = responseBike.modelInstance()
                bike.publicImages.append(
                    "https://placecats.com/300/200"
                )
                bike.frameColorSecondary = .covered
                bike.frameColorTertiary = .bareMetal
//                bike.frameColorSecondary = .red
//                bike.frameColorTertiary = .teal
                container.mainContext.insert(bike)
                try container.mainContext.save()
            }
        } catch {
            print("Failed to render \(error.localizedDescription)")
        }
    }
}
