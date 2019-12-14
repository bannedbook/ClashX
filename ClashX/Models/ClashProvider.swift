//
//  ClashProvider.swift
//  ClashX
//
//  Created by yichengchen on 2019/12/14.
//  Copyright © 2019 west2online. All rights reserved.
//

import Cocoa

class ClashProviderResp: Codable {
    let allProviders: [ClashProxyName: ClashProvider]
    lazy var providers: [ClashProxyName: ClashProvider] = {
        return allProviders.filter({ $0.value.vehicleType != .Compatible })
    }()

    private init() {
        allProviders = [:]
    }

    static func create(_ data: Data?) -> ClashProviderResp {
        guard let data = data else { return ClashProviderResp() }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.js)
        return (try? decoder.decode(ClashProviderResp.self, from: data)) ?? ClashProviderResp()
    }

    private enum CodingKeys: String, CodingKey {
        case allProviders = "providers"
    }
}

class ClashProvider: Codable {
    enum ProviderType: String, Codable {
        case Proxy
        case String
    }

    enum ProviderVehicleType: String, Codable {
        case HTTP
        case File
        case Compatible
        case Unknown
    }

    let name: String
    let proxies: [ClashProxy]
    let type: ProviderType
    let vehicleType: ProviderVehicleType
}
