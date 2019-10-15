//
//  NetworkChangeNotifier.swift
//  ClashX
//
//  Created by yicheng on 2019/10/15.
//  Copyright © 2019 west2online. All rights reserved.
//

import Cocoa
import SystemConfiguration


class NetworkChangeNotifier {
    
    
    static func start() {
        let changed: SCDynamicStoreCallBack = { dynamicStore, _, _ in
            NotificationCenter.default.post(name: kSystemNetworkStatusDidChange, object: nil)
        }
        var dynamicContext = SCDynamicStoreContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
        let dcAddress = withUnsafeMutablePointer(to: &dynamicContext, {UnsafeMutablePointer<SCDynamicStoreContext>($0)})
        
        if let dynamicStore = SCDynamicStoreCreate(kCFAllocatorDefault, "com.clashx.networknotification" as CFString, changed, dcAddress) {
            let keysArray = ["State:/Network/Global/Proxies" as CFString] as CFArray
            SCDynamicStoreSetNotificationKeys(dynamicStore, nil, keysArray)
            let loop = SCDynamicStoreCreateRunLoopSource(kCFAllocatorDefault, dynamicStore, 0)
            CFRunLoopAddSource(CFRunLoopGetCurrent(), loop, .defaultMode)
            CFRunLoopRun()
        }
    }
    
    static func currentSystemProxySetting() -> (UInt,UInt,UInt)? {
        let proxiesSetting = CFNetworkCopySystemProxySettings()?.takeRetainedValue() as! [String:AnyObject]
        guard let httpProxy = proxiesSetting[kCFNetworkProxiesHTTPPort as String] as? UInt,
            let socksProxy = proxiesSetting[kCFNetworkProxiesSOCKSPort as String]as? UInt,
            let httpsProxy = proxiesSetting[kCFNetworkProxiesHTTPSPort as String]as? UInt else {return nil}
        return (httpProxy,httpsProxy,socksProxy)
    }
}
