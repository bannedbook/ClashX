//
//  String+Extension.swift
//  ClashX
//
//  Created by 称一称 on 2018/10/7.
//  Copyright © 2018年 west2online. All rights reserved.
//
import Foundation

extension String
{
    func trimed() -> String {
        let whitespaces = CharacterSet(charactersIn: " \n\r\t")
        return self.trimmingCharacters(in: whitespaces)
    }
    

}
