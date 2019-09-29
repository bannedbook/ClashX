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
    var autoUpateTimer: Timer?
    
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
        migrateOldRemoteConfig()
        setupAutoUpdateTimer()
    }
    
    func saveConfigs() {
        Logger.log("Saving Remote Config Setting")
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(configs) {
             UserDefaults.standard.set(encoded, forKey: "kRemoteConfigs")
        }
    }
    
    func migrateOldRemoteConfig() {
        if let url = UserDefaults.standard.string(forKey: "kRemoteConfigUrl"),
            let name = URL(string: url)?.host{
            configs.append(RemoteConfigModel(url: url, name: name))
            UserDefaults.standard.removeObject(forKey: "kRemoteConfigUrl")
            saveConfigs()
        }
    }
    
    func setupAutoUpdateTimer() {
        autoUpateTimer?.invalidate()
        autoUpateTimer = nil
        guard RemoteConfigManager.autoUpdateEnable else {
            Logger.log("autoUpdateEnable did not enable,autoUpateTimer invalidated.")
            return
        }
        Logger.log("set up autoUpateTimer")
        let timeInterval: TimeInterval = 60 * 60 * 3 // Three hour
        autoUpateTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(autoUpdateCheck), userInfo: nil, repeats: true)
    }
    
    
    static var autoUpdateEnable:Bool {
        get {
            return UserDefaults.standard.object(forKey: "kAutoUpdateEnable") as? Bool ?? true
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "kAutoUpdateEnable")
            RemoteConfigManager.shared.setupAutoUpdateTimer()
        }
    }
    
    @objc func autoUpdateCheck() {
        guard RemoteConfigManager.autoUpdateEnable else {return}
        Logger.log("Tigger config auto update check")
        updateCheck()
    }
    
    func updateCheck(ignoreTimeLimit: Bool = false, showNotification: Bool = false) {
        let currentConfigName = ConfigManager.selectConfigName
        
        let group = DispatchGroup()
        
        for config in configs {
            if config.updating {continue}
            // 12hour check
            let timeLimitNoMantians = Date().timeIntervalSince(config.updateTime ?? Date(timeIntervalSince1970: 0)) < 60 * 60 * 12
            
            if timeLimitNoMantians && !ignoreTimeLimit {
                Logger.log("[Auto Upgrade] Bypassing \(config.name) due to time check")
                continue
            }
            Logger.log("[Auto Upgrade] Requesting \(config.name)")
            let isCurrentConfig = config.name == currentConfigName
            config.updating = true
            group.enter()
            RemoteConfigManager.updateConfig(config: config) {
                [weak config] error in
                guard let config = config else {return}
                
                config.updating = false
                group.leave()
                if error == nil {
                    config.updateTime = Date()
                }
                
                if isCurrentConfig {
                    if let error = error {
                        // Fail
                        if showNotification {
                            NSUserNotificationCenter.default
                                .post(title: NSLocalizedString("Remote Config Update Fail", comment: "") ,
                                      info: "\(config.name): \(error)")
                        }
                        
                    } else {
                        // Success
                        if showNotification {
                            let info = "\(config.name): \(NSLocalizedString("Succeed!", comment: ""))"
                            NSUserNotificationCenter.default
                                .post(title: NSLocalizedString("Remote Config Update", comment: ""), info:info)
                        }
                        NotificationCenter.default.post(name: kShouldUpDateConfig,
                                                        object: nil,
                                                        userInfo: ["notification": false])
                        RemoteConfigManager.didUpdateConfig()
                    }
                }
                Logger.log("[Auto Upgrade] Finish \(config.name) result: \(error ?? "succeed")")
            }
        }
        
        group.notify(queue: .main) {
            [weak self] in
            self?.saveConfigs()
        }
    }
    
    
    static func getRemoteConfigData(config: RemoteConfigModel, complete:@escaping ((Data?)->Void)) {
        guard var urlRequest = try? URLRequest(url: config.url, method: .get) else {
            assertionFailure()
            Logger.log("[getRemoteConfigData] url incorrect,\(config.name) \(config.url)")
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
                complete?(NSLocalizedString("Download fail", comment: "") )
                return
            }
            guard let newConfigString = String(data: newData, encoding: .utf8),
                verifyConfig(string: newConfigString) else {
                complete?(NSLocalizedString("Remote Config Format Error", comment: ""))
                return
            }
            let savePath = kConfigFolderPath.appending(config.name).appending(".yaml")

            if config.name == ConfigManager.selectConfigName {
                ConfigFileManager.shared.pauseForNextChange()
            }
            
            do {
                if FileManager.default.fileExists(atPath: savePath) {
                    try FileManager.default.removeItem(atPath: savePath)
                }
                try newData.write(to: URL(fileURLWithPath: savePath))
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
            Logger.log("error.localizedDescription)
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

