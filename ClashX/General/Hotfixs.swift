//
//  Hotfixs.swift
//  ClashX
//
//  Created by yicheng on 2023/6/25.
//  Copyright © 2023 west2online. All rights reserved.
//

import AppKit
import RxCocoa
import RxSwift

enum Hotfixs {
    private static var kvos = Set<NSKeyValueObservation>()
    static func applyMacOS14Hotfix(modeItem: NSMenuItem) {
        if #available(macOS 14.0, *) {
            let itemView = NormalMenuItemView(modeItem.title, rightArrow: true)

            let observer = modeItem.observe(\.title) { item, _ in
                itemView.label.stringValue = item.title
            }
            kvos.insert(observer)
            modeItem.view = itemView
        }
    }
}
