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
    init(group:ClashProxy) {
        proxyGroup = group
        super.init(title: "", action: nil, keyEquivalent: "")
        view = ProxyGroupSpeedTestMenuItemView()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate class ProxyGroupSpeedTestMenuItemView: NSView {
    let label: NSTextField
    init() {
        label = NSTextField(labelWithString: NSLocalizedString("Benchmark", comment: ""))
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 20).isActive = true
        addSubview(label)
        label.font = NSFont.menuFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func startBenchmark() {
        guard let group = (enclosingMenuItem as? ProxyGroupSpeedTestMenuItem)?.proxyGroup else {return}
        for proxyName in group.speedtestAble {
            ApiRequest.getProxyDelay(proxyName: proxyName) { delay in
                let delayStr = delay == 0 ? "fail" : "\(delay) ms"
                NotificationCenter.default.post(name: kSpeedTestFinishForProxy,
                                                object: nil,
                                                userInfo: ["proxyName": proxyName,"delay": delayStr])
            }
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        startBenchmark()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let menu = enclosingMenuItem else {return}
        if menu.isHighlighted {
            NSColor.selectedMenuItemColor.setFill()
            label.textColor = NSColor.white
        } else {
            NSColor.clear.setFill()
            label.textColor = NSColor.labelColor
        }
        dirtyRect.fill()
    }
}
