//
//  WebScripts.swift
//  BikeIndex
//
//  Created by Jack on 1/14/24.
//

import WebKit
import OSLog

enum WebScripts: String {
    case removeFrame =
    """
    nav { display: none }
    .primary-footer .terms-and-stuff { display: none }
    """
    /*    footer { display: none } */

    var script: WKUserScript {
        let escapedNewlines = self.rawValue.replacingOccurrences(of: "\n", with: "\\n")
        let javascript =
"""
console.log("I'm here!");
document.head.insertAdjacentHTML('beforeend', \"<style>\(escapedNewlines)</style>\")
"""
        Logger.api.debug("\(javascript, privacy: .public)")
        return WKUserScript(source: javascript,
                            injectionTime: .atDocumentEnd,
                            forMainFrameOnly: true)
    }
}
