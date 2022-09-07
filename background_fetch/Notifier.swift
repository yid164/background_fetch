//
//  Notifier.swift
//  background_fetch
//
//  Created by Ken Dong on 2022-09-05.
//

import Foundation
import UIKit
import UserNotifications

@available(iOS 10.0, *)
public class Notifier {
    
    // request notification permission
    static func requestAuthorization(completion: @escaping  (Bool) -> Void) {
        UNUserNotificationCenter.current()
          .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _  in
            completion(granted)
          }
      }
    
    // schedule notification
    static func scheduleLocalNotification(mode: String) {
        // Create Notification Content
        let notificationContent = UNMutableNotificationContent()

        // Configure Notification Content
        notificationContent.title = "Background Fetch Notifications"
        notificationContent.subtitle = "Background Data Sent by \(mode)"
        notificationContent.body = "The data has been sent to local server by \(mode) mode"

        // Add Trigger
        let notificationTrigger = UNTimeIntervalNotificationTrigger(timeInterval: 3.0, repeats: false)

        // Create Notification Request
        let notificationRequest = UNNotificationRequest(identifier: "cocoacasts_local_notification", content: notificationContent, trigger: notificationTrigger)

        // Add Request to User Notification Center
        UNUserNotificationCenter.current().add(notificationRequest) { (error) in
            if let error = error {
                print("Unable to Add Notification Request (\(error), \(error.localizedDescription))")
            }
        }
    }
    
    // check notification permission
    static func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { (notificationSettings) in
            switch notificationSettings.authorizationStatus {
            case .authorized, .provisional:
                return
            default:
                requestAuthorization() { grant in
                    if grant {
                        return
                    } else {
                        self.checkNotificationPermission()
                    }
                }
            }
        }
    }
}
