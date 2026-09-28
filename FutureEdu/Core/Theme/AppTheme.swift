//
//  AppTheme.swift
//  FutureEdu
//

import UIKit

enum AppTheme: Int, CaseIterable {
    case system = 0
    case light = 1
    case dark = 2

    var interfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: return .unspecified
        case .light: return .light
        case .dark: return .dark
        }
    }

    var localizedTitle: String {
        switch self {
        case .system: return NSLocalizedString("theme_system", comment: "Follow the system appearance setting")
        case .light: return NSLocalizedString("theme_light", comment: "Always use the light appearance")
        case .dark: return NSLocalizedString("theme_dark", comment: "Always use the dark appearance")
        }
    }
}
