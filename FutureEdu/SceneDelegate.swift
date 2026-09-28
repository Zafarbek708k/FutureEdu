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
        // Programmatic root (no storyboard): a UITabBarController with three
        // tabs. On iOS 26 a plain UITabBarController already renders as the
        // floating "Liquid Glass" bar — no custom bar is needed.
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = makeRootTabBarController()
        window.makeKeyAndVisible()
        self.window = window

        ThemeManager.shared.attach(to: window)
    }

    private func makeRootTabBarController() -> UITabBarController {
        let homeNav = UINavigationController(rootViewController: HomeViewController())
        homeNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("home_title", comment: "Home tab title"),
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let futureNav = UINavigationController(rootViewController: FutureViewController())
        futureNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("future_title", comment: "Future tab title"),
            image: UIImage(systemName: "sparkles"),
            selectedImage: UIImage(systemName: "sparkles")
        )

        let settingsNav = UINavigationController(rootViewController: SettingsViewController())
        settingsNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("settings_title", comment: "Settings tab title"),
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )

        for nav in [homeNav, futureNav, settingsNav] {
            nav.navigationBar.prefersLargeTitles = true
        }

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [homeNav, futureNav, settingsNav]
        return tabBarController
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

