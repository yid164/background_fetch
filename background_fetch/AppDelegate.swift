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
        if #available(iOS 13.4, *) {
            
            let data = BackgroundData(type: .firstLaunch, time: Date(), count: 0)
            
            let log = "\(data.toLog)0"
            
            FileWriter.shared.startWritting(log) {
                DispatchQueue.main.async {
                    saveToGroup(backgroundData: data)
                    NotificationCenter.default.post(name: .backgroundNotification,
                                                    object: self,
                                                    userInfo: ["data": data])
                }
            }
            
            BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundMode.appRefresh.taskId, using: nil) { task in
                self.handleAppRefresh(task: task as! BGAppRefreshTask)
            }
            
            BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundMode.processing.taskId, using: nil) { task in
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
    
    // not use iOS 9+
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
    
    @available(iOS 13.4, *)
    func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: BackgroundMode.appRefresh.taskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: UIApplication.backgroundFetchIntervalMinimum)
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("BG App Refresh Task submitted")
        } catch {
            print("BG App Refresh Task couldn't submitted: \(error)")
        }
    }

    @available(iOS 13.4, *)
    func handleAppRefresh(task: BGAppRefreshTask) {
        
        concurrentQueue.async {
            task.expirationHandler = {
                task.setTaskCompleted(success: false)
            }
            
            var timeInterval = ""
            var count = 0
            
            if let storedData = getBackgroundDataFromGroup {
                timeInterval = storedData.timeIntervalInMinsSince(since: Date())
                count += storedData.count + 1
            }
            
            let data = BackgroundData(type: .appRefresh, time: Date(), count: count)
            
            let log = "\(data.toLog)\(timeInterval)"
            
            FileWriter.shared.appendFile(log) {
                DispatchQueue.main.async {
                    saveToGroup(backgroundData: data)
                    NotificationCenter.default.post(name: .backgroundNotification,
                                                    object: self,
                                                    userInfo: ["data": data])
                }
            }
            task.setTaskCompleted(success: true)
            self.scheduleAppRefresh()
        }
    }
    
    @available(iOS 13.4, *)
    func scheduleProcessingTask() {
        let request = BGProcessingTaskRequest(identifier: BackgroundMode.processing.taskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: UIApplication.backgroundFetchIntervalMinimum)
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
        concurrentQueue.async {
            task.expirationHandler = {
                  task.setTaskCompleted(success: false)
            }
            
            var timeInterval = ""
            var count = 0
            
            if let storedData = getBackgroundDataFromGroup {
                timeInterval = storedData.timeIntervalInMinsSince(since: Date())
                count += storedData.count + 1
            }
            
            let data = BackgroundData(type: .processing, time: Date(), count: count)
            
            let log = "\(data.toLog)\(timeInterval)"
            
            FileWriter.shared.appendFile(log) {
                DispatchQueue.main.async {
                    saveToGroup(backgroundData: data)
                    NotificationCenter.default.post(name: .backgroundNotification,
                                                    object: self,
                                                    userInfo: ["data": data])
                }
            }
            
            task.setTaskCompleted(success: true)
            self.scheduleProcessingTask()
            
        }
    }
    
    let concurrentQueue = DispatchQueue(label: "ken.async", qos: .background)
}

extension Notification.Name {
    static let backgroundNotification = Notification.Name("com.example.ken.background.notification")
}

var dateFormatter: DateFormatter {
    let formatter = DateFormatter()
//    formatter.timeZone = TimeZone(identifier: "UTC")
    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    return formatter
}

let lastBackgroundTimeKey = "com.example.ken.task.background.time"

enum BackgroundMode: String, Codable {
    case processing, appRefresh, firstLaunch
    
    var rawValue: String {
        switch self {
        case .appRefresh:
            return "App Refresh Task"
        case .processing:
            return "Processing Task"
        default:
            return "First Launch"
        }
    }
    
    var taskId: String {
        switch self {
        case .appRefresh:
            return "com.example.ken.task.refresh"
        case .processing:
            return "com.example.ken.task.process"
        default:
            return ""
        }
    }
    
    var userDefaultKey: String {
        switch self {
        case .processing:
            return "bgProcessTaskKey"
        case .appRefresh:
            return "bgAppRefreshTaskKey"
        default:
            return ""
        }
    }
}
