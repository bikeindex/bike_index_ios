//
//  View+Camera.swift
//  BikeIndex
//
//  Created by Milo Wyner on 10/9/25.
//

import SwiftUI

extension View {
    /// Presents the camera for taking photos. Using ``CameraButton`` is recommended if programmatic presentation isn't needed.
    func camera(isPresented: Binding<Bool>, photo: Binding<UIImage?>) -> some View {
        modifier(CameraPresenter(isPresented: isPresented, photo: photo))
    }
}
