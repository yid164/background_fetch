//
//  Item.swift
//  background_fetch
//
//  Created by Ken Dong on 2022-08-30.
//

import Foundation

struct Item: Codable {
    let type: String
    let count: Int
    var time: String = ""
    
    init(type: String, count: Int) {
        self.type = type
        self.count = count
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        self.time = formatter.string(from: Date())
    }
    
    var toLog: String {
        "Background Executed -- \(type) -- executed: \(count) times"
    }
}


struct BackgroundData: Codable {
    let type: BackgroundMode
    let time: Date
    let count: Int
    
    func timeIntervalInMinsSince(since lastTime: Date) -> String {
        let interval = time.timeIntervalSince(lastTime)
        return "\(interval/60) mins"
    }
    
    var toLog: String {
        return "Mode: \(type.rawValue), Hit Count: \(count), Time Interval Since Last Hit: "
    }
}

func saveToGroup(backgroundData: BackgroundData) {
    let groupDefault: UserDefaults? = UserDefaults(suiteName: "background")
    let encoder: JSONEncoder = JSONEncoder()
    if let data = try? encoder.encode(backgroundData) {
        groupDefault?.set(data, forKey: "backgroundData")
    }
}

var getBackgroundDataFromGroup: BackgroundData? {
    if let groupDefault = UserDefaults(suiteName: "background") {
        let decoder: JSONDecoder = JSONDecoder()
        if let data = groupDefault.object(forKey: "backgroundData") as? Data {
            if let bd = try? decoder.decode(BackgroundData.self, from: data) {
                return bd
            }
        }
    }
    return nil
}
