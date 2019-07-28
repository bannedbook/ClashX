//
//  NSTableView+Reload.swift
//  ClashX
//
//  Created by 称一称 on 2019/7/28.
//  Copyright © 2019 west2online. All rights reserved.
//

import Cocoa

extension NSTableView {
    func reloadDataKeepingSelection() {
        let selectedRowIndexes = self.selectedRowIndexes
        self.reloadData()
        self.selectRowIndexes(selectedRowIndexes, byExtendingSelection: false)
    }
}
