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

class StatusItemView: NSView {
    @IBOutlet var imageView: NSImageView!

    @IBOutlet var uploadSpeedLabel: NSTextField!
    @IBOutlet var downloadSpeedLabel: NSTextField!
    @IBOutlet var speedContainerView: NSView!
    var updating = false

    weak var statusItem: NSStatusItem?

    lazy var menuImage: NSImage = {
        let customImagePath = (NSHomeDirectory() as NSString).appendingPathComponent("/.config/clash/menuImage.png")
        return NSImage(contentsOfFile: customImagePath) ?? NSImage(named: "menu_icon")!
    }()

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
        if #available(OSX 10.11, *) {
            let font = NSFont.systemFont(ofSize: 9, weight: .regular)
            uploadSpeedLabel.font = font
            downloadSpeedLabel.font = font
        }
    }

    func updateViewStatus(enableProxy: Bool) {
        let selectedColor = NSColor.red
        let unselectedColor: NSColor
        if #available(OSX 10.14, *) {
            unselectedColor = selectedColor.withSystemEffect(.disabled)
        } else {
            unselectedColor = selectedColor.withAlphaComponent(0.5)
        }

        imageView.image = menuImage.tint(color: enableProxy ? selectedColor : unselectedColor)
        uploadSpeedLabel.textColor = NSColor.black
        downloadSpeedLabel.textColor = uploadSpeedLabel.textColor
        updateStatusItemView()
    }

    func updateSpeedLabel(up: Int, down: Int) {
        guard !speedContainerView.isHidden else { return }

        let kbup = up / 1024
        let kbdown = down / 1024
        var finalUpStr: String
        var finalDownStr: String
        if kbup < 1024 {
            finalUpStr = "\(kbup)KB/s"
        } else {
            finalUpStr = String(format: "%.2fMB/s", Double(kbup) / 1024.0)
        }

        if kbdown < 1024 {
            finalDownStr = "\(kbdown)KB/s"
        } else {
            finalDownStr = String(format: "%.2fMB/s", Double(kbdown) / 1024.0)
        }
        DispatchQueue.main.async {
            self.downloadSpeedLabel.stringValue = finalDownStr
            self.uploadSpeedLabel.stringValue = finalUpStr
            if self.updating { Logger.log("update during update"); return }
            self.updating = true
            self.updateStatusItemView()
            self.updating = false
        }
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
    func updateImage(withView: NSView) {
        image = NSImage(data: withView.dataWithPDF(inside: withView.bounds))
        image?.isTemplate = true
    }
}
