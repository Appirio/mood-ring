//
//  MenuViewController.swift
//  MoodRing
//
//  Created by Alexander Volkov on 09.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import Foundation


/**
* Class represents one menu item
*
* @author Alexander Volkov
* @version 1.0
*/
struct MenuItem {
    
    /// the menu title
    let title: String
    
    /// the menu icon name
    let iconName: String
    
    /// the view controller name
    let viewControllerName: String
    
    /// the storyboard name
    var storyboardName: String?
    
    /// flag: true - will push a view controller over the current view controller, false - will replace it
    var pushOver = false
    
    /**
    Create new instance with given parameters
    
    - parameter title:              the menu title
    - parameter iconName:           the icon name
    - parameter viewControllerName  the view controller name
    - parameter pushOver:           the flag to push the screen over
    - parameter storyboardName:     the storyboard name (default "Main")
    
    - returns: new instance
    */
    init(title: String, iconName: String, viewControllerName: String,
        pushOver: Bool = false, storyboardName: String? = "Main") {
            self.title = title
            self.iconName = iconName
            self.viewControllerName = viewControllerName
            self.pushOver = pushOver
            self.storyboardName = storyboardName
    }
}

/// the title of the "Logout" menu item
let LOGOUT_TITLE = "Logout".localized()

/// the ID of Dashboard view controller
let DASHBOARD_VIEW_CONTROLLER = "DashboardViewController"

/// the selected menu item index
var MenuViewControllerSelectedIndex = 0

/// the width of the menu
let MenuWidth: CGFloat = isIPhone5() ? 300 : 325

/**
* Menu view controller
*
* @author Alexander Volkov
* @version 1.0
*/
class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /// heights of the cells for different devices
    let CELL_HEIGHT_DEFAULT: CGFloat = 137
    let CELL_HEIGHT_IPHONE5: CGFloat = 110
    
    /// outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuWidth: NSLayoutConstraint!
    
    /// the menu items to show
    var menus: [MenuItem] = [
        MenuItem(title: "Dashboard".localized(), iconName: "iconDashboard",
            viewControllerName: DASHBOARD_VIEW_CONTROLLER),
        MenuItem(title: "My Rating".localized(), iconName: "iconMyRating",
            viewControllerName: "MyRatingViewController"),
        MenuItem(title: "My Fun Factor".localized(), iconName: "iconMyFunFactor",
            viewControllerName: "MyFunFactorViewController"),
        MenuItem(title: LOGOUT_TITLE, iconName: "iconLogout", viewControllerName: ""),
    ]
    
    /// the selected indexPath
    var selectedIndexPath: NSIndexPath = NSIndexPath(forRow: MenuViewControllerSelectedIndex, inSection: 0) {
        didSet {
            MenuViewControllerSelectedIndex = selectedIndexPath.row
        }
    }
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInsetAndMarginsToZero()
        tableView.separatorColor = UIColor.clearColor()
        menuWidth.constant = MenuWidth
    }
    
    // MARK: UITableViewDataSource, UITableViewDelegate
    
    /**
    Get number of cells
    
    - parameter tableView: the tableView
    - parameter indexPath: the indexPath
    
    - returns: the number of menu items
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus.count
    }
    
    /**
    Get height for a cell
    
    - parameter tableView: the tableView
    - parameter indexPath: the indexPath
    
    - returns: the height
    */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return isIPhone5() ? CELL_HEIGHT_IPHONE5 : CELL_HEIGHT_DEFAULT
    }
    
    /**
    Get cell for given indexPath
    
    - parameter tableView: the tableView
    - parameter indexPath: the indexPath
    
    - returns: cell that represents corresponding menu item
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.getCell(indexPath, ofClass: MenuItemTableViewCell.self)
        let item = menus[indexPath.row]
        let isSelected = selectedIndexPath.row == indexPath.row
        cell.configureCell(item, isSelected: isSelected)
        return cell
    }
    
    /**
    Cell tap action handler. Opens corresponding screen
    
    - parameter tableView: the tableView
    - parameter indexPath: the indexPath
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let item = menus[indexPath.row]
        
        // Disable most of the items for manager role
        if AuthenticationUtil.sharedInstance.isManager && item.viewControllerName != DASHBOARD_VIEW_CONTROLLER {
            showAlert("Info", "This feature is disabled for managers in the prototype")
            return
        }
        
        if selectedIndexPath.row != indexPath.row {
            if let controller = createContentControllerForItem(item) {
                if item.pushOver {
                    if let nav = self.rootController?.contentController as? UINavigationController {
                        closeMenu()
                        nav.popToRootViewControllerAnimated(true)
                        nav.viewControllers[0].navigationItem.title = ""
                        nav.pushViewController(controller, animated: true)
                    }
                }
                else {
                    self.rootController?.setContentViewController(controller, animated: false)
                }
                closeMenu()
            }
            let lastIndexPath = selectedIndexPath
            selectedIndexPath = indexPath
            tableView.reloadRowsAtIndexPaths([lastIndexPath, indexPath], withRowAnimation: .None)
        }
        else {
            closeMenu()
        }
    }
    
    /**
    Create view controller for given menu item
    
    - parameter item: the menuitem
    
    - returns: the view controller or nil
    */
    func createContentControllerForItem(item: MenuItem) -> UIViewController? {
        let storyboard = (item.storyboardName != nil ? UIStoryboard(name: item.storyboardName!, bundle: nil)
            : self.storyboard)
        if let vc = storyboard?.instantiateViewControllerWithIdentifier(item.viewControllerName) {
            if item.pushOver {
                return vc
            }
            return vc.wrapInNavigationController()
        }
        return nil
    }
    
    /**
    "Settings" button action handler
    
    - parameter sender: the button
    */
    @IBAction func settingsAction(sender: AnyObject) {
        showStub()
    }
    
    /**
    "Help" button action handler
    
    - parameter sender: the button
    */
    @IBAction func helpAction(sender: AnyObject) {
        showStub()
    }
    
    /**
    "Logout" button action handler
    
    - parameter sender: the button
    */
    @IBAction func logoutAction(sender: AnyObject) {        
        self.returnToLoginScreen()
    }
    
    /**
    Left swipe action handler
    
    - parameter sender: the swipe gesture recognizer
    */
    @IBAction func swipeLeftAction(sender: AnyObject) {
        closeMenu()
    }
}

/**
* Cell for a menu item
*
* @author Alexander Volkov
* @version 1.0
*/
class MenuItemTableViewCell: UITableViewCell {
    
    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var topLabelMargin: NSLayoutConstraint!
    
    /**
    Setup UI
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
        topLabelMargin.constant = isIPhone5() ? 7 : 14
    }
    
    /**
    Update UI with given data
    
    - parameter item:       the menu item data
    - parameter isSelected: true - if selected, false - else
    */
    func configureCell(item: MenuItem, isSelected: Bool) {
        titleLabel.text = item.title
        iconView.image = UIImage(named: item.iconName)
        let color = isSelected ? UIColor.whiteColor() : UIColor.blue()
        iconView?.tintColor = color
        titleLabel.textColor = color
    }
}