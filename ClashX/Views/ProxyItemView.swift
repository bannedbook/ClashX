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
    let imageView: NSImageView?

    static let fixedPlaceHolderWidth: CGFloat = 20 + 50 + 25

    init(name: ClashProxyName, selected: Bool, delay: String?) {
        nameLabel = VibrancyTextField(labelWithString: name)
        delayLabel = VibrancyTextField(labelWithString: delay ?? "")
        if selected {
            imageView = NSImageView(image: NSImage(named: NSImage.menuOnStateTemplateName)!)
        } else {
            imageView = nil
        }
        super.init(autolayout: false)
        effectView.addSubview(nameLabel)
        effectView.addSubview(delayLabel)
        if let imageView = imageView {
            effectView.addSubview(imageView)
        }

        imageView?.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        delayLabel.translatesAutoresizingMaskIntoConstraints = false

        nameLabel.font = type(of: self).labelFont
        delayLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        nameLabel.alignment = .left
        delayLabel.alignment = .right

//        delayLabel.wantsLayer = true
//        delayLabel.layer?.backgroundColor = NSColor.red.cgColor
    }

    override func layout() {
        super.layout()
        nameLabel.sizeToFit()
        delayLabel.sizeToFit()
        imageView?.frame = CGRect(x: 5, y: bounds.height / 2 - 6, width: 12, height: 12)
        nameLabel.frame = CGRect(x: 18,
                                 y: (bounds.height - nameLabel.bounds.height) / 2,
                                 width: nameLabel.bounds.width,
                                 height: nameLabel.bounds.height)
        delayLabel.frame = CGRect(x: bounds.width - delayLabel.bounds.width - 8,
                                  y: (bounds.height - delayLabel.bounds.height) / 2,
                                  width: delayLabel.bounds.width,
                                  height: delayLabel.bounds.height)
    }

    func update(delay: String?) {
        delayLabel.stringValue = delay ?? ""
        needsLayout = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didClickView() {
        (enclosingMenuItem as? ProxyMenuItem)?.didClick()
    }

    override var cells: [NSCell?] {
        return [nameLabel.cell, delayLabel.cell, imageView?.cell]
    }
}
