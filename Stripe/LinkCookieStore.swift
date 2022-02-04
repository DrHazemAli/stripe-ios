//
//  CookieStore.swift
//  StripeiOS
//
//  Created by Ramon Torres on 12/21/21.
//  Copyright © 2021 Stripe, Inc. All rights reserved.
//

/// A protocol that cookie storage objects should conform to.
///
/// Provides an interface for basic CRUD functionality.
protocol LinkCookieStore {
    /// Writes a cookie to the store.
    /// - Parameters:
    ///   - key: Cookie identifier.
    ///   - value: Cookie value.
    func write(key: String, value: String)

    /// Retrieves a cookie by key.
    /// - Parameter key: Cookie identifier.
    /// - Returns: The cookie value, or `nil` if it doesn't exist.
    func read(key: String) -> String?

    /// Deletes a stored cookie identified by key.
    ///
    /// If `value` is provided, the store will only delete the cookie if the given value
    /// matches the stored value.
    ///
    /// - Parameters:
    ///   - key: Cookie identifier.
    ///   - value: Optional matching value.
    func delete(key: String, value: String?)
}

extension LinkCookieStore {
    /// Deletes a stored cookie identified by key.
    /// - Parameter key: Cookie identifier.
    func delete(key: String) {
        self.delete(key: key, value: nil)
    }
}

// MARK: - Helpers

extension LinkCookieStore {

    var sessionCookieKey: String {
        return "com.stripe.pay_sid"
    }

    func formattedSessionCookies() -> [String: [String]]? {
        guard let value = read(key: sessionCookieKey) else {
            return nil
        }

        return [
            "verification_session_client_secrets": [value]
        ]
    }

}
