//
//  RecentlyScannedStickersView.swift
//  BikeIndex
//
//  Created by Jack on 5/11/25.
//

import OSLog
import SwiftData
import SwiftUI

struct RecentlyScannedStickersView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Client.self) private var client
    var viewModel = ViewModel()

    @Query(sort: [SortDescriptor(\ScannedBike.createdAt, order: .reverse)])
    var stickers: [ScannedBike]

    @State var path = NavigationPath()
    @State var showHowToPage = false
    /// Control the presentation of this view.
    @Binding var display: Bool

    var body: some View {
        NavigationStack(path: $path) {
            // Duplicated/repeated scans are allowed
            // but duplicates on ScannedBike.id will cause problems for List
            // so we need to de-duplicate List on persistentModelID
            List {
                Section {
                    ForEach(stickers, id: \.persistentModelID) { sticker in
                        NavigationLink {
                            ScannedBikePage(
                                viewModel: .init(scan: sticker, path: path, dismiss: nil)
                            )
                            .interactiveDismissDisabled()
                        } label: {
                            StickerDisplayLabel(sticker: sticker)
                        }
                    }
                    .onDelete(perform: delete(indexSet:))
                } footer: {
                    TextLink(
                        base: client.hostProvider.host,
                        link: .howToUseStickers
                    )
                    .environment(\.openURL, openHowToPage)
                }
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
            .navigationDestination(isPresented: $showHowToPage) {
                NavigableWebView(
                    constantLink: .howToUseStickers,
                    host: client.hostProvider.host)
            }
        }
        .onDisappear {
            cleanUp()
        }
    }

    private var openHowToPage: OpenURLAction {
        OpenURLAction { _ in
            showHowToPage = true
            return .handled
        }
    }

    private func delete(indexSet: IndexSet) {
        let stickersToDelete = indexSet.map { stickers[$0] }
        do {
            try viewModel.delete(
                context: modelContext,
                stickers: stickersToDelete)
        } catch {
            Logger.model.error(
                "\(type(of: viewModel)) failed to delete sticker \(error, privacy: .private)")
        }
    }

    /// Run a clean up pass when RecentlyScannedStickersView is dismissed.
    /// If the user last scanned stickers outside of the expiration window they will either
    /// be cleaned up here (by way of onDisappear) or at the next scan.
    private func cleanUp() {
        do {
            try viewModel.cleanUpExpiredStickers(context: modelContext)
        } catch {
            Logger.model.error(
                "Failed to run regular sticker model clean-up. \(error, privacy: .private)"
            )
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
