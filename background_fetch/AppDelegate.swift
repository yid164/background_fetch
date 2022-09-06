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
    
    public var bgTaskMode: BackgroundMode? = nil
    
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
            BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundMode.appRefresh.taskId, using: nil) { task in
                self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
//            BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundMode.processing.taskId, using: nil) { task in
//                self.handleProcessingTask(task: task as! BGProcessingTask)
//            }
            
            Notifier.checkNotificationPermission()
            
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
        let request = BGAppRefreshTaskRequest(identifier: BackgroundMode.appRefresh.taskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 60)
        do {
            try BGTaskScheduler.shared.submit(request)
            print("BG App Refresh Task submitted")
        } catch {
            print("BG App Refresh Task couldn't submitted: \(error)")
        }
    }

    @available(iOS 13.0, *)
    func handleAppRefresh(task: BGAppRefreshTask) {
        
//        scheduleAppRefresh()
        
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        if let num = UserDefaults.standard.value(forKey: BackgroundMode.appRefresh.userDefaultKey) as? Int {
            Endpoint.put(item: Item(type: BackgroundMode.appRefresh.rawValue, count: num)) { item in
                NotificationCenter.default.post(name: .refreshCount,
                                                object: self,
                                                userInfo: ["item": item])
                
                Notifier.scheduleLocalNotification(mode: BackgroundMode.appRefresh.rawValue)
                
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
            
            UserDefaults.standard.set(num+1, forKey: BackgroundMode.appRefresh.userDefaultKey)

        } else {
            UserDefaults.standard.set(0, forKey: BackgroundMode.appRefresh.userDefaultKey)
            Endpoint.put(item: Item(type: BackgroundMode.appRefresh.rawValue, count: 0)){ item in
                NotificationCenter.default.post(name: .refreshCount,
                                                object: self,
                                                userInfo: ["item": item])
                
                Notifier.scheduleLocalNotification(mode: BackgroundMode.appRefresh.rawValue)
                
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
        bgTaskMode = .appRefresh
        scheduleAppRefresh()
    }
    
    @available(iOS 13.0, *)
    func scheduleProcessingTask() {
        let request = BGProcessingTaskRequest(identifier: BackgroundMode.processing.taskId)
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
        
        if let num = UserDefaults.standard.value(forKey: BackgroundMode.processing.userDefaultKey) as? Int {
            Endpoint.put(item: Item(type: BackgroundMode.processing.rawValue, count: num)) { item in
                NotificationCenter.default.post(name: .processCount,
                                                object: self,
                                                userInfo: ["item": item])
                
                Notifier.scheduleLocalNotification(mode: BackgroundMode.processing.rawValue)
                
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
            UserDefaults.standard.set(num+1, forKey: BackgroundMode.processing.userDefaultKey)
        } else {
            UserDefaults.standard.set(0, forKey: BackgroundMode.processing.userDefaultKey)
            Endpoint.put(item: Item(type: BackgroundMode.processing.rawValue, count: 0)){ item in
                NotificationCenter.default.post(name: .processCount,
                                                object: self,
                                                userInfo: ["item": item])
                
                Notifier.scheduleLocalNotification(mode: BackgroundMode.processing.rawValue)
                
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
        bgTaskMode = .processing
        scheduleProcessingTask()
    }
}

extension Notification.Name {
    static let processCount = Notification.Name("com.example.ken.task.processCount")
    
    static let refreshCount = Notification.Name("com.example.ken.task.refreshCount")
}

enum BackgroundMode: String {
    case processing, appRefresh
    
    var rawValue: String {
        switch self {
        case .appRefresh:
            return "App Refresh Task"
        case .processing:
            return "Processing Task"
        }
    }
    
    var taskId: String {
        switch self {
        case .appRefresh:
            return "com.example.ken.task.refresh"
        case .processing:
            return "com.example.ken.task.process"
        }
    }
    
    var userDefaultKey: String {
        switch self {
        case .processing:
            return "bgProcessTaskKey"
        case .appRefresh:
            return "bgProcessTaskKey"
        }
    }
}
