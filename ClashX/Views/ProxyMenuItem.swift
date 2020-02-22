//
//  ProxyMenuItem.swift
//  ClashX
//
//  Created by CYC on 2019/2/18.
//  Copyright © 2019 west2online. All rights reserved.
//

import Cocoa

class ProxyMenuItem: NSMenuItem {
    let proxyName: String

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init(proxy: ClashProxy,
         action selector: Selector?,
         selected: Bool) {
        proxyName = proxy.name
        super.init(title: proxyName, action: selector, keyEquivalent: "")
        view = ProxyItemView(name: proxyName, selected: selected, delay: proxy.history.last?.delayDisplay)
        NotificationCenter.default.addObserver(self, selector: #selector(updateDelayNotification(note:)), name: kSpeedTestFinishForProxy, object: nil)
    }

    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func didClick() {
        if let action = action {
            _ = target?.perform(action, with: self)
        }
        menu?.cancelTracking()
    }

    @objc private func updateDelayNotification(note: Notification) {
        guard let name = note.userInfo?["proxyName"] as? String, name == proxyName else {
            return
        }
        if let delay = note.userInfo?["delay"] as? String {
            (view as? ProxyItemView)?.update(delay: delay)
        }
    }
}

extension ProxyMenuItem: ProxyGroupMenuHighlightDelegate {
    func highlight(item: NSMenuItem?) {
        (view as? ProxyItemView)?.isHighlighted = item == self
    }
}
