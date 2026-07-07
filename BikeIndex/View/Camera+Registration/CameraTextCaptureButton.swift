//
//  CameraTextCaptureButton.swift
//  BikeIndex
//
//  Created by Jack on 4/13/24.
//

import SwiftUI
import UIKit

struct CameraTextCaptureButton: UIViewRepresentable {
    typealias UIViewType = UIButton

    @Binding var text: String

    func makeUIView(context: Context) -> UIViewType {
        let captureTextAction = UIAction.captureTextFromCamera(
            responder: context.coordinator,
            identifier: nil
        )
        // For more padding consistency with other Labels in Form views
        var configuration = UIButton.Configuration.plain()
        configuration.imagePadding = 8
        configuration.contentInsets = .init(top: 0, leading: -2, bottom: 0, trailing: 0)
        configuration.background.cornerRadius = 0
        return UIButton(configuration: configuration, primaryAction: captureTextAction)
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
        let parent: CameraTextCaptureButton

        init(_ parent: CameraTextCaptureButton) {
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
