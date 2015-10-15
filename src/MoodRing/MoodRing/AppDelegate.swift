//
//  AppDelegate.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 08.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    /**
    Get reference to AppDelegate
    
    - returns: return shared application delegate casted to AppDelegate
    */
    class func sharedInstance() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    /**
    Process app launching
    
    - parameter application:   the application
    - parameter launchOptions: the options
    
    - returns: true
    */
    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        initSalesforceSDK()
        return true
    }
    
    /**
    Initialize Salesforce SDK
    */
    func initSalesforceSDK() {

        /// parameters for Salesforce SDK
        let RemoteAccessConsumerKey = Configuration.sharedConfig.salesforceKey
        let OAuthRedirectURI        = Configuration.sharedConfig.salesforceCallback
        let scopes = ["api"]
        
        SFLogger.setLogLevel(SFLogLevelDebug)
        SalesforceSDKManager.sharedManager().connectedAppId = RemoteAccessConsumerKey
        SalesforceSDKManager.sharedManager().connectedAppCallbackUri = OAuthRedirectURI
        SalesforceSDKManager.sharedManager().authScopes = scopes
        SalesforceSDKManager.sharedManager().postLaunchAction = {
            [unowned self] (launchActionList: SFSDKLaunchAction) in
            let launchActionString = SalesforceSDKManager.launchActionsStringRepresentation(launchActionList)
            self.log(SFLogLevelInfo, msg:"Post-launch: launch actions taken: \(launchActionString)");
            
        }
        SalesforceSDKManager.sharedManager().launchErrorAction = {
            [unowned self] (error: NSError?, launchActionList: SFSDKLaunchAction) in
            if let actualError = error {
                self.log(SFLogLevelError, msg:"Error during SDK launch: \(actualError.localizedDescription)")
            } else {
                self.log(SFLogLevelError, msg:"Unknown error during SDK launch.")
            }
        }
    }
    
}

