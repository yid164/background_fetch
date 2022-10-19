//
//  ViewController.swift
//  background_fetch
//
//  Created by Ken Dong on 2022-08-23.
//

import UIKit
import MessageUI

class ViewController: UIViewController, MFMailComposeViewControllerDelegate {
        
    @IBOutlet weak var lastRunningType: UILabel!
    @IBOutlet weak var lastRunningTime: UILabel!
    @IBOutlet weak var totalHits: UILabel!
    
    @IBOutlet weak var sendLogMailButton: UIButton!
    @IBOutlet weak var cleanLogButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNotification()
        sendLogMailButton.addTarget(self, action: #selector(self.sendEmail), for: .allEvents)
        sendLogMailButton.setTitle("Send Mail", for: .normal)
        cleanLogButton.tintColor = .red
        cleanLogButton.setTitle("Clean Log", for: .normal)
        cleanLogButton.addTarget(self, action: #selector(self.cleanLog), for: .allTouchEvents)
    }
    
    func registerNotification() {
        NotificationCenter.default.addObserver(
            forName: .backgroundNotification,
          object: nil,
          queue: nil) { [weak self] (notification) in
              print("\(dateFormatter.string(from: Date())): Background")
              guard let self = self else { return }
              if let uInfo = notification.userInfo, let data = uInfo["data"] as? BackgroundData {
                  self.currentData = data
              }
          }
    }
    
    var currentData: BackgroundData? = nil {
        didSet {
            if currentData != nil {
                lastRunningType.text = "Type: \(currentData!.type)"
                totalHits.text = "Hits: \(currentData!.count)"
                lastRunningTime.text = "Time: \(dateFormatter.string(from: currentData!.time))"
            } else {
                lastRunningType.text = "Last Type"
                totalHits.text = "Total Hits"
                lastRunningTime.text = "Last Time"
            }
        }
    }
    
    @objc func cleanLog() {
        if #available(iOS 13.4, *) {
            cleanGroup()
            FileWriter.shared.cleanFile()
        } else {
            // Fallback on earlier versions
        }
    }
    
    @objc func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["kdong@fortinet.com"])
            if #available(iOS 13.4, *) {
                let file = FileWriter.shared
                if let data = file.fileData {
                    mail.addAttachmentData(data, mimeType: "text/plain", fileName: "log")
                }
            } else {
                // Fallback on earlier versions
            }
            
            mail.setSubject("Background Log")
            mail.setMessageBody("<p>Background Log File</p>", isHTML: true)

            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}
