//
//  AppVersionUtil.swift
//  ClashX
//
//  Created by CYC on 2019/2/18.
//  Copyright © 2019 west2online. All rights reserved.
//

import Cocoa

class AppVersionUtil: NSObject {
    private static let shared = AppVersionUtil()
    
    static private let kLastVersionNumberKey = "com.clashX.lastVersionNumber"
    
    private let lastVersionNumber:String?
    
    static var currentVersion:String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    }
    
    static var currentBuild:String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
    }
    
    override init() {
        lastVersionNumber = UserDefaults.standard.string(forKey: AppVersionUtil.kLastVersionNumberKey)
        UserDefaults.standard.set(AppVersionUtil.currentVersion, forKey: AppVersionUtil.kLastVersionNumberKey)
    }
    
    static var isFirstLaunch:Bool {
        return shared.lastVersionNumber == nil
    }
    
    static var hasVersionChanged:Bool {
        return shared.lastVersionNumber != currentVersion
    }
    
}
