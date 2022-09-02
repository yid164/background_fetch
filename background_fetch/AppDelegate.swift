//
//  AppDelegate.swift
//  background_fetch
//
//  Created by Ken Dong on 2022-08-23.
//

import UIKit
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.0, *) {
            // initally mark the first lauch
            Endpoint.put(item: Item(type: "First Lauch", count: 0)) { response in
                NotificationCenter.default.post(name: .newCountFetched,
                                                object: self,
                                                userInfo: ["item": response])
            }
            BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundId, using: nil) { task in
                self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
            print("register")
        } else {
            // or use some work around
        }
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) { }
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Msg Background")
    }

    // MARK: UISceneSession Lifecycle
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }
    
    
    @available(iOS 13.0, *)
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: backgroundId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 2)
//        request.requiresExternalPower = false
//        request.requiresNetworkConnectivity = true
        do {
            try BGTaskScheduler.shared.submit(request)
            print("BG Task submitted")
        } catch {
            print("BGTask couldn't submitted: \(error)")
        }
    }

    // Change task to BGAppRefreshTask if required
    @available(iOS 13.0, *)
    func handleAppRefresh(task: BGAppRefreshTask) {
        
        scheduleAppRefresh()
        
        task.expirationHandler = {
              task.setTaskCompleted(success: false)
        }
        
        if let num = UserDefaults.standard.value(forKey: "bgtask") as? Int {
            Endpoint.put(item: Item(type: "refresh", count: num)) { item in
                NotificationCenter.default.post(name: .newCountFetched,
                                                object: self,
                                                userInfo: ["item": item])
                task.setTaskCompleted(success: true)
            }
            UserDefaults.standard.set(num+1, forKey: "bgtask")

        } else {
            UserDefaults.standard.set(0, forKey: "bgtask")
            Endpoint.put(item: Item(type: "refresh", count: 0)){ item in
                NotificationCenter.default.post(name: .newCountFetched,
                                                object: self,
                                                userInfo: ["item": item])
                task.setTaskCompleted(success: true)
            }
        }
    }
}

let backgroundId = "com.example.ken.process"

extension Notification.Name {
  static let newCountFetched = Notification.Name("com.example.ken.newCountFetched")
}
