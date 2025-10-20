//
//  CameraPresenter.swift
//  BikeIndex
//
//  Created by Milo Wyner on 10/9/25.
//

import SwiftUI

/// A ViewModifier that presents a ``CameraImagePicker``. Should only be used by ``camera(isPresented:photo:)``.
struct CameraPresenter: ViewModifier {
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

@MainActor
private let deviceCanCapturePhotos =
    (UIImagePickerController.availableCaptureModes(for: .rear) ?? [])
    .map { UIImagePickerController.CameraCaptureMode(rawValue: Int(truncating: $0)) }
    .contains(.photo)
