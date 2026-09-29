//
//  Localizer.swift
//  FutureEdu
//
//  In-app language switching: strings are looked up in the `.lproj` bundle of
//  the language chosen in Settings (not the device language).
//  Translations live in Resources/Localizable.xcstrings.
//

import Foundation

final class Localizer {
    static let shared = Localizer()

    private(set) var language: AppLanguage = .en
    private var bundle: Bundle = .main
    private lazy var fallbackBundle: Bundle = Self.bundle(for: .en)

    private static let notFound = "\u{1}__missing__\u{1}"

    private init() {}

    var locale: Locale {
        Locale(identifier: language.localeIdentifier)
    }

    func setLanguage(_ language: AppLanguage) {
        self.language = language
        bundle = Self.bundle(for: language)
    }

    func string(_ key: String) -> String {
        let value = bundle.localizedString(forKey: key, value: Self.notFound, table: nil)
        if value != Self.notFound { return value }
        // Missing translation -> English -> the key itself.
        return fallbackBundle.localizedString(forKey: key, value: key, table: nil)
    }

    private static func bundle(for language: AppLanguage) -> Bundle {
        for name in language.bundleCandidates {
            if let path = Bundle.main.path(forResource: name, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                return bundle
            }
        }
        return .main
    }
}

/// Short access point: `L10n.tr("home.title")`, `L10n.tr("todo.filter.all", 5)`.
enum L10n {
    static func tr(_ key: String) -> String {
        Localizer.shared.string(key)
    }

    static func tr(_ key: String, _ arguments: CVarArg...) -> String {
        String(format: Localizer.shared.string(key), locale: Localizer.shared.locale, arguments: arguments)
    }
}
