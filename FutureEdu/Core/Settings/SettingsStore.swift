//
//  SettingsStore.swift
//  FutureEdu
//

import Foundation

extension Notification.Name {
    static let appLanguageDidChange = Notification.Name("FutureEdu.appLanguageDidChange")
    static let appThemeDidChange = Notification.Name("FutureEdu.appThemeDidChange")
}

/// Persists user preferences (theme, language) and broadcasts changes.
final class SettingsStore {
    static let shared = SettingsStore()

    private enum Keys {
        static let theme = "settings.theme"
        static let language = "settings.language"
    }

    private let defaults: UserDefaults
    private let notificationCenter: NotificationCenter

    init(defaults: UserDefaults = .standard, notificationCenter: NotificationCenter = .default) {
        self.defaults = defaults
        self.notificationCenter = notificationCenter
    }

    /// Call once at launch, before any UI is built.
    func bootstrap() {
        Localizer.shared.setLanguage(language)
    }

    var theme: AppTheme {
        get {
            AppTheme(rawValue: defaults.integer(forKey: Keys.theme)) ?? .system
        }
        set {
            guard newValue != theme else { return }
            defaults.set(newValue.rawValue, forKey: Keys.theme)
            notificationCenter.post(name: .appThemeDidChange, object: self)
        }
    }

    var language: AppLanguage {
        get {
            defaults.string(forKey: Keys.language).flatMap(AppLanguage.init(rawValue:)) ?? .deviceDefault
        }
        set {
            guard newValue != language else { return }
            defaults.set(newValue.rawValue, forKey: Keys.language)
            Localizer.shared.setLanguage(newValue)
            notificationCenter.post(name: .appLanguageDidChange, object: self)
        }
    }
}
