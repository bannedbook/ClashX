//
//  ProxyModeChangeCommand.swift
//  ClashX
//
//  Created by Vince-hz on 2022/1/25.
//  Copyright © 2022 west2online. All rights reserved.
//

import Foundation
import AppKit

@objc class ProxyModeChangeCommand: NSScriptCommand {
    override func performDefaultImplementation() -> Any? {
        guard let directParameter = directParameter as? String,
              let mode = ClashProxyMode(rawValue: directParameter)
        else {
            scriptErrorNumber = -1
            scriptErrorString = "please enter a valid parameter. rule, global or direct"
            return nil
        }
        guard let delegate = NSApplication.shared.delegate as? AppDelegate else {
            scriptErrorNumber = -2
            scriptErrorString = "can't get application, try again later"
            return nil
        }
        let menuItem: NSMenuItem
        switch mode {
        case .rule:
            menuItem = delegate.proxyModeRuleMenuItem
        case .global:
            menuItem = delegate.proxyModeGlobalMenuItem
        case .direct:
            menuItem = delegate.proxyModeDirectMenuItem
        }
        delegate.actionSwitchProxyMode(menuItem)
        return nil
    }
}
