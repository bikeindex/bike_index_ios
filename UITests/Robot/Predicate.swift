//
//  Predicate.swift
//  BikeIndex
//
//  Created by Milo Wyner on 6/20/25.
//

extension Robot {
    enum Predicate {
        case contains(String)
        case doesNotContain(String)

        case containsValue(Any)
        case doesNotContainValue(Any)

        case exists
        case doesNotExist

        case isEnabled
        case isNotEnabled

        case isHittable
        case isNotHittable

        var format: String {
            switch self {
            case .contains(let label):
                return "label == '\(label)'"
            case .doesNotContain(let label):
                return "label != '\(label)'"
            case .containsValue(let value):
                return "value == '\(value)'"
            case .doesNotContainValue(let value):
                return "value != '\(value)'"
            case .exists:
                return "exists == true"
            case .doesNotExist:
                return "exists == false"
            case .isEnabled:
                return "isEnabled == true"
            case .isNotEnabled:
                return "isEnabled == false"
            case .isHittable:
                return "isHittable == true"
            case .isNotHittable:
                return "isHittable == false"
            }
        }
    }
}
