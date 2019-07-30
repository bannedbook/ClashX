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
        var indexs = IndexSet()
        for index in selectedRowIndexes {
            if 0 <= index && index <= self.numberOfRows {
                indexs.insert(index)
            }
        }
        self.selectRowIndexes(indexs, byExtendingSelection: false)
    }
}
