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
//            BGTaskScheduler.shared.register(forTaskWithIdentifier: appRefreshId, using: nil) { task in
//                self.handleAppRefresh(task: task as! BGAppRefreshTask)
//            }
            BGTaskScheduler.shared.register(forTaskWithIdentifier: processId, using: nil) { task in
                self.handleProcessingTask(task: task as! BGProcessingTask)
            }
            print("register")
        } else {
            // or use some work around
        }
        
        return true
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("Did enter background")
    }
    
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
        let request = BGAppRefreshTaskRequest(identifier: appRefreshId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60 * 2)
//        request.requiresExternalPower = false
//        request.requiresNetworkConnectivity = true
        do {
            try BGTaskScheduler.shared.submit(request)
            print("BG App Refresh Task submitted")
        } catch {
            print("BG App Refresh Task couldn't submitted: \(error)")
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
            
            // Testing the time avaiable
//            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 25) {
//                Endpoint.put(item: Item(type: "25 seconds", count: 0)) { item in
//                    NotificationCenter.default.post(name: .newCountFetched,
//                                                    object: self,
//                                                    userInfo: ["item": item])
//                    task.setTaskCompleted(success: true)
//                }
//            }
            
            UserDefaults.standard.set(num+1, forKey: "bgtask")

        } else {
            UserDefaults.standard.set(0, forKey: "bgtask")
            Endpoint.put(item: Item(type: "refresh", count: 0)){ item in
                NotificationCenter.default.post(name: .newCountFetched,
                                                object: self,
                                                userInfo: ["item": item])
                task.setTaskCompleted(success: true)
            }
            
            // Testing the time avaiable
//            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 25) {
//                Endpoint.put(item: Item(type: "25 seconds", count: 0)) { item in
//                    NotificationCenter.default.post(name: .newCountFetched,
//                                                    object: self,
//                                                    userInfo: ["item": item])
//                    task.setTaskCompleted(success: true)
//                }
//            }
        }
    }
    
    @available(iOS 13.0, *)
    func scheduleProcessingTask() {
        let request = BGProcessingTaskRequest(identifier: processId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60)
        request.requiresExternalPower = false
        request.requiresNetworkConnectivity = true
        do {
            try BGTaskScheduler.shared.submit(request)
            print("BG Processing Task submitted")
        } catch {
            print("BG Processing Task couldn't submitted: \(error)")
        }
    }
    
    @available(iOS 13.0, *)
    func handleProcessingTask(task: BGProcessingTask) {
        scheduleProcessingTask()
        
        task.expirationHandler = {
              task.setTaskCompleted(success: false)
        }
        
        if let num = UserDefaults.standard.value(forKey: "bgtask") as? Int {
            Endpoint.put(item: Item(type: "processing", count: num)) { item in
                NotificationCenter.default.post(name: .newCountFetched,
                                                object: self,
                                                userInfo: ["item": item])
                task.setTaskCompleted(success: true)
            }
            UserDefaults.standard.set(num+1, forKey: "bgtask")
        } else {
            UserDefaults.standard.set(0, forKey: "bgtask")
            Endpoint.put(item: Item(type: "processing", count: 0)){ item in
                NotificationCenter.default.post(name: .newCountFetched,
                                                object: self,
                                                userInfo: ["item": item])
                task.setTaskCompleted(success: true)
            }
        }
    }
}

let processId = "com.example.ken.process"
let appRefreshId = "com.example.ken.refresh"

extension Notification.Name {
  static let newCountFetched = Notification.Name("com.example.ken.newCountFetched")
}
