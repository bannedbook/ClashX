//
//  ClashConnection.swift
//  ClashX
//
//  Created by yicheng on 2019/10/28.
//  Copyright © 2019 west2online. All rights reserved.
//

import Cocoa

struct ClashConnectionSnapShot: Codable {
    let connections: [Connection]

    static func fromData(_ data: Data) -> ClashConnectionSnapShot {
        let decoder = JSONDecoder()
        let model = try? decoder.decode(ClashConnectionSnapShot.self, from: data)
        return model ?? ClashConnectionSnapShot(connections: [])
    }
}

extension ClashConnectionSnapShot {
    struct Connection: Codable {
        let id: String
        let chains: [String]
    }
}
