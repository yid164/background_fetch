//
//  ViewController.swift
//  background_fetch
//
//  Created by Ken Dong on 2022-08-23.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var type: UILabel!
    
    @IBOutlet weak var count: UILabel!
    
    @IBOutlet weak var time: UILabel!
    
    var item: Item? = nil {
        didSet {
            if item != nil {
                type.text = item!.type
                count.text = "\(item!.count)"
                time.text = item!.time
            } else {
                type.text = "This is type"
                count.text = "This is the count"
                time.text = "This is the time"
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(1, forKey: "bgtask")
        print("viewDidLoad: ", UserDefaults.standard.integer(forKey: "bgtask"))
        registerForNotifications()
    }
    
    func registerForNotifications() {
      NotificationCenter.default.addObserver(
        forName: .newCountFetched,
        object: nil,
        queue: nil) { [weak self] (notification) in
          print("notification received")
            guard let self = self else { return }
          if let uInfo = notification.userInfo,
             let item = uInfo["item"] as? Item {
              self.item = item
          }
      }
    }
}

