//
//  ViewController.swift
//  background_fetch
//
//  Created by Ken Dong on 2022-08-23.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var appRefresh: UILabel!
    
    @IBOutlet weak var appRefreshType: UILabel!
    
    @IBOutlet weak var appRefreshCount: UILabel!
    
    @IBOutlet weak var appRefreshTime: UILabel!
    
    @IBOutlet weak var processing: UILabel!
    
    @IBOutlet weak var processingType: UILabel!
    
    @IBOutlet weak var processingCount: UILabel!
    
    @IBOutlet weak var processingTime: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        registerForAppRefreshNotifications()
        registerForProcessingNotifications()
    }
    
    var processItem: Item? = nil {
        didSet {
            if processItem != nil {
                processingType.text = processItem!.type
                processingCount.text = "\(processItem!.count)"
                processingTime.text = processItem!.time
            } else {
                processingType.text = "This is type"
                processingCount.text = "This is the count"
                processingTime.text = "This is the time"
            }
        }
    }
    
    var appRefreshItem: Item? = nil {
        didSet {
            if appRefreshItem != nil {
                appRefreshType.text = appRefreshItem!.type
                appRefreshCount.text = "\(appRefreshItem!.count)"
                appRefreshTime.text = appRefreshItem!.time
            } else {
                appRefreshType.text = "This is type"
                appRefreshCount.text = "This is the count"
                appRefreshTime.text = "This is the time"
            }
        }
    }
    
    func registerForAppRefreshNotifications() {
      NotificationCenter.default.addObserver(
        forName: .refreshCount,
        object: nil,
        queue: nil) { [weak self] (notification) in
            print("App Refresh Notification Received")
            guard let self = self else { return }
            if let uInfo = notification.userInfo, let item = uInfo["item"] as? Item {
                self.appRefreshItem = item
            }
        }
    }
    
    func registerForProcessingNotifications() {
      NotificationCenter.default.addObserver(
        forName: .processCount,
        object: nil,
        queue: nil) { [weak self] (notification) in
            print("Processing Notification Received")
            guard let self = self else { return }
            if let uInfo = notification.userInfo, let item = uInfo["item"] as? Item {
                self.processItem = item
            }
        }
    }
}
