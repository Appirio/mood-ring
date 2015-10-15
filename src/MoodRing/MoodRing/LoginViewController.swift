//
//  LoginViewController.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 08.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/// the reference to LoginViewController instance
var LoginViewControllerInstance: LoginViewController?

/**
* Login screen.
* Shows only one button "Sign in using SalesForce" because SalesForce SDK does
* not allow a custom screens for authentication.
*
* @author TCASSEMBLER
* @version 1.0
*/
class LoginViewController: UIViewController, SFAuthenticationManagerDelegate {

    /// the reference to last opened view controller
    var lastOpenedViewController: UIViewController?
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginViewControllerInstance = self
        SFAuthenticationManager.sharedManager().addDelegate(self)
    
    }
    
    /**
    Move into the app if have a valid session (logged in)
    
    - parameter animated: the animation flag
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if SFAuthenticationManager.sharedManager().haveValidSession {
            openDashboard(false)
        }
    }
    
    /**
    Light status bar
    
    - returns: .LightContent
    */
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    /**
    "Sign In" button action handler
    
    - parameter sender: the button
    */
    @IBAction func signInAction(sender: AnyObject) {
        SalesforceSDKManager.sharedManager().launch()
    }
    
    /**
    Salesforce event handler. Invoked after user has logged in
    
    - parameter manager: the manager instance
    - parameter info:    the info
    */
    func authManagerDidFinish(manager: SFAuthenticationManager!, info: SFOAuthInfo!) {
        if !SFUserAccountManager.sharedInstance().currentUser.userName.isEmpty {
            /*
            User's profile will be checked here if future to confirm to either manager or a common user role.
            For this prototype "isManagerFlag" from configuration.plist is used to switch between different roles.
            */
            openDashboard(true)
        }
    }
}
