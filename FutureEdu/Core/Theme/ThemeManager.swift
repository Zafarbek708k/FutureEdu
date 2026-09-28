//
//  ThemeManager.swift
//  FutureEdu
//

import UIKit

// App-wide theme state: persisted in UserDefaults and applied by overriding
// the UIWindow's interface style, so every screen picks it up automatically
// without each view controller checking a setting itself.
final class ThemeManager {
    static let shared = ThemeManager()

    private let storageKey = "app_theme_key"
    private let defaults: UserDefaults
    private weak var window: UIWindow?

    var currentTheme: AppTheme {
        didSet {
            defaults.set(currentTheme.rawValue, forKey: storageKey)
            window?.overrideUserInterfaceStyle = currentTheme.interfaceStyle
        }
    }

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let storedValue = defaults.integer(forKey: storageKey)
        self.currentTheme = AppTheme(rawValue: storedValue) ?? .system
    }

    // Called once from SceneDelegate. Keeps a weak reference so later
    // changes to `currentTheme` can re-apply themselves to the same window.
    func attach(to window: UIWindow) {
        self.window = window
        window.overrideUserInterfaceStyle = currentTheme.interfaceStyle
    }
}
