import HoneybadgerSwift

extension Honeybadger {
    /// Context keys we use to annotate errors with Honeybadger.
    /// Refer to these instead of raw strings for type safety and consistency.
    enum ContextKey: String {
        case userId = "user_id"
        case bikeId = "bike_id"
        case qrSticker = "qr_sticker"
        case deeplink = "deeplink"
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
