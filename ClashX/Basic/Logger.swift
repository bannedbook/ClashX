//
//  Logger.swift
//  ClashX
//
//  Created by CYC on 2018/8/7.
//  Copyright © 2018年 yichengchen. All rights reserved.
//

import Foundation
import SwiftLog

class Logger {
    static let shared = Logger()
    let queue = DispatchQueue(label: "clash.logger")
    private init() {
        Log.logger.name = "ClashX" //default is "logfile"
        Log.logger.maxFileSize = 2048 //default is 1024
        Log.logger.maxFileCount = 4 //default is 4
        Log.logger.directory = (NSHomeDirectory() as NSString).appendingPathComponent("/Library/Logs/ClashX")
        Log.logger.printToConsole = false //default is true
    }
    
    private func logToFile(msg:String) {
        self.queue.sync {
            logw(msg)
        }
    }
    
    static func log(msg:String) {
        shared.logToFile(msg: msg)
    }
    
    func logFilePath() -> String {
        return Log.logger.currentPath
    }
}
