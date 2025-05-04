//
//  BikeRegistration+Propulsion.swift
//  BikeIndex
//
//  Created by Jack on 4/7/24.
//

import Foundation

extension BikeRegistration {
    /// Track View state with validation. This model should be composed with BikeRegistration and reduce the complexity in ``Bike`` and ``BikeRegistration``.
    /// Used by BikeRegistration to POST to API endpoints
    struct Propulsion {

        /// ``hasThrottle`` and ``hasPedalAssist`` can only be true when ``isElectric`` is true.
        var isElectric: Bool = false {
            didSet {
                if isElectric == false {
                    hasThrottle = false
                    hasPedalAssist = false
                }
            }
        }

        var hasThrottle: Bool = false {
            didSet {
                if !isElectric {
                    hasThrottle = false
                }
            }
        }

        var hasPedalAssist: Bool = false {
            didSet {
                if !isElectric {
                    hasPedalAssist = false
                }
            }
        }

        // MARK: -

        init(isElectric: Bool = false, hasThrottle: Bool = false, hasPedalAssist: Bool = false) {
            self.isElectric = isElectric
            if isElectric {
                self.hasThrottle = hasThrottle
                self.hasPedalAssist = hasPedalAssist
            } else {
                self.hasThrottle = false
                self.hasPedalAssist = false
            }
        }
    }
}
