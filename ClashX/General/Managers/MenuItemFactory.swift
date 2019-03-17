//
//  MenuItemFactory.swift
//  ClashX
//
//  Created by CYC on 2018/8/4.
//  Copyright © 2018年 yichengchen. All rights reserved.
//

import Cocoa
import SwiftyJSON
import RxCocoa

class MenuItemFactory {
    static func menuItems(completionHandler:@escaping (([NSMenuItem])->())){
        ApiRequest.requestProxyGroupList { (proxies) in
            var menuItems = [NSMenuItem]()
            if (ConfigManager.shared.currentConfig?.mode == .direct) {
                completionHandler(menuItems)
                return
            }
            for proxy in proxies.sorted(by: {  $0.name < $1.name}) {
                var menu:NSMenuItem?
                switch proxy.type {
                case .select: menu = self.generateSelectorMenuItem(proxyGroup: proxy) {
                    proxyName in
                    proxies.filter{$0.name == proxyName}.first?.type == .select
                    }
                case .urltest,.fallback: menu = generateUrlTestMenuItem(proxyGroup: proxy)
                case .loadBalance:
                    menu = generateLoadBalanceMenuItem(proxyGroup: proxy)
                default: continue
                }
                if let menu = menu {menuItems.append(menu)}
                
            }
            completionHandler(menuItems.reversed())
        }
    }
    
    static func generateSelectorMenuItem(proxyGroup:ClashProxy,proxyIsSelectGroup:((ClashProxyName)->Bool))->NSMenuItem? {
        let isGlobalMode = ConfigManager.shared.currentConfig?.mode == .global
        if (isGlobalMode) {
            if proxyGroup.name != "GLOBAL" {return nil}
        } else {
            if proxyGroup.name == "GLOBAL" {return nil}
        }
        
        let menu = NSMenuItem(title: proxyGroup.name, action: nil, keyEquivalent: "")
        let selectedName = proxyGroup.now ?? ""
        let submenu = NSMenu(title: proxyGroup.name)
        var hasSelected = false
        submenu.minimumWidth = 20
        for proxy in proxyGroup.all ?? []{
            if isGlobalMode && proxyIsSelectGroup(proxy) {
                continue
            }
            
            let proxyItem = ProxyMenuItem(proxyName: proxy, action: #selector(MenuItemFactory.actionSelectProxy(sender:)))
                
            proxyItem.target = MenuItemFactory.self
            proxyItem.isSelected = proxy == selectedName

            let fittitingWidth = proxyItem.suggestWidth()
            if fittitingWidth > submenu.minimumWidth {
                submenu.minimumWidth = fittitingWidth
            }
            
            if proxyItem.isSelected {hasSelected = true}
            submenu.addItem(proxyItem)
            submenu.autoenablesItems = false
            
        }
        for item in submenu.items {
            item.view?.frame.size.width = submenu.minimumWidth
        }
        menu.submenu = submenu
        if (!hasSelected && submenu.items.count>0) {
            self.actionSelectProxy(sender: submenu.items[0] as! ProxyMenuItem)
        }
        return menu
    }
    
    static func generateUrlTestMenuItem(proxyGroup:ClashProxy)->NSMenuItem? {
        
        let menu = NSMenuItem(title: proxyGroup.name, action: nil, keyEquivalent: "")
        let selectedName = proxyGroup.now ?? ""
        let submenu = NSMenu(title: proxyGroup.name)

        let nowMenuItem = NSMenuItem(title: "now:\(selectedName)", action: nil, keyEquivalent: "")
        
        submenu.addItem(nowMenuItem)
        menu.submenu = submenu
        return menu
    }
    
    static func generateLoadBalanceMenuItem(proxyGroup:ClashProxy)->NSMenuItem? {
        let menu = NSMenuItem(title: proxyGroup.name, action: nil, keyEquivalent: "")
        let submenu = NSMenu(title: proxyGroup.name)
        
        for proxy in proxyGroup.all ?? [] {
            let proxyItem = ProxyMenuItem(proxyName: proxy, action:nil)
            let fittitingWidth = proxyItem.suggestWidth()
            if fittitingWidth > submenu.minimumWidth {
                submenu.minimumWidth = fittitingWidth
            }
            proxyItem.isSelected = false
            submenu.addItem(proxyItem)
        }
        
        for item in submenu.items {
            item.view?.frame.size.width = submenu.minimumWidth
        }
        menu.submenu = submenu
        
        return menu
    }
   
    static func generateSwitchConfigSubMenu() -> NSMenu {
        let subMenu = NSMenu(title: "Switch Configs")
        for config in ConfigManager.getConfigFilesList() {
            let item = NSMenuItem(title: config, action: #selector(MenuItemFactory.actionSelectConfig(sender:)), keyEquivalent: "")
            item.target = MenuItemFactory.self
            item.state = ConfigManager.selectConfigName == config ? .on : .off
            subMenu.addItem(item)
        }
        return subMenu
    }
}


extension MenuItemFactory {
    @objc static func actionSelectProxy(sender:ProxyMenuItem){
        guard let proxyGroup = sender.menu?.title else {return}
        let proxyName = sender.proxyName
        
        ApiRequest.updateProxyGroup(group: proxyGroup, selectProxy: proxyName) { (success) in
            if (success) {
                for items in sender.menu?.items ?? [NSMenuItem]() {
                    items.state = .off
                }
                sender.state = .on
                // remember select proxy
                ConfigManager.selectedProxyMap[proxyGroup] = proxyName
            }
        }
    }
    
    
    @objc static func actionSelectConfig(sender:NSMenuItem){
        let config = sender.title
        ConfigManager.selectConfigName = config
        NotificationCenter.default.post(Notification(name: kShouldUpDateConfig))
    }
}

