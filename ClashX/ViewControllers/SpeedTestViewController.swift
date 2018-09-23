//
//  SpeedTesdtViewController.swift
//  ClashX
//
//  Created by CYC on 2018/9/23.
//  Copyright © 2018年 west2online. All rights reserved.
//

import Cocoa

class SpeedTestViewController: NSViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    
    class ProxyModel {
        var name:String
        var delay:String?

        init(_ name:String) {
            self.name = name
        }
    }
    
    var proxies = [ProxyModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupData()
    }
    
    func setupData() {
        ApiRequest.getAllProxyList { [unowned self](proxies) in
            for proxyName in proxies {
                self.proxies.append(ProxyModel(proxyName))
            }
            self.tableView.reloadData()
            self.speedTest()
        }
    }
    
    func speedTest() {
        for proxy in proxies {
            ApiRequest.getProxyDelay(proxyName: proxy.name) {[weak self] (delay) in
                guard let strongSelf = self else {return}
                proxy.delay = delay
                strongSelf.tableView.reloadData()
            }
        }
    }
    
}

extension SpeedTestViewController:NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return proxies.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if(tableColumn?.identifier.rawValue == "proxies") {
            return cellForProxyName(tableView, atRow: row)
        } else {
            return cellForDelay(tableView, atRow: row)
        }
    }
        
        
    func cellForProxyName(_ tableView:NSTableView, atRow row:Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ProxyNameCell"), owner: nil)
        let model = proxies[row]
        let textField = cell?.viewWithTag(1) as! NSTextField
        textField.stringValue = model.name
        return cell
    }
    
    
    func cellForDelay(_ tableView:NSTableView, atRow row:Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "delayCell"), owner: nil)
        let textField = cell?.viewWithTag(1) as! NSTextField
        let model = proxies[row]

        if let delay = model.delay {
            textField.stringValue = delay
        } else {
            textField.stringValue = "testing"
        }
        return cell
    }


}

extension SpeedTestViewController:NSTableViewDelegate{
    
}

