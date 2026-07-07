/**
 MIT License - Copyright © 2026 YouForge
 Distributed at https://github.com/YouForge/SwiftUI-Barcode-Scanner-Concurrency
 Adapated for QR scanning
 */

@preconcurrency import AVFoundation
import OSLog
import SwiftUI
import Vision

/*
/// Reference implementation to utilize BarcodeScannerView
struct ContentView: View {
    @State private var scannerViewModel = BarcodeScannerViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            BarcodeScannerView(session: scannerViewModel.session)
                .ignoresSafeArea()
                .task {
                    await scannerViewModel.start()
                }

            Text(scannerViewModel.scannedCode ?? "Scan a code")
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding()
        }
    }
}
 */

struct BarcodeScannerView: UIViewRepresentable {
    let session: AVCaptureSession

    func makeUIView(context: Context) -> PreviewView {
        let view = PreviewView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}
}

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }

    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
}

@MainActor
@Observable
class BarcodeScannerViewModel {
    private(set) var isRunning = false
    private(set) var scannedCode: String?
    private(set) var error: Error?
    private var stringListener: Task<Void, Never>?

    private let captureService = BarcodeScannerCaptureService()
    var session: AVCaptureSession { captureService.captureSession }

    func start() async {
        do {
            try await captureService.start()
            isRunning = true
            scannedStringListener()
        } catch {
            self.error = error
            Logger.camera.debug("\(type(of: self)).\(#function) failed, due to error")
        }
    }

    func stop() async {
        stringListener?.cancel()
        await captureService.stop()
        isRunning = false
    }

    private func scannedStringListener() {
        stringListener = Task {
            guard let scannedStringStream = await captureService.scannedStringStream else { return }
            for await codeString in scannedStringStream {
                scannedCode = codeString
            }
        }
    }
}

actor BarcodeScannerCaptureService {
    nonisolated let captureSession = AVCaptureSession()
    private var outputSampleDelegate = OutputSampleDelegate()
    var scannedStringStream: AsyncStream<String>?

    private let videoQueue = DispatchQueue(label: "videoQueue", qos: .userInteractive)
    private let sessionQueue = DispatchSerialQueue(label: "sessionQueue", qos: .userInteractive)

    nonisolated var unownedExecutor: UnownedSerialExecutor {
        sessionQueue.asUnownedSerialExecutor()
    }

    func start() async throws {
        captureSession.beginConfiguration()
        if captureSession.inputs.count == 1 {
            Logger.camera.debug("Video input already added, resuming")
        } else if let videoCaptureDevice = AVCaptureDevice.default(for: .video),
            let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
            captureSession.canAddInput(videoInput)
        {
            captureSession.addInput(videoInput)
        } else {
            Logger.camera.debug("\(type(of: self)).\(#function) failed, could not add video input")
            return
        }

        scannedStringStream = outputSampleDelegate.scannedStringStream

        let videoOutput = AVCaptureVideoDataOutput()
        if captureSession.canAddOutput(videoOutput) {
            videoOutput.setSampleBufferDelegate(outputSampleDelegate, queue: self.videoQueue)
            captureSession.addOutput(videoOutput)
        }

        captureSession.commitConfiguration()
        Logger.camera.debug(
            "\(type(of: self)).\(#function) completed configuration, will call startRunning")
        captureSession.startRunning()
    }

    func stop() {
        if captureSession.isRunning {
            let inputs = Array(captureSession.inputs)
            let outputs = Array(captureSession.outputs)
            for input in inputs { captureSession.removeInput(input) }
            for output in outputs { captureSession.removeOutput(output) }
            captureSession.stopRunning()
        }
        scannedStringStream = nil
        outputSampleDelegate.finish()
        outputSampleDelegate = OutputSampleDelegate()
    }

    private class OutputSampleDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        let scannedStringStream: AsyncStream<String>
        private let continuation: AsyncStream<String>.Continuation

        override init() {
            let (stream, continuation) = AsyncStream.makeStream(
                of: String.self, bufferingPolicy: .bufferingOldest(1))
            self.scannedStringStream = stream
            self.continuation = continuation
        }

        func finish() {
            continuation.finish()
        }

        func captureOutput(
            _ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer,
            from connection: AVCaptureConnection
        ) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                Logger.camera.debug(
                    "\(type(of: self)).\(#function) failed, could not create pixel buffer from sample buffer"
                )
                return
            }

            self.detectBarcode(in: pixelBuffer)
        }

        private func detectBarcode(in pixelBuffer: CVPixelBuffer) {
            let request = VNDetectBarcodesRequest()

            /*

             Use the following line to restrict the type of symbologies (scannable code types)
             that the scanner will detect

             request.symbologies = [.qr, .ean13, .code128]

             Scannable symbologies are as follows

             1D Barcodes:
             codabar, code128, code39, code39CheckSum, code39FullASCII, code39FullASCIIChecksum, code93, code93i, i2of5, i2of5Checksum, msiPlessey, upce

             2D Barcodes:
             aztec, dataMatrix, microPDF417, microQR, pdf417, qr

             Product Codes:
             ean13, ean8, gs1DataBar, gs1DataBarExpanded, gs1DataBarLimited, itf14
             */

            request.symbologies = [.qr, .microQR]

            let handler = VNImageRequestHandler(
                cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])

            do {
                try handler.perform([request])
                if let results = request.results, let payload = results.first?.payloadStringValue {
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                    continuation.yield(payload)
                    print("OutputSampleDelegate.detectBarcode yielded payload: \(payload)")
                }
            } catch {
                print("Barcode detection failed: \(error)")
            }
        }
    }
}

/*

 Uncomment this section to display SwiftUI preview

 #Preview {
     ContentView()
 }
 */
