//
//  AppLanguage.swift
//  FutureEdu
//

import Foundation

enum AppLanguage: String, CaseIterable {
    case uz
    case ru
    case en

    /// Language name written in that language (never translated).
    var nativeName: String {
        switch self {
        case .uz: return "O‘zbekcha"
        case .ru: return "Русский"
        case .en: return "English"
        }
    }

    var flag: String {
        switch self {
        case .uz: return "🇺🇿"
        case .ru: return "🇷🇺"
        case .en: return "🇬🇧"
        }
    }

    var localeIdentifier: String {
        switch self {
        case .uz: return "uz_UZ"
        case .ru: return "ru_RU"
        case .en: return "en_US"
        }
    }

    /// `.lproj` folder names to try, in order.
    var bundleCandidates: [String] {
        switch self {
        case .uz: return ["uz", "uz-Latn", "uz-Latn-UZ"]
        case .ru: return ["ru"]
        case .en: return ["en", "Base"]
        }
    }

    /// First supported language from the device's preferred languages, else English.
    static var deviceDefault: AppLanguage {
        for identifier in Locale.preferredLanguages {
            let code = String(identifier.prefix(2)).lowercased()
            if let language = AppLanguage(rawValue: code) {
                return language
            }
        }
        return .en
    }
}
