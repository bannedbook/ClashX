//
//  NSUserNotificationCenter+Extension.swift
//  ClashX
//
//  Created by CYC on 2018/8/6.
//  Copyright © 2018年 yichengchen. All rights reserved.
//

import Cocoa

extension NSUserNotificationCenter {
    func post(title:String,info:String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = info
        self.deliver(notification)
    }
    
    func postGenerateSimpleConfigNotice() {
        self.post(title: "No External-controller specified in config file!", info: "We have replace current config with a simple config with external-controller specified!")
    }
}
