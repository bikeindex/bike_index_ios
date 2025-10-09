//
//  CameraButton.swift
//  BikeIndex
//
//  Created by Milo Wyner on 10/2/25.
//

import SwiftUI
import UIKit

/// A button that displays the camera for taking photos. Alternatively, use ``camera(isPresented:photo:)`` to display it programmatically.
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
