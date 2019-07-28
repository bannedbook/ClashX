//
//  ConfigFileFactory.swift
//  ClashX
//
//  Created by CYC on 2018/8/5.
//  Copyright © 2018年 yichengchen. All rights reserved.
//
import Foundation
import AppKit
import SwiftyJSON
import Yams

class ConfigFileManager {
    static let shared = ConfigFileManager()
    var witness:Witness?
    func watchConfigFile(configName:String) {
        let path = "\(kConfigFolderPath)/\(configName).yaml"
        witness = Witness(paths: [path], flags: .FileEvents, latency: 0.3) { events in
            for event in events {
                if event.flags.contains(.ItemModified) || event.flags.contains(.ItemCreated){
                    NSUserNotificationCenter.default
                        .postConfigFileChangeDetectionNotice()
                    NotificationCenter.default
                        .post(Notification(name: kConfigFileChange))
                    break
                }
            }
        }
    }
    
    
    static func saveToClashConfigFile(config:[String:Any]) {
        // save to ~/.config/clash/config.yaml
        _ = self.backupAndRemoveConfigFile(showAlert: false)
        var config = config
        var finalConfigString = ""
        do {
            if let proxyConfig = config["Proxy"] {
                finalConfigString += try
                    Yams.dump(object: ["Proxy":proxyConfig],allowUnicode:true)
                config["Proxy"] = nil
            }
            
            if let proxyGroupConfig = config["Proxy Group"] {
                finalConfigString += try
                    Yams.dump(object: ["Proxy Group":proxyGroupConfig]
                        ,allowUnicode:true)
                config["Proxy Group"] = nil
            }
            
            if let rule = config["Rule"] {
                finalConfigString += try
                    Yams.dump(object: ["Rule":rule],allowUnicode:true)
                config["Rule"] = nil
            }
            
            finalConfigString = try Yams.dump(object: config,allowUnicode:true) + finalConfigString
            
            try finalConfigString.write(toFile: kDefaultConfigFilePath, atomically: true, encoding: .utf8)
            
        } catch {
            return
        }
        
        
       
    }
    
    @discardableResult
    static func backupAndRemoveConfigFile(showAlert:Bool = false) -> Bool {
        let path = kDefaultConfigFilePath
        
        if (FileManager.default.fileExists(atPath: path)) {
            if (showAlert) {
                if !self.showReplacingConfigFileAlert() {return false}
            }
            let newPath = "\(kConfigFolderPath)config_\(Date().timeIntervalSince1970).yaml"
            try? FileManager.default.moveItem(atPath: path, toPath: newPath)
        }
        return true
    }
    
    static func copySampleConfigIfNeed() {
        if !FileManager.default.fileExists(atPath: kDefaultConfigFilePath) {
            _ = replaceConfigWithSampleConfig()
        }
    }
    
    static func replaceConfigWithSampleConfig() -> Bool {
        if (!backupAndRemoveConfigFile(showAlert: true)) {
            return false
        }
        let path = Bundle.main.path(forResource: "sampleConfig", ofType: "yaml")!
        try? FileManager.default.copyItem(atPath: path, toPath: kDefaultConfigFilePath)
        NSUserNotificationCenter.default.postGenerateSimpleConfigNotice()
        return true
    }
    
    
}


extension ConfigFileManager {
    
    static func checkFinalRuleAndShowAlert() {
        ApiRequest.getRules() {
            rules in
            let hasFinal = rules.reversed().contains(){$0.type == "MATCH"}
            if !hasFinal {
                showNoFinalRuleAlert()
            }
        }
    }
}


extension ConfigFileManager {
    static func showReplacingConfigFileAlert() -> Bool{
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("Can't recognize your config file. We will backup and replace your config file in your config folder.\n\nOtherwise the functions of ClashX will not work properly. You may need to restart ClashX or reload Config manually.", comment: "")
        alert.alertStyle = .warning
        alert.addButton(withTitle: NSLocalizedString("Replace", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    
    
    static func showNoFinalRuleAlert() {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("No FINAL rule were found in clash configs,This might caused by incorrect upgradation during earily version of clashX or error setting of FINAL rule.Please check your config file.\n\nNO FINAL rule would cause traffic send to DIRECT which no match any rules.", comment: "")
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
}
