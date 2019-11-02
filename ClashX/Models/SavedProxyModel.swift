//
//  SavedProxyModel.swift
//  ClashX
//
//  Created by yicheng on 2019/11/1.
//  Copyright © 2019 west2online. All rights reserved.
//

import Cocoa

struct SavedProxyModel: Codable {
    let group: ClashProxyName
    let selected: ClashProxyName
    let config: String

    static let key = "SavedProxyModels"

    static func migrate() -> [SavedProxyModel]? {
        if let mapping = UserDefaults.standard.dictionary(forKey: "selectedProxyMap") as? [ClashProxyName: ClashProxyName] {
            var models = [SavedProxyModel]()
            for (group, selected) in mapping {
                models.append(SavedProxyModel(group: group, selected: selected, config: ConfigManager.selectConfigName))
            }
            UserDefaults.standard.removeObject(forKey: "selectedProxyMap")
            return models
        }
        return nil
    }

    static func loadsFromUserDefault() -> [SavedProxyModel] {
        if let data = UserDefaults.standard.object(forKey: key) as? Data,
            let models = try? JSONDecoder().decode([SavedProxyModel].self, from: data) {
            return models
        }
        if let models = migrate() {
            save(models)
            return models
        }
        return []
    }

    static func save(_ models: [SavedProxyModel]) {
        if let data = try? JSONEncoder().encode(models) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

extension SavedProxyModel: Equatable {}
