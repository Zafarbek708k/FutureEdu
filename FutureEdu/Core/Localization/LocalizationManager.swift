//
//  LocalizationManager.swift
//  FutureEdu
//

import Foundation

// Persists the user's language choice and overrides "AppleLanguages" so
// Foundation picks that language's resources on the next launch. iOS reads
// AppleLanguages once at process start, so a change here only takes effect
// after the app is restarted — SettingsViewController tells the user that.
final class LocalizationManager {
    static let shared = LocalizationManager()

    private let storageKey = "app_language_key"
    private let appleLanguagesKey = "AppleLanguages"
    private let defaults: UserDefaults

    var currentLanguage: AppLanguage {
        didSet {
            defaults.set(currentLanguage.rawValue, forKey: storageKey)
            if let code = currentLanguage.languageCode {
                defaults.set([code], forKey: appleLanguagesKey)
            } else {
                defaults.removeObject(forKey: appleLanguagesKey)
            }
        }
    }

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let storedValue = defaults.integer(forKey: storageKey)
        self.currentLanguage = AppLanguage(rawValue: storedValue) ?? .system
    }
}
