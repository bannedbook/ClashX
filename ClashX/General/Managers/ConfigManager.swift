//
//  ConfigManager.swift
//  ClashX
//
//  Created by CYC on 2018/6/12.
//  Copyright © 2018年 yichengchen. All rights reserved.
//

import Foundation
import Cocoa
import RxSwift
import RxCocoa

class ConfigManager {
    
    static let shared = ConfigManager()
    private let disposeBag = DisposeBag()
    var apiPort = "8080"
    var apiSecret:String = ""
    
    init() {
        UserDefaults.standard.rx.observe(Bool.self, "kSDisableShowCurrentProxyInMenu").bind {
            [weak self] disable in
            self?.disableShowCurrentProxyInMenu = disable ?? false
        }.disposed(by: disposeBag)
    }
    
    var currentConfig: ClashConfig?{
        get {
            return currentConfigVariable.value
        }
        
        set {
            currentConfigVariable.accept(newValue)
        }
    }
    var currentConfigVariable = BehaviorRelay<ClashConfig?>(value: nil)
    
    var isRunning: Bool{
        get {
            return isRunningVariable.value
        }
        
        set {
            isRunningVariable.accept(newValue)
        }
    }
    
    var disableShowCurrentProxyInMenu = false
    
    static var selectConfigName:String{
        get {
            if shared.isRunning {
                return UserDefaults.standard.string(forKey: "selectConfigName") ?? "config"
            }
            return "config"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectConfigName")
            ConfigFileManager.shared.watchConfigFile(configName: newValue)
        }
    }
    
    var isRunningVariable = BehaviorRelay<Bool>(value: false)
    
    var proxyPortAutoSet:Bool {
        get{
            return UserDefaults.standard.bool(forKey: "proxyPortAutoSet")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "proxyPortAutoSet")
        }
    }
    let proxyPortAutoSetObservable = UserDefaults.standard.rx.observe(Bool.self, "proxyPortAutoSet")
    
    var showNetSpeedIndicator:Bool {
        get{
            return UserDefaults.standard.bool(forKey: "showNetSpeedIndicator")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "showNetSpeedIndicator")
        }
    }
    let showNetSpeedIndicatorObservable = UserDefaults.standard.rx.observe(Bool.self, "showNetSpeedIndicator")
    
    static var apiUrl:String{
        return "http://127.0.0.1:\(shared.apiPort)"
    }
    
    static var webSocketUrl: String {
        return "ws://127.0.0.1:\(shared.apiPort)"
    }
    
    
    static var selectedProxyMap:[String:String] {
        get{
            let map = UserDefaults.standard.dictionary(forKey: "selectedProxyMap") as? [String:String] ?? ["Proxy":"ProxyAuto"]
            return map.count == 0 ? ["Proxy":"ProxyAuto"] : map
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "selectedProxyMap")
        }
    }
    
    static var selectOutBoundMode:ClashProxyMode {
        get{
            return ClashProxyMode(rawValue: UserDefaults.standard.string(forKey: "selectOutBoundMode") ?? "") ?? .rule
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectOutBoundMode")
        }
    }
    
    static var allowConnectFromLan:Bool {
        get{
            return UserDefaults.standard.bool(forKey: "allowConnectFromLan")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "allowConnectFromLan")
        }
    }
    
    static var selectLoggingApiLevel:ClashLogLevel {
        get{
            return ClashLogLevel(rawValue: UserDefaults.standard.string(forKey: "selectLoggingApiLevel") ?? "") ?? .info
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectLoggingApiLevel")
        }
    }
    
    static var developerMode = UserDefaults.standard.bool(forKey: "kDeveloperMode")
    
}

extension ConfigManager {
    static func getConfigFilesList()->[String] {
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(atPath: kConfigFolderPath)
            return fileURLs
                .filter { String($0.split(separator: ".").last ?? "") == "yaml"}
                .map{$0.split(separator: ".").dropLast().joined(separator: ".")}
        } catch {
            return ["config"]
        }
    }
}
