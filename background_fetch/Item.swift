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
        "\(time): \(type) - \(count)"
    }
}
