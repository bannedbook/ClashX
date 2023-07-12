//
//  DebugSettingViewController.swift
//  ClashX Pro
//
//  Created by yicheng on 2023/5/25.
//  Copyright © 2023 west2online. All rights reserved.
//

import AppKit
import RxSwift

class DebugSettingViewController: NSViewController {
    @IBOutlet weak var swiftuiMenuBarButton: NSButton!
    @IBOutlet weak var useBuiltinApiButton: NSButton!
    @IBOutlet weak var revertProxyButton: NSButton!
    @IBOutlet weak var updateChannelPopButton: NSPopUpButton!
    var disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        swiftuiMenuBarButton.state = Settings.useSwiftUiMenuBar ? .on : .off
        swiftuiMenuBarButton.rx.state.bind { state in
            Settings.useSwiftUiMenuBar = state == .on
        }.disposed(by: disposeBag)
        useBuiltinApiButton.state = Settings.builtInApiMode ? .on:.off
        revertProxyButton.state = Settings.disableRestoreProxy ? .off : .on
        AutoUpgardeManager.shared.addChannelMenuItem(updateChannelPopButton)
    }
    @IBAction func actionUnInstallProxyHelper(_ sender: Any) {
        PrivilegedHelperManager.shared.removeInstallHelper()
    }
    @IBAction func actionOpenLogFolder(_ sender: Any) {
        NSWorkspace.shared.openFile(Logger.shared.logFolder())
    }
    @IBAction func actionOpenLocalConfig(_ sender: Any) {
        NSWorkspace.shared.openFile(kConfigFolderPath)

    }
    @IBAction func actionOpenIcloudConfig(_ sender: Any) {
        if ICloudManager.shared.icloudAvailable {
            ICloudManager.shared.getUrl {
                url in
                if let url = url {
                    NSWorkspace.shared.open(url)
                }
            }
        } else {
            NSAlert.alert(with: NSLocalizedString("iCloud not available", comment: ""))
        }
    }

    @IBAction func actionResetUserDefault(_ sender: Any) {
        guard let domain = Bundle.main.bundleIdentifier else { return }
        NSAlert.alert(with: NSLocalizedString("Click OK to quit the app and apply change.", comment: ""))
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        NSApplication.shared.terminate(self)
    }

    @IBAction func actionSetUseApiMode(_ sender: Any) {
        let alert = NSAlert()
        alert.informativeText = NSLocalizedString("Need to Restart the ClashX to Take effect, Please start clashX manually", comment: "")
        alert.addButton(withTitle: NSLocalizedString("Apply and Quit", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        if alert.runModal() == .alertFirstButtonReturn {
            Settings.builtInApiMode = !Settings.builtInApiMode
            NSApp.terminate(nil)
        } else {
            useBuiltinApiButton.state = Settings.builtInApiMode ? .on:.off
        }
    }

    @IBAction func actionUpdateGeoipDb(_ sender: Any) {
        ClashResourceManager.updateGeoIP()
    }

    @IBAction func actionRevertProxy(_ sender: Any) {
        Settings.disableRestoreProxy.toggle()
        revertProxyButton.state = Settings.disableRestoreProxy ? .off : .on
    }
}
