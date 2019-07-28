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

class RemoteConfigManager {
    
    var configs: [RemoteConfigModel] = []
    static let shared = RemoteConfigManager()

    private init(){
        if let savedConfigs = UserDefaults.standard.object(forKey: "kRemoteConfigs") as? Data {
            let decoder = JSONDecoder()
            if let loadedConfig = try? decoder.decode([RemoteConfigModel].self, from: savedConfigs) {
                configs = loadedConfig
            } else {
                assertionFailure()
            }
        }
        
        for config in configs {
            config.updating = false
        }
    }
    
    func saveConfigs() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(configs) {
             UserDefaults.standard.set(encoded, forKey: "kRemoteConfigs")
        }
    }
    
    
    static var autoUpdateEnable:Bool {
        get {
            return UserDefaults.standard.object(forKey: "kAutoUpdateEnable") as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "kAutoUpdateEnable")
        }
    }
    
    
    static func updateCheckAtLaunch() {
        guard autoUpdateEnable else {return}
//        let currentConfig = ConfigManager.selectConfigName
//
//        if RemoteConfigManager.configUrl != nil, configFileName == currentConfig {
//
//            if Date().timeIntervalSince(lastAutoCheckTime ?? Date(timeIntervalSince1970: 0)) < 60 * 60 * 12 {
//                // 12hour
//                return;
//            }
//
//            lastAutoCheckTime = Date()
//
//            RemoteConfigManager.updateConfigIfNeed { err in
//                if let err = err {
//                    NSUserNotificationCenter.default.post(title: "Remote Config Update Fail", info: err)
//                } else {
//                    NSUserNotificationCenter.default.post(title: "Remote Config Update", info: "Succeed!")
//                }
//            }
//        }
    }
    
    
    static func getRemoteConfigData(config: RemoteConfigModel, complete:@escaping ((Data?)->Void)) {
        guard var urlRequest = try? URLRequest(url: config.url, method: .get) else {
            assertionFailure()
            Logger.log(msg: "[getRemoteConfigData] url incorrect,\(config.name) \(config.url)")
            return
        }
        urlRequest.cachePolicy = .reloadIgnoringCacheData

        request(urlRequest).responseData { res in
            complete(res.result.value)
        }
    }
    
    static func updateConfig(config: RemoteConfigModel, complete:((String?)->())?=nil) {
        getRemoteConfigData(config: config) { data in
            guard let newData = data else {
                complete?("Download fail")
                return
            }
            guard let newConfigString = String(data: newData, encoding: .utf8),
                verifyConfig(string: newConfigString) else {
                complete?("Remote Config Format Error")
                return
            }
            let savePath = kConfigFolderPath.appending(config.name).appending(".yaml")
            let fm = FileManager.default
            do {
                if fm.fileExists(atPath: savePath) {
                    try fm.removeItem(atPath: savePath)
                }
                try newData.write(to: URL(fileURLWithPath: savePath))
                
//                ConfigManager.selectConfigName = configName
//                NotificationCenter.default.post(Notification(name: kShouldUpDateConfig))
//                didUpdateConfig()
                complete?(nil)
            } catch let err {
                complete?(err.localizedDescription)
            }
        }
        
    }
    
    static func verifyConfig(string: String) -> Bool {
        do {
            let yaml = try Yams.load(yaml: string) as? [String: Any]
            if let proxies = yaml?["Proxy"] as? [Any], proxies.count > 0 {
                return true
            }
        } catch let error {
            Logger.log(msg: error.localizedDescription)
            return false
        }
        return false
    }
    
    static func didUpdateConfig() {
        guard let hook = UserDefaults.standard.string(forKey: "kDidUpdateRemoteConfigHook") else {return}
        DispatchQueue.global().async {
            let appleScriptStr = "do shell script \"\(hook)\""
            let appleScript = NSAppleScript(source: appleScriptStr)
            _ = appleScript?.executeAndReturnError(nil)
        }
    }
    
}


extension String: Error {}
