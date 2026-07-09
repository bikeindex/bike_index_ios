//
//  StickerCenter.swift
//  BikeIndex
//
//  Created by Jack on 5/11/25.
//

import HoneybadgerSwift
import OSLog
import SwiftData
import SwiftUI

struct StickerCenter: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Client.self) private var client
    @Environment(QRStickerRouter.self) private var stickerRouter
    @State var viewModel = ViewModel()

    @Query(sort: [SortDescriptor(\ScannedBike.createdAt, order: .reverse)])
    var stickers: [ScannedBike]

    var body: some View {
        @Bindable var stickerRouter = stickerRouter
        NavigationStack(path: $stickerRouter.path) {
            // Duplicated/repeated scans are allowed
            // but duplicates on ScannedBike.id will cause problems for List
            // so we need to de-duplicate List on persistentModelID
            VStack(spacing: 0) {
                QRCodeCaptureView(recentlyScannedViewModel: viewModel)
                List {
                    Section {
                        ForEach(stickers, id: \.persistentModelID) { sticker in
                            NavigationLink(value: sticker) {
                                StickerDisplayLabel(sticker: sticker)
                            }
                        }
                        .onDelete(perform: delete(indexSet:))
                    }

                    Section {
                        Text("Align the QR sticker in the center of the shield")
                            .font(.callout)
                        TextLink(
                            base: client.hostProvider.host,
                            link: .howToUseStickers
                        )
                        .environment(\.openURL, openHowToPage)
                    } header: {
                        Text("⚠️ Information")

                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("QR Sticker Center")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") {
                        stickerRouter.path = NavigationPath()
                        stickerRouter.displayStickerCenter = false
                    }
                }
            }
            .navigationDestination(isPresented: $stickerRouter.showHowToPage) {
                NavigableWebView(
                    constantLink: .howToUseStickers,
                    host: client.hostProvider.host)
            }
            .navigationDestination(for: ScannedBike.self) { scannedBike in
                ScannedBikePage(
                    viewModel: .init(scan: scannedBike)
                )
            }
        }
        .onAppear {
            Logger.camera.info("[StickerCenter] onAppear \(Date())")
        }
        .onDisappear {
            Logger.camera.info("[StickerCenter] onDisappear \(Date())")
            if stickerRouter.path.isEmpty {
                cleanUp()
            }
        }
    }

    private var openHowToPage: OpenURLAction {
        OpenURLAction { _ in
            stickerRouter.showHowToPage = true
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
            Honeybadger.notify(error: error)
            Logger.model.error(
                "\(type(of: viewModel)) failed to delete sticker \(error, privacy: .private)")
        }
    }

    /// Run a clean up pass when StickerCenter is dismissed.
    /// If the user last scanned stickers outside of the expiration window they will either
    /// be cleaned up here (by way of onDisappear) or at the next scan.
    private func cleanUp() {
        do {
            try viewModel.cleanUpExpiredStickers(context: modelContext)
        } catch {
            Honeybadger.notify(error: error)
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
    static let stickerRouter = QRStickerRouter()

    static var previews: some View {
        StickerCenter()
            .environment(client)
            .environment(stickerRouter)
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
        LabeledContent {
            VStack {
                Text("\(sticker.createdAt, style: .relative)")
                    .foregroundStyle(.primary)
                Spacer()
            }
        } label: {
            VStack(alignment: .leading) {
                Text(sticker.displayTitle)
                    .monospaced()
                    .bold()
                    .foregroundStyle(.white)
                    .frame(maxHeight: .infinity)
                    .background {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .scale(1.15)
                            .fill(.accent)
                    }
                    .padding(.leading, 4)
                Text("Red Jamis")
            }

        }
    }
}
