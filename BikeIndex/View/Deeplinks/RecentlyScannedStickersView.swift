//
//  RecentlyScannedStickersView.swift
//  BikeIndex
//
//  Created by Jack on 5/11/25.
//

import SwiftData
import SwiftUI

struct RecentlyScannedStickersView: View {
    @Environment(\.modelContext) private var modelContext
    var scannedBikesViewModel = ScannedBikesViewModel()

    @Query(sort: [SortDescriptor(\ScannedBike.createdAt, order: .reverse)])
    var stickers: [ScannedBike]

    @State var path = NavigationPath()

    @Binding var display: Bool

    var body: some View {
        NavigationStack(path: $path) {
            // Duplicated/repeated scans are allowed but duplicates on ScannedBike.id cause problems for List
            // so we need to de-duplicate List on persistentModelID
            List {
                ForEach(stickers, id: \.persistentModelID) { sticker in
                    NavigationLink {
                        ScannedBikePage(viewModel: .init(scan: sticker, path: path, dismiss: nil))
                            .interactiveDismissDisabled()
                    } label: {
                        StickerDisplayLabel(sticker: sticker)
                    }
                }
                .onDelete(perform: delete(indexSet:))
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Recently Scanned Stickers")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        display = false
                    }
                }
            }
        }
    }

    private func delete(indexSet: IndexSet) {
        let stickersToDelete = indexSet.map { stickers[$0] }
        do {
            try scannedBikesViewModel.delete(context: modelContext,
                                             stickers: stickersToDelete)
        } catch {
            
        }
    }
}

struct RecentlyScannedPreview: PreviewProvider {
    static let container = try! ModelContainer(
        for: ScannedBike.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true))

    static var client = try! Client()

    static var previews: some View {
        RecentlyScannedStickersView(display: .constant(true))
            .environment(client)
            .modelContainer(container)
            .onAppear {
                for identifier in ["SAM000000", "A40340", "NONMATCH"] {
                    if let sampleSticker = ScannedBike(
                        host: client.hostProvider,
                        url: URL(string: "https://bikeindex.org/bikes/scanned/\(identifier)"))
                    {
                        container.mainContext.insert(sampleSticker)
                    }
                }

                try! container.mainContext.save()
            }
    }
}

struct StickerDisplayLabel: View {
    var sticker: ScannedBike

    var body: some View {
        HStack {
            Text(sticker.displayTitle)
                .monospaced()
                .bold()
                .foregroundStyle(.white)
                .background {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .scale(1.15)
                        .fill(.accent)
                }
                .padding(.leading, 2)

            Spacer()
            Text("\(sticker.createdAt, style: .relative)")
        }
    }
}
