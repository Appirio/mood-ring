//
//  LoginViewController.swift
//  MoodRing
//
//  Created by Alexander Volkov on 08.10.15.
//  Modified by TCASSEMBLER in 20.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/*
option: true - a custom login screen will be used (Not working yet. It's just UI for future),
        false - a Salesforce login web page will be used
*/
let OPTION_USE_CUSTOM_LOGIN_SCREEN = false

/// the reference to LoginViewController instance
var LoginViewControllerInstance: LoginViewController?
/// stores estimated keyboard height
var KeyboardHeight: CGFloat = 258

/**
* Login screen.
* Shows only one button "Sign in using SalesForce" because SalesForce SDK does
* not allow a custom screens for authentication.
*
* @author Alexander Volkov, TCASSEMBLER
* @version 1.1
*
* changes:
* 1.1:
* - new method updateCurrentUser
*/
class LoginViewController: UIViewController, SFAuthenticationManagerDelegate, UITextFieldDelegate, UIWebViewDelegate {

    /// outlets
    @IBOutlet weak var loginSalesforceButton: UIButton!
    @IBOutlet weak var customLoginView: UIView!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet var fieldViews: [UIView]!
    @IBOutlet var formOffsetOy: [NSLayoutConstraint]!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    /// the reference to last opened view controller
    var lastOpenedViewController: UIViewController?
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        LoginViewControllerInstance = self
        SFAuthenticationManager.sharedManager().addDelegate(self)
        
        // Show corresponding components
        loginSalesforceButton.hidden = OPTION_USE_CUSTOM_LOGIN_SCREEN
        customLoginView.hidden = !OPTION_USE_CUSTOM_LOGIN_SCREEN
        webView.delegate = self
        
        for view in fieldViews {
            view.addBottomBorder(height: 1, color: UIColor(white: 1, alpha: 0.3))
        }
    }
    
    /**
    Move into the app if have a valid session (logged in)
    
    - parameter animated: the animation flag
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        webView.hidden = true
        loginSalesforceButton.hidden = false
        loginSalesforceButton.enabled = true
        loadingIndicator.stopAnimating()
        if SFAuthenticationManager.sharedManager().haveValidSession {
            updateCurrentUser()
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
        self.view.endEditing(true)
        loginSalesforceButton.enabled = false
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
            loginSalesforceButton.hidden = true
            loadingIndicator.startAnimating()
            updateCurrentUser()
            openDashboard(true)
        }
    }
    
    /**
    Update current user in AuthenticationUtil
    */
    func updateCurrentUser() {
        let previousUser = AuthenticationUtil.sharedInstance.currentUser
        let id: String = SFUserAccountManager.sharedInstance().currentUser.credentials.userId
        let name: String = SFUserAccountManager.sharedInstance().currentUser.fullName
        let user = User(id: id,
            name,
            rating: previousUser.avgAllProjectsRating,
            funFactor: previousUser.funFactor,
            iconUrl: previousUser.iconUrl
        )
        AuthenticationUtil.sharedInstance.currentUser = user
    }
    
    // MARK: Keyboard
    
    /**
    Dismiss keyboard
    
    - parameter textField: the textField
    
    - returns: true
    */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /**
    Move form up when the field is focused
    
    - parameter textField: the textField
    
    - returns: true
    */
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        // move form up to reveal the field
        let currentPosition = textField.convertRectCorrectly(textField.frame, toView: self.view)
        
        let visibleHeight = UIScreen.mainScreen().bounds.height - KeyboardHeight
        let fieldOy = self.view.frame.origin.y + currentPosition.origin.y
        let extraOffsetUnderKeyboard: CGFloat = 44
        let maxFieldOy = visibleHeight - currentPosition.height - extraOffsetUnderKeyboard
        if fieldOy > maxFieldOy {
            let viewAdditionalOffset = fieldOy - maxFieldOy
            for constraint in formOffsetOy {
                constraint.constant = viewAdditionalOffset
            }
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
        return true
    }
    
    /**
    Add keyboard listeners
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Listen for keyboard events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
    Remove listeners
    */
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /**
    Handle keyboard opening
    */
    func keyboardWillShow(notification: NSNotification) {
        let rect = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        KeyboardHeight = rect.height
    }
    
    /**
    Keyboard disappear event handler
    
    :param: notification the notification object
    */
    func keyboardWillHide(notification: NSNotification) {
        for constraint in formOffsetOy {
            constraint.constant = 0
        }
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}
