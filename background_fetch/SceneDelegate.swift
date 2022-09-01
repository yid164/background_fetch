//
//  SceneDelegate.swift
//  background_fetch
//
//  Created by Ken Dong on 2022-08-23.
//

import UIKit
import BackgroundTasks

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    @available(iOS 13.0, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        BGTaskScheduler.shared.cancelAllTaskRequests()
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    @available(iOS 13.0, *)
    func sceneDidDisconnect(_ scene: UIScene) { }

    @available(iOS 13.0, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
        print("didBecomeActive: ", UserDefaults.standard.integer(forKey: "bgtask"))
    }

    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) { }

    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) { }

    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("didEnterBackground: ", UserDefaults.standard.integer(forKey: "bgtask"))
        (UIApplication.shared.delegate as! AppDelegate).scheduleAppRefresh()
    }
}
