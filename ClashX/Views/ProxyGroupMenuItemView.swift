//
//  ProxyGroupMenuItemView.swift
//  ClashX
//
//  Created by yicheng on 2019/10/16.
//  Copyright © 2019 west2online. All rights reserved.
//

import Cocoa

class ProxyGroupMenuItemView: MenuItemBaseView {
    let groupNameLabel: NSTextField
    let selectProxyLabel: NSTextField
    let arrowLabel = NSTextField(labelWithString: "▶")

    override var cells: [NSCell?] {
        return [groupNameLabel.cell, selectProxyLabel.cell, arrowLabel.cell]
    }

    init(group: ClashProxyName, targetProxy: ClashProxyName) {
        groupNameLabel = VibrancyTextField(labelWithString: group)
        selectProxyLabel = VibrancyTextField(labelWithString: targetProxy)
        super.init(autolayout: true)

        // arrow
        effectView.addSubview(arrowLabel)
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowLabel.rightAnchor.constraint(equalTo: effectView.rightAnchor, constant: -10).isActive = true
        arrowLabel.centerYAnchor.constraint(equalTo: effectView.centerYAnchor).isActive = true
        arrowLabel.setContentHuggingPriority(.required, for: .horizontal)
        arrowLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        // group
        groupNameLabel.translatesAutoresizingMaskIntoConstraints = false
        effectView.addSubview(groupNameLabel)
        groupNameLabel.leftAnchor.constraint(equalTo: effectView.leftAnchor, constant: 20).isActive = true
        groupNameLabel.centerYAnchor.constraint(equalTo: effectView.centerYAnchor).isActive = true
        groupNameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        // select
        selectProxyLabel.translatesAutoresizingMaskIntoConstraints = false
        effectView.addSubview(selectProxyLabel)
        selectProxyLabel.rightAnchor.constraint(equalTo: effectView.rightAnchor, constant: -30).isActive = true
        selectProxyLabel.centerYAnchor.constraint(equalTo: effectView.centerYAnchor).isActive = true
        selectProxyLabel.lineBreakMode = .byTruncatingHead

        // space
        selectProxyLabel.leftAnchor.constraint(greaterThanOrEqualTo: groupNameLabel.rightAnchor, constant: 20).isActive = true

        // max
        effectView.widthAnchor.constraint(lessThanOrEqualToConstant: 330).isActive = true
        // font & color
        groupNameLabel.font = type(of: self).labelFont
        selectProxyLabel.font = type(of: self).labelFont
        groupNameLabel.textColor = NSColor.labelColor
        selectProxyLabel.textColor = NSColor.secondaryLabelColor
        arrowLabel.textColor = NSColor.labelColor

        // noti
        NotificationCenter.default.addObserver(self, selector: #selector(proxyInfoDidUpdate(note:)), name: .proxyUpdate(for: group), object: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func proxyInfoDidUpdate(note: NSNotification) {
        guard let info = note.object as? ClashProxy else { assertionFailure(); return }
        selectProxyLabel.stringValue = info.now ?? ""
    }
}

extension ProxyGroupMenuItemView: ProxyGroupMenuHighlightDelegate {
    func highlight(item: NSMenuItem?) {
        isHighlighted = item == enclosingMenuItem
    }
}
