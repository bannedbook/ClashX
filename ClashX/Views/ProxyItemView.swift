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

    init(name: ClashProxyName, selected: Bool, delay: String?) {
        nameLabel = VibrancyTextField(labelWithString: name)
        delayLabel = VibrancyTextField(labelWithString: delay ?? "       ")
        if selected {
            imageView = NSImageView(image: NSImage(named: NSImage.menuOnStateTemplateName)!)
        } else {
            imageView = nil
        }
        super.init(autolayout: true)
        effectView.addSubview(nameLabel)
        effectView.addSubview(delayLabel)
        if let imageView = imageView {
            effectView.addSubview(imageView)
        }

        imageView?.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        delayLabel.translatesAutoresizingMaskIntoConstraints = false

        delayLabel.centerYAnchor.constraint(equalTo: effectView.centerYAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: effectView.centerYAnchor).isActive = true
        imageView?.centerYAnchor.constraint(equalTo: effectView.centerYAnchor).isActive = true

        delayLabel.rightAnchor.constraint(equalTo: effectView.rightAnchor, constant: -15).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: effectView.leftAnchor, constant: 25).isActive = true
        imageView?.leftAnchor.constraint(equalTo: effectView.leftAnchor, constant: 8).isActive = true

        delayLabel.leftAnchor.constraint(greaterThanOrEqualTo: nameLabel.rightAnchor, constant: 30).isActive = true

        nameLabel.font = type(of: self).labelFont
        delayLabel.font = NSFont.menuBarFont(ofSize: 12)
    }

    func update(delay: String?) {
        delayLabel.stringValue = delay ?? "       "
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
