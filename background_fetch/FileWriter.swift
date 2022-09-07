//
//  FileWriter.swift
//  background_fetch
//
//  Created by Ken Dong on 2022-09-06.
//

import Foundation

@available(iOS 13.4, *)
public class FileWriter {
    
    static let fileURLString: String = "file.text"
    
    static func cleanFile() {
        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = dir.appendingPathComponent(fileURLString)
            
            if FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    try FileManager.default.removeItem(at: fileURL)
                } catch {
                    print("Error to remove file")
                }
                print("Cleaned File")
            } else {
                print("File is not existed")
            }
        } else {
            print("File is not existed")
        }
    }
    
    static func createFile(_ text: String = "", complete: @escaping () -> () = {}) {

        let text = text //just a text

        if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {

            let fileURL = dir.appendingPathComponent(fileURLString)

            do {
                try text.write(to: fileURL, atomically: false, encoding: .utf8)
                complete()
            }
            catch {
                print("Error to Write File")
            }
        }
    }
    
    static func readFile() -> String {
        
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return "ERROR TO READ FILE" }
        
        let fileURL = dir.appendingPathComponent(fileURLString)
        do {
            let text = try String(contentsOf: fileURL, encoding: .utf8)
            return text
        }
        catch {
            print("Error to Read File")
            return "ERROR TO READ FILE"
        }
    }
    
    static func appendFile(_ text: String = "", complete: @escaping () -> () = {}) {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        let fileURL = dir.appendingPathComponent(fileURLString)
        
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                if let fileHandle = try? FileHandle(forWritingTo: fileURL) {
                    try fileHandle.seekToEnd()
                    try fileHandle.write(contentsOf: "\n(text)".data(using: .utf8)!)
                    try fileHandle.close()
                    complete()
                }
            } else {
                createFile("", complete: complete)
            }
        } catch {
            print("Append File Error")
        }
    }
    
    static func startWritting(_ text: String, complete: @escaping () -> () = {}) {
        cleanFile()
        createFile(text, complete: complete)
    }
}
