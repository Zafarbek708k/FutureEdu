//
//  SceneDelegate.swift
//  FutureEdu
//
//  Created by macbook on 14/06/26.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        // Must run before any UI is built so that strings use the saved language.
        SettingsStore.shared.bootstrap()

        let window = UIWindow(windowScene: windowScene)
        window.overrideUserInterfaceStyle = SettingsStore.shared.theme.interfaceStyle
        window.rootViewController = MainTabBarController(selectedTab: .home)
        window.makeKeyAndVisible()
        self.window = window

        NotificationCenter.default.addObserver(
            self, selector: #selector(themeDidChange), name: .appThemeDidChange, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(languageDidChange), name: .appLanguageDidChange, object: nil
        )
    }

    // MARK: - Settings changes

    @objc private func themeDidChange() {
        guard let window else { return }
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            window.overrideUserInterfaceStyle = SettingsStore.shared.theme.interfaceStyle
        }
    }

    /// Rebuilds the whole UI so every screen picks up the new language,
    /// keeping the user on the tab they were on (Settings).
    @objc private func languageDidChange() {
        guard let window else { return }
        let currentTab = (window.rootViewController as? MainTabBarController)?.currentTab ?? .home
        let newRoot = MainTabBarController(selectedTab: currentTab)

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve) {
            let animationsWereEnabled = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            window.rootViewController = newRoot
            UIView.setAnimationsEnabled(animationsWereEnabled)
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        NotificationCenter.default.removeObserver(self)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}
