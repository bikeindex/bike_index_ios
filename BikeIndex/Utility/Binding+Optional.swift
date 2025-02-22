//
//  Binding+Optional.swift
//  BikeIndex
//
//  Created by Jack on 12/28/23.
//

import SwiftUI

/// Via https://stackoverflow.com/a/72291242/178805
extension Binding where Value: Equatable {
    public init(_ source: Binding<Value?>, replacingNilWith nilProxy: Value) {
        self.init(
            get: { source.wrappedValue ?? nilProxy },
            set: { newValue in
                if newValue == nilProxy {
                    source.wrappedValue = nil
                } else {
                    source.wrappedValue = newValue
                }
            }
        )
    }
}
