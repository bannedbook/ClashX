//
//  ClashConfig.swift
//  ClashX
//
//  Created by CYC on 2018/7/30.
//  Copyright © 2018年 yichengchen. All rights reserved.
//
import Foundation

enum ClashProxyMode: String,Codable {
    case rule = "Rule"
    case global = "Global"
    case direct = "Direct"
}

enum ClashLogLevel:String,Codable {
    case info = "info"
    case warning = "warning"
    case error = "error"
    case debug = "debug"
    case silent = "silent"
    case unknow = "unknow"
}

class ClashConfig:Codable {
    var port:Int
    var socketPort:Int
    var allowLan:Bool
    var mode:ClashProxyMode
    var logLevel:ClashLogLevel
    
    private enum CodingKeys : String, CodingKey {
        case port, socketPort = "socks-port", allowLan = "allow-lan", mode, logLevel = "log-level"
    }
    
    static func fromData(_ data:Data)->ClashConfig?{
        let decoder = JSONDecoder()
        let model = try? decoder.decode(ClashConfig.self, from: data)
        return model
    }
    
    func copy() -> ClashConfig? {
        guard let data = try? JSONEncoder().encode(self) else {return nil}
        let copy = try? JSONDecoder().decode(ClashConfig.self, from: data)
        return copy
    }
}
