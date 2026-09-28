//
//  AppLanguage.swift
//  FutureEdu
//

import Foundation

enum AppLanguage: Int, CaseIterable {
    case system = 0
    case english = 1
    case russian = 2
    case uzbek = 3

    // nil means "follow the device's language" — no AppleLanguages override.
    var languageCode: String? {
        switch self {
        case .system: return nil
        case .english: return "en"
        case .russian: return "ru"
        case .uzbek: return "uz"
        }
    }

    // Language names are shown in their own language regardless of the
    // app's current locale, which is the standard convention for language pickers.
    var localizedTitle: String {
        switch self {
        case .system: return NSLocalizedString("language_system", comment: "Follow the device language setting")
        case .english: return "English"
        case .russian: return "Русский"
        case .uzbek: return "Oʻzbekcha"
        }
    }
}
