//
//  CameraCaptureButton.swift
//  BikeIndex
//
//  Created by Jack on 4/13/24.
//

import SwiftUI
import UIKit

struct CameraCaptureButton: UIViewRepresentable {
    typealias UIViewType = UIButton

    @Binding var text: String

    func makeUIView(context: Context) -> UIViewType {
        let captureTextAction = UIAction.captureTextFromCamera(
            responder: context.coordinator,
            identifier: nil
        )
        return UIButton(primaryAction: captureTextAction)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UIButton, context: Context) -> CGSize? {
        uiView.intrinsicContentSize
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {}

    // MARK: - UIKit bridging

    func makeCoordinator() -> KeyInputCoordinator {
        KeyInputCoordinator(self)
    }

    class KeyInputCoordinator: UIResponder, UIKeyInput {
        let parent: CameraCaptureButton

        init(_ parent: CameraCaptureButton) {
            self.parent = parent
        }

        var hasText = false

        func insertText(_ text: String) {
            parent.text = text
        }

        func deleteBackward() {
        }
    }
}
