//
//  String+Localized.swift
//  ClashX
//
//  Created by 称一称 on 2018/10/8.
//  Copyright © 2018年 west2online. All rights reserved.
//

import Foundation

// to use english as showing language
// defaults write com.west2online.ClashX AppleLanguages '("en-US")'
extension String {
    func localized(bundle: Bundle = .main, tableName: String = "Localizable") -> String {
        return NSLocalizedString(self, tableName: tableName, value: "\(self)", comment: "")
    }
}
