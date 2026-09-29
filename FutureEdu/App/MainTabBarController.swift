//
//  MainTabBarController.swift
//  FutureEdu
//
//  Root of the app. Built with the Xcode 26 SDK, UITabBarController gets the
//  Liquid Glass floating tab bar automatically on iOS 26+, and the classic
//  tab bar on older iOS versions.
//

import UIKit

final class MainTabBarController: UITabBarController {

    enum Tab: Int, CaseIterable {
        case home = 0
        case future = 1
        case settings = 2

        var titleKey: String {
            switch self {
            case .home: return "tab.home"
            case .future: return "tab.future"
            case .settings: return "tab.settings"
            }
        }

        var iconName: String {
            switch self {
            case .home: return "house"
            case .future: return "sparkles"
            case .settings: return "gearshape"
            }
        }

        var selectedIconName: String {
            switch self {
            case .home: return "house.fill"
            case .future: return "sparkles"
            case .settings: return "gearshape.fill"
            }
        }
    }

    private let initialTab: Tab

    init(selectedTab: Tab) {
        self.initialTab = selectedTab
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.initialTab = .home
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewControllers = Tab.allCases.map(makeController(for:))
        selectedIndex = initialTab.rawValue

        if #available(iOS 26.0, *) {
            // Liquid Glass tab bar shrinks while scrolling down, like system apps.
            tabBarMinimizeBehavior = .onScrollDown
        }
    }

    var currentTab: Tab {
        Tab(rawValue: selectedIndex) ?? .home
    }

    private func makeController(for tab: Tab) -> UIViewController {
        let root: UIViewController
        switch tab {
        case .home: root = HomeViewController()
        case .future: root = FutureViewController()
        case .settings: root = SettingsViewController()
        }

        let navigation = UINavigationController(rootViewController: root)
        navigation.navigationBar.prefersLargeTitles = true
        navigation.tabBarItem = UITabBarItem(
            title: L10n.tr(tab.titleKey),
            image: UIImage(systemName: tab.iconName),
            selectedImage: UIImage(systemName: tab.selectedIconName)
        )
        return navigation
    }
}
