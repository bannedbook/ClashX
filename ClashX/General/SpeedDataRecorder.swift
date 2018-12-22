//
//  SpeedDataRecorder.swift
//  ClashX
//
//  Created by CYC on 2018/10/2.
//  Copyright © 2018 west2online. All rights reserved.
//

import Cocoa

class SpeedDataRecorder {
    static let shared = SpeedDataRecorder()
    private init(){}
    
    private let queue = DispatchQueue(label: "clashx.SpeedDataRecorder", qos: .default, attributes: .concurrent)
    private var speedDict = [String:Int]()
    
    func getDelay(_ proxyName:String) -> Int? {
        var delay:Int?
        queue.sync { [weak self] in
            delay = self?.speedDict[proxyName]
        }
        return delay
    }
    
    func setDelay(_ proxyName:String,delay:Int?) {
        queue.async(qos: .default, flags: .barrier) {
            [weak self] in
            self?.speedDict[proxyName] = delay
        }
    }
}
