//
//  AppDelegate.swift
//  BikeIndex
//
//  Created by Milo Wyner on 11/11/25.
//

import OSLog
import UIKit

/// Used for handling background session events.
class AppDelegate: NSObject, UIApplicationDelegate {
    var backgroundSessionDelegate: BackgroundSessionDelegate?

    func application(
        _ application: UIApplication,
        handleEventsForBackgroundURLSession identifier: String,
        completionHandler: @escaping () -> Void
    ) {
        if let backgroundSessionDelegate {
            backgroundSessionDelegate.appDelegateCompletionHandler = completionHandler
        } else {
            Logger.client.error(
                "\(#function) Can't store AppDelegate's background URL session completion handler because backgroundSessionDelegate is nil"
            )
        }
    }
}
