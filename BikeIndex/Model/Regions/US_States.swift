//
//  States.swift
//  BikeIndex
//
//  Created by Jack on 12/28/23.
//

import Foundation

enum US_States: String, CaseIterable, Identifiable {
    typealias Abbreviation = String

    var id: String { self.rawValue }

    case al = "Alabama"
    case ak = "Alaska"
    case az = "Arizona"
    case ar = "Arkansas"
    case ca = "California"
    case co = "Colorado"
    case ct = "Connecticut"
    case de = "Delaware"
    case dc = "District of Columbia"
    case fl = "Florida"
    case ga = "Georgia"
    case hi = "Hawaii"
    case id = "Idaho"
    case il = "Illinois"
    case `in` = "Indiana"
    case ia = "Iowa"
    case ks = "Kansas"
    case ky = "Kentucky"
    case la = "Louisiana"
    case me = "Maine"
    case md = "Maryland"
    case ma = "Massachusetts"
    case mi = "Michigan"
    case mn = "Minnesota"
    case ms = "Mississippi"
    case mo = "Missouri"
    case mt = "Montana"
    case ne = "Nebraska"
    case nv = "Nevada"
    case nh = "New Hampshire"
    case nj = "New Jersey"
    case nm = "New Mexico"
    case ny = "New York"
    case nc = "North Carolina"
    case nd = "North Dakota"
    case oh = "Ohio"
    case ok = "Oklahoma"
    case or = "Oregon"
    case pa = "Pennsylvania"
    case pr = "Puerto Rico"
    case ri = "Rhode Island"
    case sc = "South Carolina"
    case sd = "South Dakota"
    case tn = "Tennessee"
    case tx = "Texas"
    case ut = "Utah"
    case vt = "Vermont"
    case va = "Virginia"
    case wa = "Washington"
    case wv = "West Virginia"
    case wi = "Wisconsin"
    case wy = "Wyoming"

    var abbreviation: Abbreviation {
        switch self {
        case .al:
            return "AL"
        case .ak:
            return "AK"
        case .az:
            return "AZ"
        case .ar:
            return "AR"
        case .ca:
            return "CA"
        case .co:
            return "CO"
        case .ct:
            return "CT"
        case .de:
            return "DE"
        case .dc:
            return "DC"
        case .fl:
            return "FL"
        case .ga:
            return "GA"
        case .hi:
            return "HI"
        case .id:
            return "ID"
        case .il:
            return "IL"
        case .in:
            return "IN"
        case .ia:
            return "IA"
        case .ks:
            return "KS"
        case .ky:
            return "KY"
        case .la:
            return "LA"
        case .me:
            return "ME"
        case .md:
            return "MD"
        case .ma:
            return "MA"
        case .mi:
            return "MI"
        case .mn:
            return "MN"
        case .ms:
            return "MS"
        case .mo:
            return "MO"
        case .mt:
            return "MT"
        case .ne:
            return "NE"
        case .nv:
            return "NV"
        case .nh:
            return "NH"
        case .nj:
            return "NJ"
        case .nm:
            return "NM"
        case .ny:
            return "NY"
        case .nc:
            return "NC"
        case .nd:
            return "ND"
        case .oh:
            return "OH"
        case .ok:
            return "OK"
        case .or:
            return "OR"
        case .pa:
            return "PA"
        case .pr:
            return "PR"
        case .ri:
            return "RI"
        case .sc:
            return "SC"
        case .sd:
            return "SD"
        case .tn:
            return "TN"
        case .tx:
            return "TX"
        case .ut:
            return "UT"
        case .vt:
            return "VT"
        case .va:
            return "VA"
        case .wa:
            return "WA"
        case .wv:
            return "WV"
        case .wi:
            return "WI"
        case .wy:
            return "WY"
        }
    }
}
