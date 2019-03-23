//
//  ClashProxy.swift
//  ClashX
//
//  Created by CYC on 2019/3/17.
//  Copyright © 2019 west2online. All rights reserved.
//

import Cocoa

enum ClashProxyType:String,Codable {
    case urltest = "URLTest"
    case fallback = "Fallback"
    case loadBalance = "LoadBalance"
    case select = "Selector"
    case direct = "Direct"
    case reject = "Reject"
    case shadowsocks = "Shadowsocks"
    case socks5 = "Socks5"
    case http = "Http"
    case vmess = "Vmess"
    case unknow = "Unknow"
}

typealias ClashProxyName = String

class ClashProxySpeedHistory:Codable {
    let time:Date
    let delay:Int
    
    class hisDateFormaterInstance {
        static let shared = hisDateFormaterInstance()
        lazy var formater:DateFormatter = {
            var f = DateFormatter()
            f.dateFormat = "HH:mm"
            return f
        }()
    }
    
    lazy var delayDisplay:String =  {
        switch delay {
        case 0: return "fail"
        default:return "\(delay) ms"
        }
    }()
    
    lazy var dateDisplay:String = {
       return hisDateFormaterInstance.shared.formater.string(from: time)
    }()
}



class ClashProxy:Codable {
    var name:ClashProxyName = ""
    let type:ClashProxyType
    let all:[ClashProxyName]?
    let history:[ClashProxySpeedHistory]
    let now:ClashProxyName?

    private enum CodingKeys : String, CodingKey {
        case type,all,history,now
    }
    
    lazy var maxProxyName:String = {
        return all?.max{$1.count > $0.count} ?? ""
    }()
    
    lazy var maxProxyNameLength:CGFloat = {
        let rect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: 20)
        let attr = [NSAttributedString.Key.font: NSFont.menuBarFont(ofSize: 0)]
        return (self.maxProxyName as NSString)
            .boundingRect(with: rect,
                          options: .usesLineFragmentOrigin,
                          attributes: attr).width;
    }()
}

class ClashProxyResp{
    
    let proxies:[ClashProxy]
    let proxiesMap:[ClashProxyName:ClashProxy]
    
    init(_ data:Any?) {
        guard
            let data = data as? [String:[String:Any]],
            let proxies = data["proxies"]
            else {
                self.proxiesMap = [:]
                self.proxies = []
                return
        }
        
        var proxiesModel = [ClashProxy]()
        
        var proxiesMap = [ClashProxyName:ClashProxy]()
        
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: NSCalendar.Identifier.ISO8601.rawValue)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SZ"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        for (key,value) in proxies {
            guard let data = try? JSONSerialization.data(withJSONObject: value, options: .prettyPrinted) else {
                continue
            }
            guard let proxy = try? decoder.decode(ClashProxy.self, from: data) else {
                continue
            }
            proxy.name = key
            proxiesModel.append(proxy)
            proxiesMap[proxy.name] = proxy
        }
        self.proxiesMap = proxiesMap
        self.proxies = proxiesModel
    }
    
    lazy var proxyGroups:[ClashProxy] = {
        return proxies.filter{
            switch $0.type {
            case .select,.urltest,.fallback,.loadBalance:return true
            default:return false
            }
            }.sorted(by: {$0.name < $1.name})
    }()
    
    lazy var longestProxyGroupName = {
        return proxyGroups.max{$1.name.count > $0.name.count}?.name ?? ""
    }()
    
    lazy var maxProxyNameLength:CGFloat = {
        let rect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: 20)
        let attr = [NSAttributedString.Key.font: NSFont.menuBarFont(ofSize: 0)]
        return (self.longestProxyGroupName as NSString)
            .boundingRect(with: rect,
                          options: .usesLineFragmentOrigin,
                          attributes: attr).width;
    }()
    
    
}



