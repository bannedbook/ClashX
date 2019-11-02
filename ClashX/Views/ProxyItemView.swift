//
//  ProxyItemView.swift
//  ClashX
//
//  Created by yicheng on 2019/11/2.
//  Copyright © 2019 west2online. All rights reserved.
//

import Cocoa

class ProxyItemView: MenuItemBaseView {
    let nameLabel: NSTextField
    let delayLabel: NSTextField

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init(name: ClashProxyName, history: ClashProxySpeedHistory) {
        nameLabel = VibrancyTextField(labelWithString: name)
        delayLabel = VibrancyTextField(labelWithString: history.delayDisplay)
        super.init(handleClick: true, autolayout: true)
        effectView.addSubview(nameLabel)
        effectView.addSubview(delayLabel)

        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        delayLabel.translatesAutoresizingMaskIntoConstraints = false

        delayLabel.centerYAnchor.constraint(equalTo: effectView.centerYAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: effectView.centerYAnchor).isActive = true

        delayLabel.rightAnchor.constraint(equalTo: effectView.rightAnchor, constant: -15).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: effectView.leftAnchor, constant: 20).isActive = true

        delayLabel.leftAnchor.constraint(greaterThanOrEqualTo: nameLabel.rightAnchor, constant: 30).isActive = true

        nameLabel.font = type(of: self).labelFont
        delayLabel.font = NSFont.menuFont(ofSize: 13)
    }

    override func didClickView() {
        enclosingMenuItem?.menu?.cancelTracking()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var labels: [NSTextField] {
        return [nameLabel, delayLabel]
    }
}
