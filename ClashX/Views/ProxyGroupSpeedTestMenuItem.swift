//
//  ProxyGroupSpeedTestMenuItem.swift
//  ClashX
//
//  Created by yicheng on 2019/10/15.
//  Copyright © 2019 west2online. All rights reserved.
//

import Cocoa

class ProxyGroupSpeedTestMenuItem: NSMenuItem {
    var proxyGroup: ClashProxy
    init(group:ClashProxy, selector: Selector?, name: String = NSLocalizedString("SpeedTest", comment: "")) {
        proxyGroup = group
        super.init(title: name, action: selector, keyEquivalent: "")
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
