//
//  AddBikeOutput.swift
//  BikeIndex
//
//  Created by Jack on 12/10/23.
//

import Foundation
import SwiftUI

/// Capture context for alerts after network operations fail or succeed when tapping Register in ``RegisterBikeView``.
@Observable final class AddBikeOutput {
    var show: Bool = false
    private(set) var actions: () -> Void = {}
    private(set) var message: LocalizedStringKey = ""
    private(set) var title: LocalizedStringKey = ""

    init() {

    }

    init(
        show: Bool, actions: @escaping () -> Void, message: LocalizedStringKey,
        title: LocalizedStringKey
    ) {
        self.show = show
        self.actions = actions
        self.message = message
        self.title = title
    }
}
