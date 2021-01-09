//
//  AnrDetectUtil.swift
//  Rooms
//
//  Created by miniLV on 2021/1/4.
//  Copyright © 2020 miniLV. All rights reserved.
//


import Cocoa

class AnrDetectUtil {
    static let shared = AnrDetectUtil()
    
    private init() {}
    lazy var thread = AnrDetectThread()
    
    
    func start(threshold: Double = 10) {
        thread.start(threshold: threshold) {
            [weak thread] allThreadBackTrace in
            Logger.log("[ANR] \(allThreadBackTrace)", level: .error)
            thread?.cancel()
        }
    }
    
    func stop() {
        thread.cancel()
    }
}
