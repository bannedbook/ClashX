//
//  AutoUpgardeManager.swift
//  ClashX
//
//  Created by yicheng on 2019/10/28.
//  Copyright © 2019 west2online. All rights reserved.
//

import Cocoa
import Sparkle

class AutoUpgardeManager: NSObject {
    var checkForUpdatesMenuItem: NSMenuItem?
    static let shared = AutoUpgardeManager()
    private var controller:SPUStandardUpdaterController?
    private var current: Channel = {
        if let value = UserDefaults.standard.object(forKey: "AutoUpgardeManager.current") as? Int,
            let channel = Channel(rawValue: value) { return channel }
        return .stable
    }() {
        didSet {
            UserDefaults.standard.set(current.rawValue, forKey: "AutoUpgardeManager.current")
        }
    }

    private lazy var menuItems: [Channel: NSMenuItem] = {
        var items = [Channel: NSMenuItem]()
        for channel in Channel.allCases {
            let item = NSMenuItem(title: channel.title, action: #selector(didSelectUpgradeChannel(_:)), keyEquivalent: "")
            item.target = self
            item.tag = channel.rawValue
            items[channel] = item
        }
        return items
    }()

    private var allowSelectChannel: Bool {
        return Bundle.main.object(forInfoDictionaryKey: "SUDisallowSelectChannel") as? Bool != true
    }

    // MARK: Public
    func setup() {
        controller = SPUStandardUpdaterController(updaterDelegate: self, userDriverDelegate: nil)
    }

    func setupCheckForUpdatesMenuItem(_ item: NSMenuItem) {
        checkForUpdatesMenuItem = item
        checkForUpdatesMenuItem?.target = controller
        checkForUpdatesMenuItem?.action = #selector(SPUStandardUpdaterController.checkForUpdates(_:))
    }

    func addChanelMenuItem(_ menu: inout NSMenu) {
        guard WebPortalManager.hasWebProtal == false, allowSelectChannel else { return }
        let upgradeMenu = NSMenu(title: NSLocalizedString("Upgrade Channel", comment: ""))
        for (_, item) in menuItems {
            upgradeMenu.addItem(item)
        }

        let upgradeMenuItem = NSMenuItem(title: NSLocalizedString("Upgrade Channel", comment: ""), action: nil, keyEquivalent: "")
        upgradeMenuItem.submenu = upgradeMenu
        menu.addItem(upgradeMenuItem)
        updateDisplayStatus()
    }
}

extension AutoUpgardeManager {
    @objc private func didSelectUpgradeChannel(_ menuItem: NSMenuItem) {
        guard let channel = Channel(rawValue: menuItem.tag) else { return }
        current = channel
        updateDisplayStatus()
    }

    private func updateDisplayStatus() {
        for (channel, menuItem) in menuItems {
            menuItem.state = channel == current ? .on : .off
        }
    }
}

extension AutoUpgardeManager: SPUUpdaterDelegate {
    func feedURLString(for updater: SPUUpdater) -> String? {
        guard WebPortalManager.hasWebProtal == false, allowSelectChannel else { return nil }
        return current.urlString
    }

    func updaterWillRelaunchApplication(_ updater: SPUUpdater) {
        SystemProxyManager.shared.disableProxy(port: 0, socksPort: 0, forceDisable: true)
    }
}

// MARK: - Channel Enum

extension AutoUpgardeManager {
    enum Channel: Int, CaseIterable {
        case stable
        case prelease
        case appcenter
    }
}

extension AutoUpgardeManager.Channel {
    var title: String {
        switch self {
        case .stable:
            return NSLocalizedString("Stable", comment: "")
        case .prelease:
            return NSLocalizedString("Prelease", comment: "")
        case .appcenter:
            return "Appcenter"
        }
    }

    var urlString: String {
        switch self {
        case .stable:
            return "https://yichengchen.github.io/clashX/appcast.xml"
        case .prelease:
            return "https://yichengchen.github.io/clashX/appcast_pre.xml"
        case .appcenter:
            return "https://api.appcenter.ms/v0.1/public/sparkle/apps/dce6e9a3-b6e3-4fd2-9f2d-35c767a99663"
        }
    }
}
