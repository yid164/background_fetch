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
    
    public var processRuns: Bool = false
    
    public var appRefreshRuns: Bool = false
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 13.4, *) {
            
            Notifier.checkNotificationPermission()
            
            UserDefaults.standard.set(0, forKey: BackgroundMode.appRefresh.userDefaultKey)
            
            UserDefaults.standard.set(0, forKey: BackgroundMode.processing.userDefaultKey)
            
            KeychainManager.removeKeychain(service: BackgroundMode.processing.rawValue, account: "Ken")
            
            KeychainManager.removeKeychain(service: BackgroundMode.appRefresh.rawValue, account: "Ken")
            
            KeychainManager.createKeychain(password: "HelloWorld".data(using: .utf8) ?? Data(), service: BackgroundMode.processing.rawValue, account: "Ken")
            
            KeychainManager.createKeychain(password: "HelloWorld".data(using: .utf8) ?? Data(), service: BackgroundMode.appRefresh.rawValue, account: "Ken")
            
            let item = Item(type: "First Launch", count: 0)
            
            FileWriter.startWritting(item.toLog) {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .processCount,
                                                    object: self,
                                                    userInfo: ["item": item])
                    
                    NotificationCenter.default.post(name: .refreshCount,
                                                    object: self,
                                                    userInfo: ["item": item])
                    
                    NotificationCenter.default.post(name: .logUpdate, object: self, userInfo: ["update": true])
                }

            }
            
            BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundMode.appRefresh.taskId, using: nil) { task in
                self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
            
//            BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundMode.processing.taskId, using: nil) { task in
//                self.handleProcessingTask(task: task as! BGProcessingTask)
//            }
            
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

    @available(iOS 13.4, *)
    func handleAppRefresh(task: BGAppRefreshTask) {
        
        scheduleAppRefresh()
                
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        let num = UserDefaults.standard.value(forKey: BackgroundMode.appRefresh.userDefaultKey) as? Int ?? 0
        
        let item = Item(type: BackgroundMode.appRefresh.rawValue, count: num)
        
        let keyData = KeychainManager.getKeychain(service: BackgroundMode.appRefresh.rawValue, account: "Ken")
        let keyStr = String(decoding: keyData, as: UTF8.self)
        
        let log = "\(item.toLog)\nKeychain: \(keyStr)"
        
        FileWriter.appendFile(log) {
            self.appRefreshRuns = true
            DispatchQueue.main.async {
                Notifier.scheduleLocalNotification(mode: BackgroundMode.appRefresh.rawValue)
                UserDefaults.standard.set(num+1, forKey: BackgroundMode.appRefresh.userDefaultKey)
                NotificationCenter.default.post(name: .logUpdate, object: self, userInfo: ["update": true])
                self.appRefreshRuns = false
                task.setTaskCompleted(success: true)
            }
        }
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
    
    @available(iOS 13.4, *)
    func handleProcessingTask(task: BGProcessingTask) {
        
        task.expirationHandler = {
              task.setTaskCompleted(success: false)
        }
        
        let num = UserDefaults.standard.value(forKey: BackgroundMode.processing.userDefaultKey) as? Int ?? 0
        
        let item = Item(type: BackgroundMode.processing.rawValue, count: num)
        
        let keyData = KeychainManager.getKeychain(service: BackgroundMode.processing.rawValue, account: "Ken")
        let keyStr = String(decoding: keyData, as: UTF8.self)
        
        let log = "\(item.toLog)\nKeychain: \(keyStr)"
        
        FileWriter.appendFile(log) {
            self.processRuns = true
            DispatchQueue.main.async {
                Notifier.scheduleLocalNotification(mode: BackgroundMode.processing.rawValue)
                UserDefaults.standard.set(num+1, forKey: BackgroundMode.processing.userDefaultKey)
                NotificationCenter.default.post(name: .logUpdate, object: self, userInfo: ["update": true])
                self.processRuns = false
                task.setTaskCompleted(success: true)
            }
        }
        scheduleProcessingTask()
    }
}

extension Notification.Name {
    static let processCount = Notification.Name("com.example.ken.task.processCount")
    
    static let refreshCount = Notification.Name("com.example.ken.task.refreshCount")
    
    static let logUpdate = Notification.Name("com.example.ken.task.log")
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
