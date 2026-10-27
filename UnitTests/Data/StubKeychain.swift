//
//  StubKeychain.swift
//  UnitTests
//

import Foundation
import KeychainSwift

/// An in-memory `KeychainSwift` stub so tests never touch the real (persisted)
/// simulator keychain. Values can be pre-seeded via `preloaded`.
final class StubKeychain: KeychainSwift, @unchecked Sendable {
    private let lock = NSLock()
    private var store: [String: String] = [:]

    init(preloaded: [String: String] = [:]) {
        store = preloaded
        super.init()
    }

    override func get(_ key: String) -> String? {
        lock.lock()
        defer { lock.unlock() }
        return store[key]
    }

    override func delete(_ key: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return store.removeValue(forKey: key) != nil
    }
}
