//
//  NSImage+extension.swift
//  ClashX
//
//  Created by CYC on 2018/8/6.
//  Copyright © 2018年 yichengchen. All rights reserved.
//

import AppKit
import Foundation

extension NSImage {
    func tint(color: NSColor) -> NSImage {
        let image = copy() as! NSImage
        image.lockFocus()

        color.set()

        let imageRect = NSRect(origin: NSZeroPoint, size: image.size)
        imageRect.fill(using: .sourceIn)

        image.unlockFocus()
        image.isTemplate = false

        return image
    }
}
