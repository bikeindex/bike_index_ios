//
//  QRCodeCaptureView.swift
//  BikeIndex
//
//  Created by Jack on 5/31/26.
//

import AVFoundation
import HoneybadgerSwift
import OSLog
import SwiftUI

/// A view that displays a camera preview and scans for QR codes in the camera feed.
/// When a QR code matching a Bike Index sticker URL is detected, the scan is persisted
/// via the ``DeeplinkManager`` and the sticker page is displayed over the camera.
struct QRCodeCaptureView: View {
    @Environment(Client.self) var client
    @Environment(\.modelContext) private var modelContext
    @Environment(QRStickerRouter.self) var stickerRouter
    var recentlyScannedViewModel: StickerCenter.ViewModel
    @State private var scannerViewModel = BarcodeScannerViewModel()

    var body: some View {
        BarcodeScannerView(session: scannerViewModel.session)
            .ignoresSafeArea()
            .onAppear {
                Logger.camera.info("[QRCodeCaptureView] onAppear \(Date())")
                if stickerRouter.path.isEmpty && !scannerViewModel.isRunning {
                    Task { await scannerViewModel.start() }
                    Logger.camera.info(
                        "[QRCodeCaptureView] onAppear — path is empty & not running, starting camera"
                    )
                } else if stickerRouter.path.isEmpty {
                    Logger.camera.info(
                        "[QRCodeCaptureView] onAppear — already running at root (path='\(String(describing: stickerRouter.path))'), skipping start"
                    )
                } else {
                    Logger.camera.info(
                        "[QRCodeCaptureView] onAppear — path is '\(String(describing: stickerRouter.path))' (root), waiting for onChange to start"
                    )
                }
            }
            .onChange(
                of: stickerRouter.path,
                { oldPath, newPath in
                    if oldPath.isEmpty && !newPath.isEmpty {
                        if scannerViewModel.isRunning {
                            Logger.camera.info(
                                "[QRCodeCaptureView] path → \(String(describing: newPath)), stopping camera (was running)"
                            )
                            Task { await scannerViewModel.stop() }
                        } else {
                            Logger.camera.info(
                                "[QRCodeCaptureView] path → \(String(describing: newPath)), skipping stop (already stopped)"
                            )
                        }
                    } else if !oldPath.isEmpty && newPath.isEmpty {
                        if !scannerViewModel.isRunning {
                            Logger.camera.info(
                                "[QRCodeCaptureView] path cleared, starting camera (was not running)"
                            )
                            Task { await scannerViewModel.start() }
                        } else {
                            Logger.camera.info(
                                "[QRCodeCaptureView] path cleared, skipping start (already running at \(Date()))"
                            )
                        }
                    }
                }
            )
            .onChange(
                of: scannerViewModel.scannedCode,
                { oldValue, newValue in
                    Logger.camera.info(
                        "[QRCodeCaptureView] scannedCode changed: \(oldValue ?? "nil") -> \(newValue ?? "nil")"
                    )
                    if let newValue, stickerRouter.path.isEmpty {
                        didScan(code: newValue)
                    } else if let newValue {
                        Logger.camera.info(
                            "[QRCodeCaptureView] scannedCode → \(String(describing: newValue)), skipping (path is '\(String(describing: stickerRouter.path))', not at root)"
                        )
                    }
                }
            )
            .overlay {
                /// Information text is displayed by parent view StickerCenter
                CrosshairsOverlay()
            }
    }

    /// Process a scanned QR code: parse sticker URL, persist, and navigate
    func didScan(code: String) {
        Logger.camera.info("[QRCodeCaptureView.didScan] start: \(code)")
        let stickerParser = StickerParser(host: client.hostProvider)
        guard let scannedBike = stickerParser.parse(code: code) else {
            Logger.deeplinks.error("[QRCodeCaptureView.didScan] StickerParser failed: \(code)")
            return
        }

        do {
            let persistedSticker = try recentlyScannedViewModel.persist(
                context: modelContext, sticker: scannedBike)
            Logger.camera.info(
                "[QRCodeCaptureView.didScan] persist success: \(persistedSticker.id)"
            )
            stickerRouter.scanUniversalLink(persistedSticker)
        } catch {
            Honeybadger.notify(error: error, qrSticker: code)
            Logger.deeplinks.error(
                "[QRCodeCaptureView.didScan] persist failed: \(code, privacy: .public)"
            )
        }
        Logger.camera.info("[QRCodeCaptureView.didScan] complete: \(code, privacy: .public)")

    }
}

struct CrosshairsOverlay: View {
    var body: some View {
        ZStack {
            Image("qr-scanner-crosshair")
                .resizable()
                .aspectRatio(1.0, contentMode: .fill)
                .tint(Color.primary)
                .opacity(0.6)
                .safeAreaPadding(.all)
                .containerRelativeFrame(.vertical, count: 10, span: 1, spacing: 0)
                .containerRelativeFrame(.horizontal, count: 10, span: 1, spacing: 0)

            let lineWidth: CGFloat = 1
            HStack {
                Spacer()
                Rectangle()
                    .foregroundStyle(Color.green)
                    .frame(height: lineWidth)
                    .containerRelativeFrame(.horizontal, count: 4, span: 1, spacing: 0)
                Spacer()
                Rectangle()
                    .foregroundStyle(Color.blue)
                    .frame(height: lineWidth)
                    .containerRelativeFrame(.horizontal, count: 4, span: 1, spacing: 0)
                Spacer()
            }

            VStack {
                Spacer()
                Rectangle()
                    .foregroundStyle(Color.yellow)
                    .frame(width: lineWidth)
                    .containerRelativeFrame(.vertical, count: 8, span: 1, spacing: 0)
                Spacer()
                Rectangle()
                    .foregroundStyle(Color.purple)
                    .frame(width: lineWidth)
                    .containerRelativeFrame(.vertical, count: 8, span: 1, spacing: 0)
                Spacer()
            }
        }

    }
}

#Preview("Crosshairs Overlay") {
    VStack(spacing: 0) {
        Rectangle()
            .ignoresSafeArea()
            .foregroundStyle(.red)
            .overlay {
                CrosshairsOverlay()
            }
        List {

        }
    }
}
