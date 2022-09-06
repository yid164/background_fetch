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
            Endpoint.put(item: Item(type: "First Lauch", count: -1)) { response in
                NotificationCenter.default.post(name: .processCount,
                                                object: self,
                                                userInfo: ["item": response])
                
                NotificationCenter.default.post(name: .refreshCount,
                                                object: self,
                                                userInfo: ["item": response])
            }
            BGTaskScheduler.shared.register(forTaskWithIdentifier: appRefreshId, using: nil) { task in
                self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
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
        do {
            try BGTaskScheduler.shared.submit(request)
            print("BG App Refresh Task submitted")
        } catch {
            print("BG App Refresh Task couldn't submitted: \(error)")
        }
    }

    @available(iOS 13.0, *)
    func handleAppRefresh(task: BGAppRefreshTask) {
        
        scheduleAppRefresh()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        if let num = UserDefaults.standard.value(forKey: backgroundAppRefreshTaskKey) as? Int {
            Endpoint.put(item: Item(type: backgroundAppRefreshTaskKey, count: num)) { item in
                NotificationCenter.default.post(name: .refreshCount,
                                                object: self,
                                                userInfo: ["item": item])
                // Hide this for testing the time
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
            
            UserDefaults.standard.set(num+1, forKey: backgroundAppRefreshTaskKey)

        } else {
            UserDefaults.standard.set(0, forKey: backgroundAppRefreshTaskKey)
            Endpoint.put(item: Item(type: backgroundAppRefreshTaskKey, count: 0)){ item in
                NotificationCenter.default.post(name: .refreshCount,
                                                object: self,
                                                userInfo: ["item": item])
                // Hide this for testing the time
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
        
        task.expirationHandler = {
              task.setTaskCompleted(success: false)
        }
        
        if let num = UserDefaults.standard.value(forKey: backgroundProcessTaskKey) as? Int {
            Endpoint.put(item: Item(type: backgroundProcessTaskKey, count: num)) { item in
                NotificationCenter.default.post(name: .processCount,
                                                object: self,
                                                userInfo: ["item": item])
                // Hide this for testing the time
                task.setTaskCompleted(success: true)
            }
            
            //1 min test
//            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 60) {
//                Endpoint.put(item: Item(type: "1 min", count: 1)) { item in
//                    NotificationCenter.default.post(name: .newCountFetched,
//                                                    object: self,
//                                                    userInfo: ["item": item])
//                    task.setTaskCompleted(success: true)
//                }
//            }
            UserDefaults.standard.set(num+1, forKey: "bgtask")
        } else {
            UserDefaults.standard.set(0, forKey: backgroundProcessTaskKey)
            Endpoint.put(item: Item(type: backgroundProcessTaskKey, count: 0)){ item in
                NotificationCenter.default.post(name: .processCount,
                                                object: self,
                                                userInfo: ["item": item])
                // Hide this for testing the time
                task.setTaskCompleted(success: true)
            }
            
            //1 min test
//            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + 60) {
//                Endpoint.put(item: Item(type: "1 min", count: 1)) { item in
//                    NotificationCenter.default.post(name: .newCountFetched,
//                                                    object: self,
//                                                    userInfo: ["item": item])
//                    task.setTaskCompleted(success: true)
//                }
//            }
        }
        scheduleProcessingTask()
    }
}

let processId = "com.example.ken.task.process"
let appRefreshId = "com.example.ken.task.refresh"

let backgroundAppRefreshTaskKey = "bgAppRefreshTask"
let backgroundProcessTaskKey = "bgProcessTask"

extension Notification.Name {
    static let processCount = Notification.Name("com.example.ken.task.processCount")
    
    static let refreshCount = Notification.Name("com.example.ken.task.refreshCount")
}
