//
//  Countries.swift
//  BikeIndex
//
//  Created by Jack on 12/28/23.
//

import Foundation

enum Countries: String, CaseIterable, Identifiable {
    typealias ISO = String

    var id: String { self.rawValue }

    case af = "Afghanistan"
    case al = "Albania"
    case dz = "Algeria"
    case `as` = "American Samoa"
    case ad = "Andorra"
    case ao = "Angola"
    case ai = "Anguilla"
    case aq = "Antarctica"
    case ag = "Antigua and Barbuda"
    case ar = "Argentina"
    case am = "Armenia"
    case aw = "Aruba"
    case au = "Australia"
    case at = "Austria"
    case az = "Azerbaijan"
    case bs = "Bahamas"
    case bh = "Bahrain"
    case bd = "Bangladesh"
    case bb = "Barbados"
    case by = "Belarus"
    case be = "Belgium"
    case bz = "Belize"
    case bj = "Benin"
    case bm = "Bermuda"
    case bt = "Bhutan"
    case bo = "Bolivia"
    case ba = "Bosnia and Herzegovina"
    case bw = "Botswana"
    case bv = "Bouvet Island"
    case br = "Brazil"
    case io = "British Indian Ocean Territory"
    case bn = "Brunei Darussalam"
    case bg = "Bulgaria"
    case bf = "Burkina Faso"
    case bi = "Burundi"
    case kh = "Cambodia"
    case cm = "Cameroon"
    case ca = "Canada"
    case cv = "Cape Verde"
    case ky = "Cayman Islands"
    case cf = "Central African Republic"
    case td = "Chad"
    case cl = "Chile"
    case cn = "China"
    case cx = "Christmas Island"
    case cc = "Cocos (Keeling) Islands"
    case co = "Colombia"
    case km = "Comoros"
    case cg = "Congo"
    case cd = "Congo, The Democratic Republic of The"
    case ck = "Cook Islands"
    case cr = "Costa Rica"
    case ci = "Cote D'ivoire"
    case hr = "Croatia"
    case cu = "Cuba"
    case cy = "Cyprus"
    case cz = "Czech Republic"
    case dk = "Denmark"
    case dj = "Djibouti"
    case dm = "Dominica"
    case `do` = "Dominican Republic"
    case ec = "Ecuador"
    case eg = "Egypt"
    case sv = "El Salvador"
    case gq = "Equatorial Guinea"
    case er = "Eritrea"
    case ee = "Estonia"
    case et = "Ethiopia"
    case fk = "Falkland Islands (Malvinas"
    case fo = "Faroe Islands"
    case fj = "Fiji"
    case fi = "Finland"
    case fr = "France"
    case gf = "French Guiana"
    case pf = "French Polynesia"
    case tf = "French Southern Territories"
    case ga = "Gabon"
    case gm = "Gambia"
    case ge = "Georgia"
    case de = "Germany"
    case gh = "Ghana"
    case gi = "Gibraltar"
    case gr = "Greece"
    case gl = "Greenland"
    case gd = "Grenada"
    case gp = "Guadeloupe"
    case gu = "Guam"
    case gt = "Guatemala"
    case gg = "Guernsey"
    case gn = "Guinea"
    case gw = "Guinea-bissau"
    case gy = "Guyana"
    case ht = "Haiti"
    case hm = "Heard Island and Mcdonald Islands"
    case va = "Holy See (Vatican City State"
    case hn = "Honduras"
    case hk = "Hong Kong"
    case hu = "Hungary"
    case `is` = "Iceland"
    case `in` = "India"
    case id = "Indonesia"
    case ir = "Iran, Islamic Republic of"
    case iq = "Iraq"
    case ie = "Ireland"
    case im = "Isle of Man"
    case il = "Israel"
    case it = "Italy"
    case jm = "Jamaica"
    case jp = "Japan"
    case je = "Jersey"
    case jo = "Jordan"
    case kz = "Kazakhstan"
    case ke = "Kenya"
    case ki = "Kiribati"
    case kp = "Korea, Democratic People's Republic of"
    case kr = "Korea, Republic of"
    case kw = "Kuwait"
    case kg = "Kyrgyzstan"
    case la = "Lao People's Democratic Republic"
    case lv = "Latvia"
    case lb = "Lebanon"
    case ls = "Lesotho"
    case lr = "Liberia"
    case ly = "Libyan Arab Jamahiriya"
    case li = "Liechtenstein"
    case lt = "Lithuania"
    case lu = "Luxembourg"
    case mo = "Macao"
    case mk = "Macedonia, The Former Yugoslav Republic of"
    case mg = "Madagascar"
    case mw = "Malawi"
    case my = "Malaysia"
    case mv = "Maldives"
    case ml = "Mali"
    case mt = "Malta"
    case mh = "Marshall Islands"
    case mq = "Martinique"
    case mr = "Mauritania"
    case mu = "Mauritius"
    case yt = "Mayotte"
    case mx = "Mexico"
    case fm = "Micronesia, Federated States of"
    case md = "Moldova, Republic of"
    case mc = "Monaco"
    case mn = "Mongolia"
    case me = "Montenegro"
    case ms = "Montserrat"
    case ma = "Morocco"
    case mz = "Mozambique"
    case mm = "Myanmar"
    case na = "Namibia"
    case nr = "Nauru"
    case np = "Nepal"
    case nl = "Netherlands"
    case an = "Netherlands Antilles"
    case nc = "New Caledonia"
    case nz = "New Zealand"
    case ni = "Nicaragua"
    case ne = "Niger"
    case ng = "Nigeria"
    case nu = "Niue"
    case nf = "Norfolk Island"
    case mp = "Northern Mariana Islands"
    case no = "Norway"
    case om = "Oman"
    case pk = "Pakistan"
    case pw = "Palau"
    case ps = "Palestinian Territory, Occupied"
    case pa = "Panama"
    case pg = "Papua New Guinea"
    case py = "Paraguay"
    case pe = "Peru"
    case ph = "Philippines"
    case pn = "Pitcairn"
    case pl = "Poland"
    case pt = "Portugal"
    case pr = "Puerto Rico"
    case qa = "Qatar"
    case re = "Reunion"
    case ro = "Romania"
    case ru = "Russian Federation"
    case rw = "Rwanda"
    case sh = "Saint Helena"
    case kn = "Saint Kitts and Nevis"
    case lc = "Saint Lucia"
    case pm = "Saint Pierre and Miquelon"
    case vc = "Saint Vincent and The Grenadines"
    case ws = "Samoa"
    case sm = "San Marino"
    case st = "Sao Tome and Principe"
    case sa = "Saudi Arabia"
    case sn = "Senegal"
    case rs = "Serbia"
    case sc = "Seychelles"
    case sl = "Sierra Leone"
    case sg = "Singapore"
    case sk = "Slovakia"
    case si = "Slovenia"
    case sb = "Solomon Islands"
    case so = "Somalia"
    case za = "South Africa"
    case gs = "South Georgia and The South Sandwich Islands"
    case es = "Spain"
    case lk = "Sri Lanka"
    case sd = "Sudan"
    case sr = "Suriname"
    case sj = "Svalbard and Jan Mayen"
    case sz = "Swaziland"
    case se = "Sweden"
    case ch = "Switzerland"
    case sy = "Syrian Arab Republic"
    case tw = "Taiwan, Province of China"
    case tj = "Tajikistan"
    case tz = "Tanzania, United Republic of"
    case th = "Thailand"
    case tl = "Timor-leste"
    case tg = "Togo"
    case tk = "Tokelau"
    case to = "Tonga"
    case tt = "Trinidad and Tobago"
    case tn = "Tunisia"
    case tr = "Turkey"
    case tm = "Turkmenistan"
    case tc = "Turks and Caicos Islands"
    case tv = "Tuvalu"
    case ug = "Uganda"
    case ua = "Ukraine"
    case ae = "United Arab Emirates"
    case gb = "United Kingdom"
    case us = "United States"
    case um = "United States Minor Outlying Islands"
    case uy = "Uruguay"
    case uz = "Uzbekistan"
    case vu = "Vanuatu"
    case ve = "Venezuela"
    case vn = "Viet Nam"
    case vg = "Virgin Islands, British"
    case vi = "Virgin Islands, U.S"
    case wf = "Wallis and Futuna"
    case eh = "Western Sahara"
    case ye = "Yemen"
    case zm = "Zambia"
    case zw = "Zimbabwe"

    var isoCode: ISO {
        switch self {
        case .af:
            return "AF"
        case .al:
            return "AL"
        case .dz:
            return "DZ"
        case .as:
            return "AS"
        case .ad:
            return "AD"
        case .ao:
            return "AO"
        case .ai:
            return "AI"
        case .aq:
            return "AQ"
        case .ag:
            return "AG"
        case .ar:
            return "AR"
        case .am:
            return "AM"
        case .aw:
            return "AW"
        case .au:
            return "AU"
        case .at:
            return "AT"
        case .az:
            return "AZ"
        case .bs:
            return "BS"
        case .bh:
            return "BH"
        case .bd:
            return "BD"
        case .bb:
            return "BB"
        case .by:
            return "BY"
        case .be:
            return "BE"
        case .bz:
            return "BZ"
        case .bj:
            return "BJ"
        case .bm:
            return "BM"
        case .bt:
            return "BT"
        case .bo:
            return "BO"
        case .ba:
            return "BA"
        case .bw:
            return "BW"
        case .bv:
            return "BV"
        case .br:
            return "BR"
        case .io:
            return "IO"
        case .bn:
            return "BN"
        case .bg:
            return "BG"
        case .bf:
            return "BF"
        case .bi:
            return "BI"
        case .kh:
            return "KH"
        case .cm:
            return "CM"
        case .ca:
            return "CA"
        case .cv:
            return "CV"
        case .ky:
            return "KY"
        case .cf:
            return "CF"
        case .td:
            return "TD"
        case .cl:
            return "CL"
        case .cn:
            return "CN"
        case .cx:
            return "CX"
        case .cc:
            return "CC"
        case .co:
            return "CO"
        case .km:
            return "KM"
        case .cg:
            return "CG"
        case .cd:
            return "CD"
        case .ck:
            return "CK"
        case .cr:
            return "CR"
        case .ci:
            return "CI"
        case .hr:
            return "HR"
        case .cu:
            return "CU"
        case .cy:
            return "CY"
        case .cz:
            return "CZ"
        case .dk:
            return "DK"
        case .dj:
            return "DJ"
        case .dm:
            return "DM"
        case .do:
            return "DO"
        case .ec:
            return "EC"
        case .eg:
            return "EG"
        case .sv:
            return "SV"
        case .gq:
            return "GQ"
        case .er:
            return "ER"
        case .ee:
            return "EE"
        case .et:
            return "ET"
        case .fk:
            return "FK"
        case .fo:
            return "FO"
        case .fj:
            return "FJ"
        case .fi:
            return "FI"
        case .fr:
            return "FR"
        case .gf:
            return "GF"
        case .pf:
            return "PF"
        case .tf:
            return "TF"
        case .ga:
            return "GA"
        case .gm:
            return "GM"
        case .ge:
            return "GE"
        case .de:
            return "DE"
        case .gh:
            return "GH"
        case .gi:
            return "GI"
        case .gr:
            return "GR"
        case .gl:
            return "GL"
        case .gd:
            return "GD"
        case .gp:
            return "GP"
        case .gu:
            return "GU"
        case .gt:
            return "GT"
        case .gg:
            return "GG"
        case .gn:
            return "GN"
        case .gw:
            return "GW"
        case .gy:
            return "GY"
        case .ht:
            return "HT"
        case .hm:
            return "HM"
        case .va:
            return "VA"
        case .hn:
            return "HN"
        case .hk:
            return "HK"
        case .hu:
            return "HU"
        case .is:
            return "IS"
        case .in:
            return "IN"
        case .id:
            return "ID"
        case .ir:
            return "IR"
        case .iq:
            return "IQ"
        case .ie:
            return "IE"
        case .im:
            return "IM"
        case .il:
            return "IL"
        case .it:
            return "IT"
        case .jm:
            return "JM"
        case .jp:
            return "JP"
        case .je:
            return "JE"
        case .jo:
            return "JO"
        case .kz:
            return "KZ"
        case .ke:
            return "KE"
        case .ki:
            return "KI"
        case .kp:
            return "KP"
        case .kr:
            return "KR"
        case .kw:
            return "KW"
        case .kg:
            return "KG"
        case .la:
            return "LA"
        case .lv:
            return "LV"
        case .lb:
            return "LB"
        case .ls:
            return "LS"
        case .lr:
            return "LR"
        case .ly:
            return "LY"
        case .li:
            return "LI"
        case .lt:
            return "LT"
        case .lu:
            return "LU"
        case .mo:
            return "MO"
        case .mk:
            return "MK"
        case .mg:
            return "MG"
        case .mw:
            return "MW"
        case .my:
            return "MY"
        case .mv:
            return "MV"
        case .ml:
            return "ML"
        case .mt:
            return "MT"
        case .mh:
            return "MH"
        case .mq:
            return "MQ"
        case .mr:
            return "MR"
        case .mu:
            return "MU"
        case .yt:
            return "YT"
        case .mx:
            return "MX"
        case .fm:
            return "FM"
        case .md:
            return "MD"
        case .mc:
            return "MC"
        case .mn:
            return "MN"
        case .me:
            return "ME"
        case .ms:
            return "MS"
        case .ma:
            return "MA"
        case .mz:
            return "MZ"
        case .mm:
            return "MM"
        case .na:
            return "NA"
        case .nr:
            return "NR"
        case .np:
            return "NP"
        case .nl:
            return "NL"
        case .an:
            return "AN"
        case .nc:
            return "NC"
        case .nz:
            return "NZ"
        case .ni:
            return "NI"
        case .ne:
            return "NE"
        case .ng:
            return "NG"
        case .nu:
            return "NU"
        case .nf:
            return "NF"
        case .mp:
            return "MP"
        case .no:
            return "NO"
        case .om:
            return "OM"
        case .pk:
            return "PK"
        case .pw:
            return "PW"
        case .ps:
            return "PS"
        case .pa:
            return "PA"
        case .pg:
            return "PG"
        case .py:
            return "PY"
        case .pe:
            return "PE"
        case .ph:
            return "PH"
        case .pn:
            return "PN"
        case .pl:
            return "PL"
        case .pt:
            return "PT"
        case .pr:
            return "PR"
        case .qa:
            return "QA"
        case .re:
            return "RE"
        case .ro:
            return "RO"
        case .ru:
            return "RU"
        case .rw:
            return "RW"
        case .sh:
            return "SH"
        case .kn:
            return "KN"
        case .lc:
            return "LC"
        case .pm:
            return "PM"
        case .vc:
            return "VC"
        case .ws:
            return "WS"
        case .sm:
            return "SM"
        case .st:
            return "ST"
        case .sa:
            return "SA"
        case .sn:
            return "SN"
        case .rs:
            return "RS"
        case .sc:
            return "SC"
        case .sl:
            return "SL"
        case .sg:
            return "SG"
        case .sk:
            return "SK"
        case .si:
            return "SI"
        case .sb:
            return "SB"
        case .so:
            return "SO"
        case .za:
            return "ZA"
        case .gs:
            return "GS"
        case .es:
            return "ES"
        case .lk:
            return "LK"
        case .sd:
            return "SD"
        case .sr:
            return "SR"
        case .sj:
            return "SJ"
        case .sz:
            return "SZ"
        case .se:
            return "SE"
        case .ch:
            return "CH"
        case .sy:
            return "SY"
        case .tw:
            return "TW"
        case .tj:
            return "TJ"
        case .tz:
            return "TZ"
        case .th:
            return "TH"
        case .tl:
            return "TL"
        case .tg:
            return "TG"
        case .tk:
            return "TK"
        case .to:
            return "TO"
        case .tt:
            return "TT"
        case .tn:
            return "TN"
        case .tr:
            return "TR"
        case .tm:
            return "TM"
        case .tc:
            return "TC"
        case .tv:
            return "TV"
        case .ug:
            return "UG"
        case .ua:
            return "UA"
        case .ae:
            return "AE"
        case .gb:
            return "GB"
        case .us:
            return "US"
        case .um:
            return "UM"
        case .uy:
            return "UY"
        case .uz:
            return "UZ"
        case .vu:
            return "VU"
        case .ve:
            return "VE"
        case .vn:
            return "VN"
        case .vg:
            return "VG"
        case .vi:
            return "VI"
        case .wf:
            return "WF"
        case .eh:
            return "EH"
        case .ye:
            return "YE"
        case .zm:
            return "ZM"
        case .zw:
            return "ZW"
        }
    }
}
