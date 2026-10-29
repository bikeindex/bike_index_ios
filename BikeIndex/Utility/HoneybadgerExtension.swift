import HoneybadgerSwift
import UIKit

extension Honeybadger {
    /// Context keys we use to annotate errors with Honeybadger.
    /// Refer to these instead of raw strings for type safety and consistency.
    enum ContextKey: String {
        case userId = "user_id"
        case bikeId = "bike_id"
        case qrSticker = "qr_sticker"
        case deeplink = "deeplink"
        case appVersion = "app_version"
        case deviceModel = "device_model"
    }

    static func notify(error: Error, bikeId: Int) {
        Honeybadger.notify(
            error: error,
            context: [
                Honeybadger.ContextKey.bikeId.rawValue: String(bikeId)
            ])
    }

    static func notify(error: Error, qrSticker stickerCode: String) {
        Honeybadger.notify(
            error: error,
            context: [
                Honeybadger.ContextKey.qrSticker.rawValue: stickerCode
            ])
    }

    /// Annotate all errors with the app version and device model.
    /// Call once at app launch.
    @MainActor static func setLaunchContext() {
        let versionInfo = AppVersionInfo()
        let combinedVersion =
            "\(versionInfo.marketingVersion ?? "unknown") (\(versionInfo.buildNumber ?? "unknown"))"
        Honeybadger.setContext(context: [
            Honeybadger.ContextKey.appVersion.rawValue: combinedVersion,
            Honeybadger.ContextKey.deviceModel.rawValue: UIDevice.current.name,
        ])
    }

    static func set(userId: String) {
        Honeybadger.setContext(
            context: [
                Honeybadger.ContextKey.userId.rawValue: userId
            ])
    }

    static func reset() {
        Honeybadger.resetContext(context: [:])
    }
}
