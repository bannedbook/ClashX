//
//  ClashWindowController.swift
//  ClashX
//
//  Created by yicheng on 2023/7/5.
//  Copyright © 2023 west2online. All rights reserved.
//
import AppKit

private class ClashWindowsRecorder {
    static let shared = ClashWindowsRecorder()
    var windowControllers = [NSWindowController]() {
        didSet {
            if windowControllers.isEmpty {
                NSApp.setActivationPolicy(.accessory)
            } else {
                if NSApp.activationPolicy() == .accessory {
                    NSApp.setActivationPolicy(.regular)
                }
            }
        }
    }
}

class ClashWindowController<T: NSViewController>: NSWindowController, NSWindowDelegate {
    var onWindowClose: (() -> Void)?
    var lastSize: CGSize? {
        get {
            if let str = UserDefaults.standard.value(forKey: "lastSize.\(T.className())") as? String {
                return NSSizeFromString(str) as CGSize
            }
            return nil
        }
        set {
            if let size = newValue {
                UserDefaults.standard.set(NSStringFromSize(size), forKey: "lastSize.\(T.className())")
            }
        }
    }

    static func create() -> NSWindowController {
        if let wc = ClashWindowsRecorder.shared.windowControllers.first(where: {$0 is Self}) {
            return wc
        }
        let win = NSWindow()
        let wc = ClashWindowController(window: win)
        wc.contentViewController = T()
        win.titlebarAppearsTransparent = false
        ClashWindowsRecorder.shared.windowControllers.append(wc)
        return wc
    }

    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        NSApp.activate(ignoringOtherApps: true)
        if let lastSize = lastSize, lastSize != .zero {
            window?.setContentSize(lastSize)
        }
        window?.center()
        window?.makeKeyAndOrderFront(self)
        window?.delegate = self
    }

    func windowWillClose(_ notification: Notification) {
        ClashWindowsRecorder.shared.windowControllers.removeAll(where: {$0 == self})
        onWindowClose?()
        if let win = window {
            if !win.styleMask.contains(.fullScreen) {
                lastSize = win.frame.size
            }
        }
    }
}
