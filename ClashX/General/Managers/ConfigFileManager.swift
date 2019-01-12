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
        let path = "\(kConfigFolderPath)/\(configName).yml"
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
    
    
    
    static func configs(from proxyModels:[ProxyServerModel]) -> [String:Any]? {
        guard let yamlStr = try? String(contentsOfFile: kDefaultConfigFilePath),
            var yaml = (try? Yams.load(yaml: yamlStr)) as? [String:Any] else {return nil}
        
        var proxies:[Any] = yaml["Proxy"] as? [Any] ?? []
        var proxyNames = [String]()
        for each in proxyModels {
            var newProxy:[String : Any] = ["name":each.remark,
                                           "server":each.serverHost,
                                           "port":Int(each.serverPort) ?? 0,
                                           ]
            
            switch each.proxyType {
            case .shadowsocks:
                newProxy["type"] = "ss"
                newProxy["cipher"] = each.method
                newProxy["password"] = each.password
                if (each.simpleObfs != .none) {
                    newProxy["obfs"] = each.simpleObfs.rawValue
                    newProxy["obfs-host"] = "bing.com"
                }
            case .socks5:
                newProxy["type"] = "socks"
            }
            proxies.append(newProxy)
            proxyNames.append(each.remark)
        }
        yaml["Proxy"] = proxies
        
        var proxyGroups = yaml["Proxy Group"]  as? [Any] ?? []
        if proxyGroups.count == 0 {
            
            let autoGroup:[String : Any] = ["name":"auto","type": "url-test", "url": "https://www.bing.com", "interval": 300,"proxies":proxyNames]
            proxyNames.append("auto")
            let selectGroup:[String : Any] = ["name":"Proxy","type":"select","proxies":proxyNames]
            proxyGroups = [autoGroup,selectGroup]
            yaml["Proxy Group"] = proxyGroups
        }
        
        return yaml
    }
    
    static func saveToClashConfigFile(config:[String:Any]) {
        // save to ~/.config/clash/config.yml
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
            let newPath = "\(kConfigFolderPath)config_\(Date().timeIntervalSince1970).yml"
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
        let path = Bundle.main.path(forResource: "sampleConfig", ofType: "yml")!
        try? FileManager.default.copyItem(atPath: path, toPath: kDefaultConfigFilePath)
        NSUserNotificationCenter.default.postGenerateSimpleConfigNotice()
        return true
    }
    
    
    static func importConfigFile() {
        let openPanel = NSOpenPanel()
        openPanel.title = "Choose Config Json File"
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.becomeKey()
        let result = openPanel.runModal()
        guard (result.rawValue == NSFileHandlingPanelOKButton && (openPanel.url) != nil) else {
            NSUserNotificationCenter.default
                .post(title: "Import Server Profile failed!",
                      info: "Invalid config file!")
            return
        }
        let fileManager = FileManager.default
        let filePath:String = (openPanel.url?.path)!
        var profiles = [ProxyServerModel]()
        
        
        if fileManager.fileExists(atPath: filePath) &&
            filePath.hasSuffix("json") {
            if let data = fileManager.contents(atPath: filePath),
                let json = try? JSON(data: data) {
                let remarkSet = Set<String>()
                for item in json["configs"].arrayValue{
                    if let host = item["server"].string,
                        let method = item["method"].string,
                        let password = item["password"].string{
                        
                        let profile = ProxyServerModel()
                        profile.serverHost = host
                        profile.serverPort = String(item["server_port"].intValue)
                        profile.method = method
                        profile.password = password
                        profile.remark = item["remarks"].stringValue
                        profile.pluginStr = item["plugin_opts"].stringValue
                        if remarkSet.contains(profile.remark) {
                            profile.remark.append("Dup")
                        }
                        
                        if (profile.isValid()) {
                            profiles.append(profile)
                        }
                    }
                }
                
                if (profiles.count > 0) {
                    if let configDict = configs(from: profiles) {
                        self.saveToClashConfigFile(config: configDict)
                        NSUserNotificationCenter
                            .default
                            .post(title: "Import Server Profile succeed!",
                                  info: "Successful import \(profiles.count) items")
                        NotificationCenter.default.post(Notification(name: kShouldUpDateConfig))
                    }
                    
                } else {
                    NSUserNotificationCenter
                        .default
                        .post(title: "Import Server Profile Fail!",
                              info: "No proxies are imported")
                }
            }
        }
        
    }
    
    static func addProxyToConfig(proxy:ProxyServerModel) {
        if let configDict = configs(from: [proxy]) {
            self.saveToClashConfigFile(config: configDict)
            NotificationCenter.default.post(Notification(name: kShouldUpDateConfig))
        }
    }
}


extension ConfigFileManager {
    
    static func checkFinalRuleAndShowAlert() {
        ApiRequest.getRules() {
            rules in
            let hasFinal = rules.reversed().contains(){$0.type == "FINAL"}
            if !hasFinal {
                showNoFinalRuleAlert()
            }
        }
    }
}


extension ConfigFileManager {
    static func showReplacingConfigFileAlert() -> Bool{
        let alert = NSAlert()
        alert.messageText = """
        Can't recognize your config file. We will backup and replace your config file in your config folder.
        
        Otherwise the functions of ClashX will not work properly. You may need to restart ClashX or reload Config manually.
        """
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Replace")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    
    
    static func showNoFinalRuleAlert() {
        let alert = NSAlert()
        alert.messageText = """
No FINAL rule were found in clash configs,This might caused by incorrect upgradation during earily version of clashX or error setting of FINAL rule.Please check your config file.

NO FINAL rule would cause traffic send to DIRECT which no match any rules.
""".localized()
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
}
