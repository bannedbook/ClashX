//
//  SystemProxyManager.swift
//  ClashX
//
//  Created by yichengchen on 2019/8/17.
//  Copyright © 2019 west2online. All rights reserved.
//

import ServiceManagement
import AppKit

class SystemProxyManager: NSObject {
    
    static let shared = SystemProxyManager()
    
    private static let machServiceName = "com.west2online.ClashX.ProxyConfigHelper"
    private var authRef: AuthorizationRef?
    private var connection: NSXPCConnection?
    private var _helper: ProxyConfigRemoteProcessProtocol?
    private var savedProxyInfo: [String:Any] {
        get {
            return UserDefaults.standard.dictionary(forKey: "kSavedProxyInfo") ?? [:]
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "kSavedProxyInfo")
        }
    }
    
    private var disableRestoreProxy:Bool {
        get {
            return UserDefaults.standard.bool(forKey: "kDisableRestoreProxy")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "kDisableRestoreProxy")
        }
    }
    
    // MARK: - LifeCycle
    
    override init() {
        super.init()
        initAuthorizationRef()
    }
    
    // MARK: - Public
    
    func checkInstall() {
        helperStatus { [weak self] installed in
            if installed {return}
            if Thread.isMainThread {
                self?.notifyInstall()
            } else {
                DispatchQueue.main.async {
                    self?.notifyInstall()
                }
            }
        }
    }
    
    func saveProxy() {
        guard !disableRestoreProxy else {return}
        
        helper()?.getCurrentProxySetting({ [weak self] info in
            if let info = info as? [String : Any] {
                self?.savedProxyInfo = info
            }
        })
    }
    
    func enableProxy(port: Int,socksPort: Int) {
        Logger.log(msg: "enableProxy", level: .debug)
        helper()?.enableProxy(withPort: Int32(port), socksPort: Int32(socksPort), authData: authData(), error: { error in
            if let error = error{
                Logger.log(msg: "enableProxy \(error)", level: .error)
            }
        })
    }
    
    func disableProxy(port: Int,socksPort: Int) {
        Logger.log(msg: "disableProxy", level: .debug)
        
        if disableRestoreProxy {
            helper()?.disableProxy(withAuthData: authData(), error: { error  in
                if let error = error{
                    Logger.log(msg: "disableProxy \(error)", level: .error)
                }
            })
            return
        }
        
        helper()?.restoreProxy(withCurrentPort: Int32(port), socksPort: Int32(socksPort), info: savedProxyInfo, authData: authData(), error: { error in
            if let error = error{
                Logger.log(msg: "restoreProxy \(error)", level: .error)
            }
        })        
    }
    
    // MARK: - Private
    
    private func initAuthorizationRef() {
        // Create an empty AuthorizationRef
        let status = AuthorizationCreate(nil, nil, AuthorizationFlags(), &authRef)
        if (status != OSStatus(errAuthorizationSuccess)) {
            Logger.log(msg:"initAuthorizationRef AuthorizationCreate failed",level: .error)
            return
        }
    }
    
    
    /// Install new helper daemon
    private func installHelperDaemon() {
        
        // Create authorization reference for the user
        var authRef: AuthorizationRef?
        var authStatus = AuthorizationCreate(nil, nil, [], &authRef)
        
        // Check if the reference is valid
        guard authStatus == errAuthorizationSuccess else {
            Logger.log(msg: "Authorization failed: \(authStatus)", level: .error)
            return
        }
        
        // Ask user for the admin privileges to install the
        var authItem = AuthorizationItem(name: kSMRightBlessPrivilegedHelper, valueLength: 0, value: nil, flags: 0)
        var authRights = AuthorizationRights(count: 1, items: &authItem)
        let flags: AuthorizationFlags = [[], .interactionAllowed, .extendRights, .preAuthorize]
        authStatus = AuthorizationCreate(&authRights, nil, flags, &authRef)
        defer {
            if let ref = authRef {
                AuthorizationFree(ref, [])
            }
        }
        // Check if the authorization went succesfully
        guard authStatus == errAuthorizationSuccess else {
            Logger.log(msg: "Couldn't obtain admin privileges: \(authStatus)", level: .error)
            return
        }
        
        // Launch the privileged helper using SMJobBless tool
        var error: Unmanaged<CFError>? = nil
        
        if(SMJobBless(kSMDomainSystemLaunchd, SystemProxyManager.machServiceName as CFString, authRef, &error) == false) {
            let blessError = error!.takeRetainedValue() as Error
            Logger.log(msg: "Bless Error: \(blessError)", level: .error)
        } else {
            Logger.log(msg: "\(SystemProxyManager.machServiceName) installed successfully", level: .info)
        }
        
        connection?.invalidate()
        connection = nil
        _helper = nil
    }
    
    private func authData() -> Data? {
        guard let authRef = authRef else {return nil}
        var authRefExtForm = AuthorizationExternalForm()
        
        // Make an external form of the AuthorizationRef
        var status = AuthorizationMakeExternalForm(authRef, &authRefExtForm)
        if (status != OSStatus(errAuthorizationSuccess)) {
            Logger.log(msg: "AppviewController: AuthorizationMakeExternalForm failed", level: .error)
            return nil
        }
        
        // Add all or update required authorization right definition to the authorization database
        var currentRight:CFDictionary?
        
        // Try to get the authorization right definition from the database
        status = AuthorizationRightGet(AppAuthorizationRights.rightName.utf8String!, &currentRight)
        
        if (status == errAuthorizationDenied) {
            
            let defaultRules = AppAuthorizationRights.rightDefaultRule
            status = AuthorizationRightSet(authRef,
                                           AppAuthorizationRights.rightName.utf8String!,
                                           defaultRules as CFDictionary,
                                           AppAuthorizationRights.rightDescription,
                                           nil, "Common" as CFString)
        }
        
        // We need to put the AuthorizationRef to a form that can be passed through inter process call
        let authData = NSData(bytes: &authRefExtForm, length:kAuthorizationExternalFormLength)
        return authData as Data
    }
    
    private func helperConnection() -> NSXPCConnection? {
        // Check that the connection is valid before trying to do an inter process call to helper
        if(connection == nil) {
            connection = NSXPCConnection(machServiceName: SystemProxyManager.machServiceName, options: NSXPCConnection.Options.privileged)
            connection?.remoteObjectInterface = NSXPCInterface(with: ProxyConfigRemoteProcessProtocol.self)
            connection?.invalidationHandler = {
                self.connection?.invalidationHandler = nil
                OperationQueue.main.addOperation() {
                    self.connection = nil
                    Logger.log(msg: "XPC Connection Invalidated")
                }
            }
            connection?.resume()
        }
        return connection
    }
    
    
    private func helper(failture: (() -> Void)? = nil) -> ProxyConfigRemoteProcessProtocol? {
        if _helper == nil {
            guard let newHelper = self.helperConnection()?.remoteObjectProxyWithErrorHandler({ error in
                Logger.log(msg: "Helper connection was closed with error: \(error)")
                failture?()
            }) as? ProxyConfigRemoteProcessProtocol else { return nil }
            _helper = newHelper
        }
        return _helper
    }
    
    private func helperStatus(completion: @escaping (_ installed: Bool) -> Void) {
        let helperURL = Bundle.main.bundleURL.appendingPathComponent("Contents/Library/LaunchServices/" + SystemProxyManager.machServiceName)
        var callback:((Bool)->Void)? = completion
        
        guard
            let helperBundleInfo = CFBundleCopyInfoDictionaryForURL(helperURL as CFURL) as? [String: Any],
            let helperVersion = helperBundleInfo["CFBundleShortVersionString"] as? String,
            let helper = self.helper() else {
                callback?(false)
                callback = nil
                return
        }
        var installed = false
        let semaphore = DispatchSemaphore(value: 0)
        helper.getVersion { installedHelperVersion in
            installed = installedHelperVersion == helperVersion
        }
        _ = semaphore.wait(timeout: DispatchTime.now()+1)
        callback?(installed)
        callback = nil
    }
    
    
}

extension SystemProxyManager {
    private func notifyInstall() {
        guard showInstallHelperAlert() else {exit(0)}
        self.installHelperDaemon()
    }
    
    private func showInstallHelperAlert() -> Bool{
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("ClashX needs to install a helper tool with administrator privileges to set system proxy quickly.", comment: "")
        alert.alertStyle = .warning
        alert.addButton(withTitle: NSLocalizedString("Install", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("Quit", comment: ""))
        return alert.runModal() == .alertFirstButtonReturn
    }
}


fileprivate struct AppAuthorizationRights {
    static let rightName: NSString = "com.west2online.ClashX.ProxyConfigHelper.config"
    static let rightDefaultRule: Dictionary = adminRightsRule
    static let rightDescription: CFString = "ProxyConfigHelper wants to configure your proxy setting'" as CFString
    static var adminRightsRule: [String:Any] = ["class" : "user",
                                                "group" : "admin",
                                                "timeout" : 0,
                                                "version" : 1]
}
