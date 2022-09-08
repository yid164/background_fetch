//
//  BackgroundManager.swift
//  background_fetch
//
//  Created by Ken Dong on 2022-09-07.
//

import Foundation
import BackgroundTasks

@available(iOS 13.4, *)
class BackgroundManager {
    
    static let shared = BackgroundManager()
    
    // public api: register when app launched
    func register() {
        
//        let task = Task
        
        UserDefaults.standard.set(0, forKey: BackgroundMode.appRefresh.userDefaultKey)
        
        UserDefaults.standard.set(0, forKey: BackgroundMode.processing.userDefaultKey)
        
        let item = Item(type: "First Launch", count: 0)
        
        FileWriter.shared.startWritting(item.toLog) {
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .processCount,
                                                object: AppDelegate.self,
                                                userInfo: ["item": item])
                
                NotificationCenter.default.post(name: .refreshCount,
                                                object: AppDelegate.self,
                                                userInfo: ["item": item])
                
                NotificationCenter.default.post(name: .logUpdate,
                                                object: AppDelegate.self,
                                                userInfo: ["update": true])
            }

        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundMode.appRefresh.taskId, using: nil) { [weak self] task in
            guard let self = self else { return }
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: BackgroundMode.processing.taskId, using: nil) { [weak self] task in
            guard let self = self else { return }
            self.handleProcessingTask(task: task as! BGProcessingTask)
        }
        

        print("register")
    }
    
    // public api: schedule when app in the background
    func scheduleBackground() {
        scheduleAppRefresh()
        scheduleProcessingTask()
    }
    
    // public api: cancel task
    func cancelTask() {}
}

@available(iOS 13.4, *)
extension BackgroundManager {
    
    private var lastBackgroundFetchTime: Date? {
        if let lastFetchTimeString = UserDefaults.standard.string(forKey: lastBackgroundTimeKey) {
            return dateFormatter.date(from: lastFetchTimeString)
        } else {
            return nil
        }
    }
    
    private func setBackgroundFetchTime(_ date: Date = Date()) {
        UserDefaults.standard.set(dateFormatter.string(from: Date()), forKey: lastBackgroundTimeKey)
    }
    
    private func handleProcessingTask(task: BGProcessingTask) {
        
        task.expirationHandler = {
              task.setTaskCompleted(success: false)
        }
        
        var requireHandle = true
        if let lastBackgroundFetch = lastBackgroundFetchTime {
            if lastBackgroundFetch.timeIntervalSince(Date()) < minTimeInterval {
                requireHandle = false
            }
        }
        
        if requireHandle {
            let num = UserDefaults.standard.value(forKey: BackgroundMode.processing.userDefaultKey) as? Int ?? 0
            
            let item = Item(type: BackgroundMode.processing.rawValue, count: num)
            
            let log = item.toLog
            
            FileWriter.shared.appendFile(log) {
                self.setBackgroundFetchTime()
                UserDefaults.standard.set(num+1, forKey: BackgroundMode.processing.userDefaultKey)
                NotificationCenter.default.post(name: .logUpdate,
                                                object: AppDelegate.self,
                                                userInfo: ["update": true])
            }

            
//            Notifier.scheduleLocalNotification(mode: BackgroundMode.processing.rawValue)

            
            
        } else {
            FileWriter.shared.appendFile("Processing Msg: Time Limit") {
                NotificationCenter.default.post(name: .logUpdate,
                                                object: AppDelegate.self,
                                                userInfo: ["update": true])
            }

        }
        
        task.setTaskCompleted(success: true)

        scheduleProcessingTask()
    }
    
    private func handleAppRefresh(task: BGAppRefreshTask) {
        
        scheduleAppRefresh()
        
        var requireHandle = true
        if let lastBackgroundFetch = lastBackgroundFetchTime {
            if lastBackgroundFetch.timeIntervalSince(Date()) < minTimeInterval {
                requireHandle = false
            }
        }
                
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        
        if requireHandle {
            let num = UserDefaults.standard.value(forKey: BackgroundMode.appRefresh.userDefaultKey) as? Int ?? 0
            
            let item = Item(type: BackgroundMode.appRefresh.rawValue, count: num)
            
            let log = item.toLog
            
            FileWriter.shared.appendFile(log) {
                NotificationCenter.default.post(name: .logUpdate,
                                                object: AppDelegate.self,
                                                userInfo: ["update": true])
                
                UserDefaults.standard.set(num+1, forKey: BackgroundMode.appRefresh.userDefaultKey)
                self.setBackgroundFetchTime()
            }
        } else {
            FileWriter.shared.appendFile("App Refresh Msg: Time Limit") {
                NotificationCenter.default.post(name: .logUpdate,
                                                object: AppDelegate.self,
                                                userInfo: ["update": true])
            }
            
        }
        task.setTaskCompleted(success: true)
    }
    
    private func scheduleAppRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: BackgroundMode.appRefresh.taskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30)
        do {
            try BGTaskScheduler.shared.submit(request)
            print("BG App Refresh Task submitted")
        } catch {
            print("BG App Refresh Task couldn't submitted: \(error)")
        }
    }
    
    private func scheduleProcessingTask() {
        let request = BGProcessingTaskRequest(identifier: BackgroundMode.processing.taskId)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 30)
        request.requiresExternalPower = false
        request.requiresNetworkConnectivity = true
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("BG Processing Task submitted")
        } catch {
            print("BG Processing Task couldn't submitted: \(error)")
        }
    }
}

@available(iOS 13.0.0, *)
class TaskQueue {
    
    private actor TaskQueueActor {
        private var blocks : [() async -> Void] = []
        private var currentTask : Task<Void,Never>? = nil
        
        func addBlock(block:@escaping () async -> Void){
            blocks.append(block)
            next()
        }
        
        func next()
        {
            if(currentTask != nil) {
                return
            }
            if(!blocks.isEmpty)
            {
                let block = blocks.removeFirst()
                currentTask = Task{
                    await block()
                    currentTask = nil
                    next()
                }
            }
        }
    }
    private let taskQueueActor = TaskQueueActor()
    
    func dispatch(block:@escaping () async ->Void){
        Task{
            await taskQueueActor.addBlock(block: block)
        }
    }
}
