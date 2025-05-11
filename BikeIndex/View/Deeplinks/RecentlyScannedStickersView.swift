//
//  RecentlyScannedStickersView.swift
//  BikeIndex
//
//  Created by Jack on 5/11/25.
//

import SwiftUI
import SwiftData

struct RecentlyScannedStickersView: View {
    @Query(sort: [SortDescriptor(\ScannedBike.createdAt, order: .reverse)])
    var stickers: [ScannedBike]

    @State var path = NavigationPath()

    @Binding var dismiss: Bool

    var body: some View {
        NavigationStack(path: $path) {
            // Duplicated/repeated scans are allowed but duplicates on ScannedBike.id cause problems for List
            // so we need to de-duplicate List on persistentModelID
            List(stickers, id: \.persistentModelID) { sticker in
                NavigationLink {
                    ScannedBikePage(viewModel: .init(scan: sticker, path: path, dismiss: nil))
                    .interactiveDismissDisabled()
                } label: {
                    HStack {
                        Text("\(sticker.url.lastPathComponent)")
                        Spacer()
                        Text("\(sticker.createdAt, style: .relative)")
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Recently Scanned Stickers")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Dismiss") {
                        // TODO: Refine this inversion because it's very confusing in the current naming.
                        dismiss = false
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable let client = try! Client()

    @Previewable let container = try! ModelContainer(
        for: ScannedBike.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    RecentlyScannedStickersView(dismiss: .constant(true))
        .environment(client)
        .modelContainer(container)
        .onAppear {
            let sampleSticker = ScannedBike(host: client.hostProvider,
                                            url: URL(string: "https://bikeindex.org/bikes/scanned/A40340"))
        }
}
