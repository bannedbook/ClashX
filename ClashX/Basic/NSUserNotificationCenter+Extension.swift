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
}
