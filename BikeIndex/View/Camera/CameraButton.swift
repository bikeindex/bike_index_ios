//
//  ImagePicker.swift
//  BikeIndex
//
//  Created by Milo Wyner on 10/2/25.
//

import SwiftUI
import UIKit

/// A button that displays the camera for taking photos.
struct CameraButton<Label>: View where Label: View {
    @Binding var photo: UIImage?
    let label: Label

    @State private var cameraIsPresented = false

    init(photo: Binding<UIImage?>, @ViewBuilder label: () -> Label) {
        self._photo = photo
        self.label = label()
    }

    var body: some View {
        Button {
            cameraIsPresented = true
        } label: {
            label
        }
        .camera(isPresented: $cameraIsPresented, photo: $photo)
    }
}

#Preview {
    CameraButton(photo: .constant(nil)) {
        Label("Camera", systemImage: "camera")
    }
}

extension View {
    /// Presents the camera for taking photos.
    func camera(isPresented: Binding<Bool>, photo: Binding<UIImage?>) -> some View {
        modifier(CameraPresenter(isPresented: isPresented, photo: photo))
    }
}

private struct CameraPresenter: ViewModifier {
    @Binding var isPresented: Bool
    @Binding var photo: UIImage?

    func body(content: Content) -> some View {
        if deviceCanCapturePhotos {
            content
                .fullScreenCover(isPresented: $isPresented) {
                    CameraImagePicker(image: $photo)
                        .ignoresSafeArea()
                }
        } else {
            content
        }
    }
}

private struct CameraImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        picker.sourceType = .camera
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraImagePicker

        init(_ parent: CameraImagePicker) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let image = info[.editedImage] as? UIImage {
                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

@MainActor
private let deviceCanCapturePhotos =
    (UIImagePickerController.availableCaptureModes(for: .rear) ?? [])
    .map { UIImagePickerController.CameraCaptureMode(rawValue: Int(truncating: $0)) }
    .contains(.photo)
