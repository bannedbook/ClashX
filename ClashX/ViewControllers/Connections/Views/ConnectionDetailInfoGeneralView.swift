//
//  ConnectionDetailInfoGeneralView.swift
//  ClashX
//
//  Created by yicheng on 2023/7/8.
//  Copyright © 2023 west2online. All rights reserved.
//

import Cocoa

class ConnectionDetailInfoGeneralView: NSView, NibLoadable {

    @IBOutlet weak var entryLabel: NSTextField!
    @IBOutlet weak var networkTypeLabel: NSTextField!
    @IBOutlet weak var totalUploadLabel: NSTextField!
    @IBOutlet weak var totalDownloadLabel: NSTextField!
    @IBOutlet weak var maxUploadLabel: NSTextField!
    @IBOutlet weak var maxDownloadLabel: NSTextField!
    @IBOutlet weak var currentUploadLabel: NSTextField!
    @IBOutlet weak var currentDownloadLabel: NSTextField!

    @IBOutlet weak var ruleLabel: NSTextField!
    @IBOutlet weak var proxyChainLabel: NSTextField!
    @IBOutlet weak var otherTextView: NSTextView!
    @IBOutlet weak var sourceIpLabel: NSTextField!
    @IBOutlet weak var destLabel: NSTextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        otherTextView.backgroundColor = NSColor.clear
        otherTextView.font = NSFont.systemFont(ofSize: 10)
    }
}
