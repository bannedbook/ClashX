//
//  ProxyGroupMenuItemView.swift
//  ClashX
//
//  Created by yicheng on 2019/10/16.
//  Copyright © 2019 west2online. All rights reserved.
//

import Cocoa

class ProxyGroupMenuItemView: NSView {
    let groupNameLabel: NSTextField
    let selectProxyLabel: NSTextField
    let arrowImageView = NSTextField(labelWithString: "▶")
    init(group: ClashProxyName, targetProxy: ClashProxyName) {
        groupNameLabel = NSTextField(labelWithString: group)
        selectProxyLabel = NSTextField(labelWithString: targetProxy)
        if #available(macOS 10.15, *) {
            super.init(frame: .zero)
        } else {
            super.init(frame: NSRect(x: 0, y: 0, width: 0, height: 20))
        }
        // self
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 20).isActive = true

        // arrow
        addSubview(arrowImageView)
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        arrowImageView.rightAnchor.constraint(equalTo: rightAnchor, constant: -10).isActive = true
        arrowImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        // group
        groupNameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(groupNameLabel)
        groupNameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        groupNameLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        // select
        selectProxyLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectProxyLabel)
        selectProxyLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -30).isActive = true
        selectProxyLabel.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        // space
        selectProxyLabel.leftAnchor.constraint(greaterThanOrEqualTo: groupNameLabel.rightAnchor, constant: 30).isActive = true

        // font
        let font = NSFont.menuFont(ofSize: 14)
        groupNameLabel.font = font
        selectProxyLabel.font = font
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidMoveToSuperview() {
        super.viewDidMoveToSuperview()
        if #available(macOS 10.15, *) {} else {
            if let view = superview {
                view.autoresizingMask = [.width]
            }
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard let menu = enclosingMenuItem else { return }
        if menu.isHighlighted {
            NSColor.selectedMenuItemColor.setFill()
            groupNameLabel.textColor = NSColor.white
            selectProxyLabel.textColor = NSColor.white
            arrowImageView.textColor = NSColor.white
        } else {
            NSColor.clear.setFill()
            groupNameLabel.textColor = NSColor.labelColor
            arrowImageView.textColor = NSColor.labelColor
            selectProxyLabel.textColor = NSColor.gray
        }
        dirtyRect.fill()
    }
}
