//
//  RootViewController.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 10.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Root view controller
*
* @author TCASSEMBLER
* @version 1.0
*/
class RootViewController: ContentViewController {
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        showLoginScreen()
    }
    
    /**
    Show Login screen
    */
    func showLoginScreen() {
        if let vc = create(LoginViewController.self) {
            super.setContentViewController(vc)
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
    Checks if need to delegate content opening to contentController
    
    - parameter viewController: the view controller
    - parameter animated:       the animation flag
    */
    override func setContentViewController(viewController: UIViewController, animated: Bool) {
        if let vc = contentController as? ContentViewController {
            vc.setContentViewController(viewController, animated: true)
        }
        else {
            let vc = ContentViewController()
            vc.setContentViewController(viewController, animated: false)
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
    
    /**
    Open Login screen
    */
    func openLoginScreen() {
        if let vc = contentController as? ContentViewController {
            contentController = nil
            vc.dismissViewControllerToSide(vc, side: .BOTTOM, nil)
        }
        showLoginScreen()
    }
}

/**
* Helpful view controller to change the status bar color
*
* @author TCASSEMBLER
* @version 1.0
*/
class ContentViewController: UIViewController {
    
    /// the last shown view controller
    var contentController: UIViewController?
    
    /**
    Light status bar
    
    - returns: .Default
    */
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }
    
    /**
    Changes current top view controller
    
    - parameter viewController: the view controller
    - parameter animated:       the animation flag
    */
    func setContentViewController(viewController: UIViewController, animated: Bool = false) {
        if animated {
            let lastVC = contentController
            showViewControllerFromSide(viewController, inContainer: self.view,
                bounds: self.view.bounds, side: .BOTTOM, {
                    lastVC?.removeFromParent()
            })
        }
        else {
            contentController?.removeFromParent()
            loadViewController(viewController, self.view)
            self.view.sendSubviewToBack(viewController.view)
        }
        contentController = viewController
    }
}
