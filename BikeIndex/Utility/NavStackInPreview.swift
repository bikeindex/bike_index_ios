//
//  NavStackInPreview.swift
//  BikeIndex
//
//  Created by Jack on 3/16/25.
//

import SwiftUI

#if DEBUG
/// Wrap this view's content in two different ways:
/// 1. Previews will use a NavigationView
/// 2. Everywhere else (SnapshotPreviews and Snapshot tests) will use a plain group
/// SnapshotPreviews and its PreviewGallery will hit navigation problems when adding subsequent NavigationStacks
/// so this helper works around that.
struct NavStackInPreview<Preview>: View where Preview: View {
    @ViewBuilder var content: () -> Preview

    var body: some View {
        if ProcessInfo().isRunningPreviews {
            NavigationStack {
                content()
            }
        } else {
            Group {
                content()
            }
        }
    }
}
#endif
