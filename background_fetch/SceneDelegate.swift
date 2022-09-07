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
    func sceneDidBecomeActive(_ scene: UIScene) { }

    @available(iOS 13.0, *)
    func sceneWillResignActive(_ scene: UIScene) { }

    @available(iOS 13.0, *)
    func sceneWillEnterForeground(_ scene: UIScene) { }

    @available(iOS 13.0, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        print("App did enter the background mode")
        let delegate = UIApplication.shared.delegate as! AppDelegate
        delegate.scheduleAppRefresh()
//        delegate.scheduleProcessingTask()
        
//        if !delegate.appRefreshRuns {
//            delegate.scheduleAppRefresh()
////            delegate.appRefreshRuns = true
//        }
        
//        if !delegate.processRuns {
//            delegate.scheduleProcessingTask()
////            delegate.processRuns = true
//        }
    }
}
