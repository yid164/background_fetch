//
//  Endpoint.swift
//  background_fetch
//
//  Created by Ken Dong on 2022-08-30.
//

import Foundation

@available (iOS 13, *)
class Endpoint {
    
    static var urlSession = URLSession(configuration: .default)
    
    static func put(item: Item, completionHandler: @escaping (_ response: Item) -> Void) {
        print("PUT")
        // Add the local machine IP address for API request
        let url = URL(string: "http://192.168.31.206:9090/item/")
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "PUT"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        // or
        request.cachePolicy = .reloadIgnoringCacheData
        
        let today = Date()
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "yyyy/MM/dd HH:mm"
        
        let body: [String : Any] = [
            "type": "\(item.type)",
            "count": "\(item.count)",
            "time": "\(formatter1.string(from: today))"
        ]
        if let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) {
            request.httpBody = httpBody
            
            let task = urlSession.dataTask(with: request) { (data, response, error) in
                
                // Check for Error
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
                
                if data != nil {
                    print("Recived the data")
                }
                DispatchQueue.main.async {
                    var i = Item(type: item.type, count: item.count)
                    i.time = "\(formatter1.string(from: today))"
                    completionHandler(i)
                }
            }
            task.resume()
        } else {
            print("Error")
        }
    }
}
