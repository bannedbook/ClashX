
import Foundation
import AppKit

class ProxyConfigHelperManager {
    static let kProxyConfigFolder = (NSHomeDirectory() as NSString).appendingPathComponent("/.config/clash")
    static let kVersion = "0.1.3"

    
    static func vaildHelper() -> Bool {
        let scriptPath = "\(Bundle.main.resourcePath!)/check_proxy_helper.sh"
        let appleScriptStr = "do shell script \"bash \\\"\(scriptPath)\\\" \(kProxyConfigFolder) \(kVersion) \" "
        let appleScript = NSAppleScript(source: appleScriptStr)
        var dict: NSDictionary?
        if let res = appleScript?.executeAndReturnError(&dict) {
            if (res.stringValue?.contains("success")) ?? false {
                return true
            }
        } else {
            Logger.log(msg: "\(String(describing: dict))",level: .error)
        }
        return false
        
    }

    static func install() -> Bool {
        checkConfigDir()
        checkMMDB()
        upgardeYmlExtensionName()
        checkAndRemoveOldErrorConfig()
        
        let proxyHelperPath = Bundle.main.path(forResource: "ProxyConfig", ofType: nil)
        let targetPath = "\(kProxyConfigFolder)/ProxyConfig"
        
       
        if !vaildHelper() {
            if (!showInstallHelperAlert()) {
                NSApplication.shared.terminate(nil)
            }
            
            if (FileManager.default.fileExists(atPath: targetPath)) {
                try? FileManager.default.removeItem(atPath: targetPath)
            }
            try? FileManager.default.copyItem(at: URL(fileURLWithPath: proxyHelperPath!), to: URL(fileURLWithPath: targetPath))

            let scriptPath = "\(Bundle.main.resourcePath!)/install_proxy_helper.sh"
            let appleScriptStr = "do shell script \"bash \(scriptPath) \(kProxyConfigFolder) \" with administrator privileges"
            let appleScript = NSAppleScript(source: appleScriptStr)
                        
            var dict: NSDictionary?
            if let _ = appleScript?.executeAndReturnError(&dict) {
                return true
            } else {
                return false
            }
        }
        return true
    }
    
    static func checkConfigDir() {
        var isDir : ObjCBool = true
        
        if !FileManager.default.fileExists(atPath: kProxyConfigFolder, isDirectory:&isDir) {
            do {
                try FileManager.default.createDirectory(atPath: kProxyConfigFolder, withIntermediateDirectories: true, attributes: nil)
            } catch {
                showCreateConfigDirFailAlert()
            }
        }
    }
    
    static func checkMMDB() {
        let fileManage = FileManager.default
        let destMMDBPath = "\(kProxyConfigFolder)/Country.mmdb"
        
        // Remove old mmdb file after version update.
        if fileManage.fileExists(atPath: destMMDBPath) {
            if AppVersionUtil.hasVersionChanged || AppVersionUtil.isFirstLaunch {
                try? fileManage.removeItem(atPath: destMMDBPath)
            }
        }
        
        
        if !fileManage.fileExists(atPath: destMMDBPath) {
            if let mmdbPath = Bundle.main.path(forResource: "Country", ofType: "mmdb") {
                try? fileManage.copyItem(at: URL(fileURLWithPath: mmdbPath), to: URL(fileURLWithPath: destMMDBPath))
            }
        }
    }
    
    static func checkAndRemoveOldErrorConfig() {
        if FileManager.default.fileExists(atPath: kDefaultConfigFilePath) {
            do {
                let defaultConfigData = try Data(contentsOf: URL(fileURLWithPath: kDefaultConfigFilePath))
                var checkSum: UInt8 = 0
                for byte in defaultConfigData {
                    checkSum &+= byte
                }
                
                if checkSum == 101 {
                    // old error config
                    Logger.log(msg: "removing old config.yaml")
                    try FileManager.default.removeItem(atPath: kDefaultConfigFilePath)
                }
            } catch let err {
                Logger.log(msg: "removing old config.yaml fail: \(err.localizedDescription)")
            }
        }
    }
    
    static func upgardeYmlExtensionName() {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: URL(fileURLWithPath: kConfigFolderPath, isDirectory: true), includingPropertiesForKeys: nil, options: [.skipsSubdirectoryDescendants])
            
            for upgradeUrl in fileURLs.filter({$0.pathExtension == "yml" }) {
                let dest = upgradeUrl.deletingPathExtension().appendingPathExtension("yaml")
                try FileManager.default.moveItem(at: upgradeUrl, to: dest)
            }
            
        } catch let err {
            Logger.log(msg: err.localizedDescription)
        }
        
    }
    
    static func setUpSystemProxy(port: Int?,socksPort: Int?) -> Bool {
        let task = Process()
        task.launchPath = "\(kProxyConfigFolder)/ProxyConfig"
        let hookTask:String?
        if let port = port,let socksPort = socksPort {
            hookTask = UserDefaults.standard.string(forKey: "kProxyEnableHook")
            task.arguments = [String(port),String(socksPort), "enable"]
        } else {
            hookTask = UserDefaults.standard.string(forKey: "kProxyDisableHook")
            task.arguments = ["0", "0", "disable"]
        }
        
        task.launch()
        
        task.waitUntilExit()
        
        if task.terminationStatus != 0 {
            return false
        }
        
        DispatchQueue.global().async {
            if let command = hookTask {
                let appleScriptStr = "do shell script \"\(command)\""
                let appleScript = NSAppleScript(source: appleScriptStr)
                _ = appleScript?.executeAndReturnError(nil)
            }
        }
        
        return true
    }
    
    static func showInstallHelperAlert() -> Bool{
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("ClashX needs to install a small tool to ~/.config/clash with administrator privileges to set system proxy quickly.\n\nOtherwise you need to type in the administrator password every time you change system proxy through ClashX.", comment: "")
        alert.alertStyle = .warning
        alert.addButton(withTitle: NSLocalizedString("Install", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Quit", comment: ""))
        return alert.runModal() == .alertFirstButtonReturn
    }
    
    static func showCreateConfigDirFailAlert() {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("ClashX fail to create ~/.config/clash folder. Please check privileges or manually create folder and restart ClashX.", comment: "")
        alert.alertStyle = .warning
        alert.addButton(withTitle: NSLocalizedString("Quit", comment: ""))
        alert.runModal()
        NSApplication.shared.terminate(nil)
    }

}
