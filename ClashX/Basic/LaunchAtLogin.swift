//
//  AutoStartManager.swift
//  ClashX
//
//  Created by CYC on 2018/6/14.
//  Copyright © 2018年 yichengchen. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import ServiceManagement

public class LaunchAtLogin {
    private static let id = "com.west2online.ClashX.LaunchHelper"

    static let shared = LaunchAtLogin()

    private init() {
        isEnableVirable.accept(isEnabled)
    }

    public var isEnabled: Bool {
        get {
            guard let jobs = (SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: AnyObject]]) else {
                return false
            }
            let job = jobs.first { $0["Label"] as! String == LaunchAtLogin.id }
            return job?["OnDemand"] as? Bool ?? false
        }
        set {
            SMLoginItemSetEnabled(LaunchAtLogin.id as CFString, newValue)
            isEnableVirable.accept(newValue)
        }
    }

    var isEnableVirable = BehaviorRelay<Bool>(value: false)
}
