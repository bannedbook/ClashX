//
//  StatusItemView.swift
//  ClashX
//
//  Created by CYC on 2018/6/23.
//  Copyright © 2018年 yichengchen. All rights reserved.
//

import AppKit
import Foundation
import RxCocoa
import RxSwift

class StatusItemView: NSView, StatusItemViewProtocol {
    @IBOutlet var imageView: NSImageView!

    @IBOutlet var uploadSpeedLabel: NSTextField!
    @IBOutlet var downloadSpeedLabel: NSTextField!
    @IBOutlet var speedContainerView: NSView!

    weak var statusItem: NSStatusItem?

    static func create(statusItem: NSStatusItem?) -> StatusItemView {
        var topLevelObjects: NSArray?
        if Bundle.main.loadNibNamed("StatusItemView", owner: self, topLevelObjects: &topLevelObjects) {
            let view = (topLevelObjects!.first(where: { $0 is NSView }) as? StatusItemView)!
            view.statusItem = statusItem
            view.setupView()
            return view
        }
        return NSView() as! StatusItemView
    }

    func setupView() {
        uploadSpeedLabel.font = StatusItemTool.font
        downloadSpeedLabel.font = StatusItemTool.font

        uploadSpeedLabel.textColor = NSColor.black
        downloadSpeedLabel.textColor = NSColor.black
    }

    func updateSize(width: CGFloat) {
        frame = CGRect(x: 0, y: 0, width: width, height: 22)
    }

    func updateViewStatus(enableProxy: Bool) {
        let selectedColor = NSColor.red
        let unselectedColor = selectedColor.withSystemEffect(.disabled)
        imageView.image = StatusItemTool.menuImage.tint(color: enableProxy ? selectedColor : unselectedColor)
        updateStatusItemView()
    }

    func updateSpeedLabel(up: Int, down: Int) {
        guard !speedContainerView.isHidden else { return }
        let finalUpStr = SpeedUtils.getSpeedString(for: up)
        let finalDownStr = SpeedUtils.getSpeedString(for: down)

        if downloadSpeedLabel.stringValue == finalDownStr && uploadSpeedLabel.stringValue == finalUpStr {
            return
        }
        downloadSpeedLabel.stringValue = finalDownStr
        uploadSpeedLabel.stringValue = finalUpStr
        updateStatusItemView()
    }

    func showSpeedContainer(show: Bool) {
        speedContainerView.isHidden = !show
        updateStatusItemView()
    }

    func updateStatusItemView() {
        statusItem?.updateImage(withView: self)
    }
}

extension NSStatusItem {
    func updateImage(withView view: NSView) {
        if let rep = view.bitmapImageRepForCachingDisplay(in: view.bounds) {
            view.cacheDisplay(in: view.bounds, to: rep)
            let img = NSImage(size: view.bounds.size)
            img.addRepresentation(rep)
            img.isTemplate = true
            button?.image = img
        } else {
            Logger.log("generate status menu icon fail", level: .error)
        }
    }
}
