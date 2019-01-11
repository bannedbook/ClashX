//
//  RemoteConfigManager.swift
//  ClashX
//
//  Created by CYC on 2018/11/6.
//  Copyright © 2018 west2online. All rights reserved.
//

import Cocoa
import Alamofire
import Yams

class RemoteConfigManager: NSObject {
    static var configUrl:String? {
        get {
            return UserDefaults.standard.string(forKey: "kRemoteConfigUrl")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "kRemoteConfigUrl")
        }
    }
    
    static func showUrlInputAlert() {
        let msg = NSAlert()
        msg.addButton(withTitle: "OK")
        msg.addButton(withTitle: "Cancel")  // 2nd button
        msg.messageText = "Remote config"
        msg.informativeText = "url:"
        
        let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 300, height: 24))
        txt.cell?.usesSingleLineMode = true
        txt.stringValue = configUrl ?? ""
        msg.accessoryView = txt
        let response = msg.runModal()
        
        if response == .alertFirstButtonReturn {
            if URL(string: txt.stringValue) != nil {
                configUrl = txt.stringValue
                updateConfigIfNeed()
            }else {
                alert(with: "Url Error")
            }
        }
    }
    
    static func getRemoteConfigString(handler:@escaping (String, String?)->()) {
        guard let urlString = configUrl,
            let host = URL(string: urlString)?.host
            else {alert(with: "Not config url set!");return}
        
        request(urlString, method: .get).responseString(encoding: .utf8) { (res) in
            if let s = res.result.value {
                handler(host,s)
            } else {
                handler(host,nil)
            }
        }
    }
    
    static func updateConfigIfNeed() {
        getRemoteConfigString { (host,string) in
            guard let newConfigString = string else {alert(with: "Download fail"); return}
            
            let savePath = kConfigFolderPath.appending(host).appending(".yml")
            let fm = FileManager.default
            do {
                if fm.fileExists(atPath: savePath) {
                    let current = try String(contentsOfFile: savePath)
                    if current == newConfigString {
                        self.alert(with: "No Update needed!")
                    }
                    try fm.removeItem(atPath: savePath)
                }
                try newConfigString.write(toFile: savePath, atomically: true, encoding: .utf8)
                ConfigManager.selectConfigName = host
                NotificationCenter.default.post(Notification(name: kShouldUpDateConfig))
                self.alert(with: "Update Success!")
            } catch let err {
                self.alert(with: err.localizedDescription)
            }

        }
    }
    
    static func alert(with text:String) {
        let alert = NSAlert()
        alert.messageText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}


extension String: Error {}
