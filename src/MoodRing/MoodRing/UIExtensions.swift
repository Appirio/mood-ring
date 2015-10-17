//
//  UIExtensions.swift
//  MoodRing
//
//  Created by Alexander Volkov on 08.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/**
A set of helpful extensions for classes from UIKit
*/

/**
* Methods for loading and removing a view controller and its views,
* and shortcut helpful methods for instantiating UIViewController
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIViewController {
    
    /**
    Shortcut method for loading view controller, making it full transparent and fading in.
    
    - parameter viewController: the view controller to show
    - parameter callback:       callback block to invoke after the view controller is fully visible (alpha=1)
    */
    func fadeInViewController(viewController: UIViewController, _ callback: (()->())?) {
        let viewToShow = viewController.view
        viewToShow.alpha = 0
        loadViewController(viewController, self.view)
        
        // Fade in
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            viewToShow.alpha = 1
            }) { (fin: Bool) -> Void in
                callback?()
        }
    }
    
    /**
    Add the view controller and view into the current view controller
    and given containerView correspondingly.
    Uses autoconstraints.
    
    - parameter childVC:       view controller to load
    - parameter containerView: view to load into
    */
    func loadViewController(childVC: UIViewController, _ containerView: UIView) {
        loadViewController(childVC, containerView, withBounds: containerView.bounds)
    }
    
    /**
    Add the view controller and view into the current view controller
    and given containerView correspondingly.
    Sets fixed bounds for the loaded view in containerView.
    Constraints can be added manually or automatically.
    
    - parameter childVC:       view controller to load
    - parameter containerView: view to load into
    - parameter bounds:        the view bounds
    */
    func loadViewController(childVC: UIViewController, _ containerView: UIView, withBounds bounds: CGRect) {
        let childView = childVC.view
        
        childView.frame = bounds
        
        // Adding new VC and its view to container VC
        self.addChildViewController(childVC)
        containerView.addSubview(childView)
        
        // Finally notify the child view
        childVC.didMoveToParentViewController(self)
    }
    
    /**
    Remove view controller and view from their parents
    */
    func removeFromParent() {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
    }
    
    /**
    Instantiate given view controller.
    The method assumes that view controller is identified the same as its class
    and view is defined in the same storyboard.
    
    - parameter viewControllerClass: the class name
    - parameter storyboardName:      the name of the storyboard (optional)
    
    - returns: view controller or nil
    */
    func create<T: UIViewController>(viewControllerClass: T.Type, storyboardName: String? = nil) -> T? {
        let className = NSStringFromClass(viewControllerClass).componentsSeparatedByString(".").last!
        var storyboard = self.storyboard
        if let storyboardName = storyboardName {
            storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        }
        return storyboard?.instantiateViewControllerWithIdentifier(className) as? T
    }
    
    /**
    Show given view controller
    
    - parameter viewController: the view controller
    */
    func showViewController(viewController: UIViewController) {
        self.loadViewController(viewController, self.view)
    }
    
    /**
    Instantiate given view controller.
    The method assumes that view controller is identified the same as its class
    and view is defined in "Main" storyboard.
    
    - parameter viewController:Class the class name
    
    - returns: view controller or nil
    */
    class func createFromMainStoryboard<T: UIViewController>(viewControllerClass: T.Type) -> T? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let className = NSStringFromClass(viewControllerClass).componentsSeparatedByString(".").last!
        return storyboard.instantiateViewControllerWithIdentifier(className) as? T
    }
    
    /**
    Get currently opened view controller
    
    - returns: the top visible view controller
    */
    class func getCurrentViewController() -> UIViewController? {
        
        // If the root view is a navigation controller, we can just return the visible ViewController
        if let navigationController = getNavigationController() {
            
            return navigationController.visibleViewController
        }
        
        // Otherwise, we must get the root UIViewController and iterate through presented views
        if let rootController = UIApplication.sharedApplication().keyWindow?.rootViewController {
            
            var currentController: UIViewController! = rootController
            
            // Each ViewController keeps track of the view it has presented, so we
            // can move from the head to the tail, which will always be the current view
            while( currentController.presentedViewController != nil ) {
                
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }
    
    /**
    Returns the navigation controller if it exists
    
    - returns: the navigation controller or nil
    */
    class func getNavigationController() -> UINavigationController? {
        
        if let navigationController = UIApplication.sharedApplication().keyWindow?.rootViewController  {
            
            return navigationController as? UINavigationController
        }
        return nil
    }
    
    /**
    Wraps the given view controller into NavigationController
    
    - returns: NavigationController instance
    */
    func wrapInNavigationController() -> UINavigationController {
        let navigation = NavigationController(rootViewController: self)
        navigation.navigationBar.translucent = false
        return navigation
    }
}

/**
View transition type (from corresponding side)
*/
enum TRANSITION {
    case RIGHT, LEFT, BOTTOM, NONE
}
/**
* Methods for custom transitions from the sides
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIViewController {
    
    /**
    Show view controller from the side.
    See also dismissViewControllerToSide()
    
    - parameter viewController: the view controller to show
    - parameter side:           the side to move the view controller from
    - parameter bounds:         the bounds of the view controller
    - parameter callback:       the callback block to invoke after the view controller is shown and stopped
    */
    func showViewControllerFromSide(viewController: UIViewController,
        inContainer containerView: UIView, bounds: CGRect, side: TRANSITION, _ callback:(()->())? = nil) {
            // New view
            let toView = viewController.view;
            
            // Setup bounds for new view controller view
            toView.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight];
            var frame = bounds
            frame.origin.y = containerView.frame.height - bounds.height
            switch side {
            case .BOTTOM:
                frame.origin.y = containerView.frame.size.height // From bottom
            case .LEFT:
                frame.origin.x = -MenuWidth // From left
            case .RIGHT:
                frame.origin.x = containerView.frame.size.width // From right
            default:break
            }
            toView.frame = frame
            
            self.addChildViewController(viewController)
            containerView.addSubview(toView)
            
            UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1.0,
                initialSpringVelocity: 1.0, options: [], animations: { () -> Void in
                    switch side {
                    case .BOTTOM:
                        frame.origin.y = containerView.frame.height - bounds.height + bounds.origin.y
                    case .LEFT, .RIGHT:
                        frame.origin.x = 0
                    default:break
                    }
                    toView.frame = frame
                }) { (fin: Bool) -> Void in
                    viewController.didMoveToParentViewController(self)
                    callback?()
            }
    }
    
    /**
    Dismiss the view controller through moving it back to given side
    See also showViewControllerFromSide()
    
    - parameter viewController: the view controller to dismiss
    - parameter side:           the side to move the view controller to
    - parameter callback:       the callback block to invoke after the view controller is dismissed
    */
    func dismissViewControllerToSide(viewController: UIViewController, side: TRANSITION, _ callback:(()->())?) {
        UIView.animateWithDuration(0.3, delay: 0, usingSpringWithDamping: 1.0,
            initialSpringVelocity: 1.0, options: [], animations: { () -> Void in
                // Move back to bottom
                switch side {
                case .BOTTOM:
                    viewController.view.frame.origin.y = UIScreen.mainScreen().bounds.height
                case .LEFT:
                    viewController.view.frame.origin.x = -MenuWidth
                    viewController.view.alpha = 0
                case .RIGHT:
                    viewController.view.frame.origin.x = self.view.frame.size.width
                default:break
                }
                
            }) { (fin: Bool) -> Void in
                viewController.willMoveToParentViewController(nil)
                viewController.view.removeFromSuperview()
                viewController.removeFromParentViewController()
                callback?()
        }
    }
    
}

/**
* Helpful class to set preferred status bar
*
* @author Alexander Volkov
* @version 1.0
*/
class NavigationController: UINavigationController {
    
    /**
    Set dark status bar
    
    - returns: .Default
    */
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
}

// the main font prefix
let FONT_PREFIX = "SourceSansPro"

/**
* Common fonts used in the app
*
* @author Alexander Volkov
* @version 1.0
*/
struct Fonts {
    
    static var Regular = "\(FONT_PREFIX)-Regular"
    static var Bold = "\(FONT_PREFIX)-Bold"
    static var Thin = "\(FONT_PREFIX)-ExtraLight"
    static var ThinItalic = "\(FONT_PREFIX)-ExtraLightIt"
    static var Light = "\(FONT_PREFIX)-Light"
    static var Semibold = "\(FONT_PREFIX)-Semibold"
    static var Italic = "\(FONT_PREFIX)-It"
}

/**
* Applies default family fonts for UILabels from IB.
*
* @author Alexander Volkov
* @version 1.0
*/
extension UILabel {
    
    /**
    Applies default family fonts
    */
    public override func awakeFromNib() {
        super.awakeFromNib()
        applyDefaultFontFamily()
    }
    
    /**
    Applies default family fonts
    
    - parameter aDecoder: the decoder
    
    - returns: UILabel instance
    */
    public override func awakeAfterUsingCoder(aDecoder: NSCoder) -> AnyObject? {
        self.applyDefaultFontFamily()
        return self
    }
    
    /**
    Applies default family fonts
    */
    func applyDefaultFontFamily() {
        if font.fontName.contains("Thin", caseSensitive: false) {
            if font.fontName.contains("Italic", caseSensitive: false) {
                self.font = UIFont(name: Fonts.ThinItalic, size: self.font.pointSize)
            }
            else {
                self.font = UIFont(name: Fonts.Thin, size: self.font.pointSize)
            }
        }
        else if font.fontName.contains("Light", caseSensitive: false) {
            self.font = UIFont(name: Fonts.Light, size: self.font.pointSize)
        }
        else if font.fontName.contains("Semibold", caseSensitive: false) {
            self.font = UIFont(name: Fonts.Semibold, size: self.font.pointSize)
        }
        else if font.fontName.contains("Bold", caseSensitive: false) {
            self.font = UIFont(name: Fonts.Bold, size: self.font.pointSize)
        }
        else if font.fontName.contains("Italic", caseSensitive: false) {
            self.font = UIFont(name: Fonts.Italic, size: self.font.pointSize)
        }
        else if font.fontName.contains("Regular", caseSensitive: false) {
            self.font = UIFont(name: Fonts.Regular, size: self.font.pointSize)
        }
    }
}

/**
* Shortcut methods for UIView
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIView {
    
    /**
    Make round corners for the view
    
    - parameter radius: the radious of the corners
    */
    func roundCorners(radius: CGFloat = 2) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    /**
    Make the view round
    */
    func makeRound() {
        self.roundCorners(self.bounds.width / 2)
    }
    
    /**
    Add shadow to the view
    
    - parameter size: the size of the shadow
    */
    func addShadow(size: CGFloat = 2.5, var shift: CGFloat? = nil, opacity: Float = 1) {
        if shift == nil {
            shift = size
        }
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOffset = CGSizeMake(-shift!, 0)
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = size
    }
}

/**
* Extension to display alerts
*
* :author: TCSASSEMBLER
* :version: 1.0
*/
extension UIViewController {
    
    /**
    Displays alert with specified title & message
    
    - parameter title:   the title
    - parameter message: the message
    */
    func showAlert(title: String, _ message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK".localized(), style: UIAlertActionStyle.Default,
        handler: { (_) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

/**
* Extends UIView with shortcut methods
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIView {
    
    /**
    Adds bottom border to the view with given side margins
    
    - parameter height:  the height of the border
    - parameter color:   the border color
    - parameter margins: the left and right margin
    
    - returns: the border view
    */
    func addBottomBorder(height height: CGFloat = 1,
        color: UIColor = UIColor(r: 105, g: 154, b: 198), margins: CGFloat = 0) -> UIView {
        let border = UIView()
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(border)
        border.addConstraint(NSLayoutConstraint(item: border,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.Height,
            multiplier: 1, constant: height))
        self.addConstraint(NSLayoutConstraint(item: border,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: border,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1, constant: margins))
        self.addConstraint(NSLayoutConstraint(item: border,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1, constant: margins))
        return border
    }
    
    /**
    Add border for the view
    
    - parameter color:       the border color
    - parameter borderWidth: the size of the border
    */
    func addBorder(color: UIColor = UIColor.whiteColor(), borderWidth: CGFloat = 0.5) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = color.CGColor
    }
    
    /**
    Add border view for the view
    
    - parameter borderWidth: the size of the border
    - parameter color:       the border color
    - parameter shift:       the shift of the view (if used as a shadow)
    
    - returns: the view
    */
    func addBorderView(borderWidth: CGFloat = 2, color: UIColor = UIColor.whiteColor(),
        shift: CGSize = CGSizeZero) -> UIView {
        let border = UIView()
        border.backgroundColor = color
        border.translatesAutoresizingMaskIntoConstraints = false
        let superview = self.superview!
        superview.addSubview(border)

        superview.addConstraint(NSLayoutConstraint(item: border,
            attribute: NSLayoutAttribute.Top,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Top,
            multiplier: 1, constant: -borderWidth + shift.height))
        superview.addConstraint(NSLayoutConstraint(item: border,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1, constant: borderWidth + shift.height))
        superview.addConstraint(NSLayoutConstraint(item: border,
            attribute: NSLayoutAttribute.Leading,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Leading,
            multiplier: 1, constant: -borderWidth + shift.width))
        superview.addConstraint(NSLayoutConstraint(item: border,
            attribute: NSLayoutAttribute.Trailing,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self,
            attribute: NSLayoutAttribute.Trailing,
            multiplier: 1, constant: borderWidth + shift.width))
        superview.bringSubviewToFront(self)
        border.layoutIfNeeded()
        border.makeRound()
        return border
    }
    
}

/**
* Shortcut methods for UITableView
*
* @author Alexander Volkov
* @version 1.0
*/
extension UITableView {
    
    /**
    Prepares tableView to have zero margins for separator
    and removes extra separators after all rows
    */
    func separatorInsetAndMarginsToZero() {
        let tableView = self
        if tableView.respondsToSelector("setSeparatorInset:") {
            tableView.separatorInset = UIEdgeInsetsZero
        }
        if tableView.respondsToSelector("setLayoutMargins:") {
            tableView.layoutMargins = UIEdgeInsetsZero
        }
        
        // Remove extra separators after all rows
        tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    /**
    Register given cell class for the tableView.
    
    - parameter cellClass: a cell class
    */
    func registerCell(cellClass: UITableViewCell.Type) {
        let className = NSStringFromClass(cellClass).componentsSeparatedByString(".").last!
        let nib = UINib(nibName: className, bundle: nil)
        self.registerNib(nib, forCellReuseIdentifier: className)
    }
    
    /**
    Get cell of given class for indexPath
    
    - parameter indexPath: the indexPath
    - parameter cellClass: a cell class
    
    - returns: a reusable cell
    */
    func getCell<T: UITableViewCell>(indexPath: NSIndexPath, ofClass cellClass: T.Type) -> T {
        let className = NSStringFromClass(cellClass).componentsSeparatedByString(".").last!
        return self.dequeueReusableCellWithIdentifier(className, forIndexPath: indexPath) as! T
    }
}

/**
* Separator inset fix
*
* @author Alexander Volkov
* @version 1.0
*/
class ZeroMarginsCell: UITableViewCell {
    
    /// separator inset fix
    override var layoutMargins: UIEdgeInsets {
        get { return UIEdgeInsetsZero }
        set(newVal) {}
    }
}

/// type alias for image request callback
typealias ImageCallback = (UIImage?)->()
/// Cache for images
var CachedImages = [String: (UIImage?, [ImageCallback])]()

/**
* Extends UIImage with a shortcut method.
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIImage {
    
    /**
    Load image asynchronously
    
    - parameter url:      image URL
    - parameter callback: the callback to return the image
    */
    class func loadFromURLAsync(url: NSURL, callback: ImageCallback) {
        let key = url.absoluteString
        
        // If there is cached data, then use it
        if let data = CachedImages[key] {
            if data.1.isEmpty { // Is image already loadded, then use it
                callback(data.0)
            }
            else { // If image is not yet loaded, then add callback to the list of callbacks
                var savedCallbacks: [ImageCallback] = data.1
                savedCallbacks.append(callback)
                CachedImages[key] = (nil, savedCallbacks)
            }
            return
        }
        // If the image is first time requested, then load it
        CachedImages[key] = (nil, [callback])
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), {
            
            let imageData = NSData(contentsOfURL: url)
            dispatch_async(dispatch_get_main_queue(), {
                if let data = imageData {
                    if let image = UIImage(data: data) {
                        
                        // Notify all callbacks
                        for callback in CachedImages[key]!.1 {
                            callback(image)
                        }
                        CachedImages[key] = (image, [])
                        return
                    }
                    else {
                        print("ERROR: Error occured while creating image from the data: \(data)")
                    }
                }
                // No image - return nil
                callback(nil)
            })
        })
    }
    
    /**
    Load image asynchronously.
    More simple method than loadFromURLAsync() that helps to cover common fail cases
    and allow to concentrate on success loading.
    
    - parameter urlString: the url string
    - parameter callback:  the callback to return the image
    */
    class func loadAsync(urlString: String?, callback: (UIImage)->()) {
        if let urlStr = urlString {
            if urlStr.hasPrefix("http") {
                if let url = NSURL(string: urlStr) {
                    UIImage.loadFromURLAsync(url, callback: { (image: UIImage?) -> () in
                        if let img = image {
                            callback(img)
                        }
                    })
                }
            }
                // If urlString is not real URL, then try to load image from assets
            else if let image = UIImage(named: urlStr) {
                callback(image)
            }
        }
    }
}

/**
* Extension adds methods that change navigation bar
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIViewController {
    
    /**
    Changes navigation bar design
    */
    func setupNavigationBar(isTransparent isTransparent: Bool = false) {
        navigationController!.navigationBar.tintColor = UIColor.blue()
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: "nav-header-bg"
            + (isTransparent ? "-transparent" : "")),
            forBarMetrics: UIBarMetrics.Default)
        navigationController?.navigationBar.translucent = isTransparent
        if isTransparent {
            navigationController?.navigationBar.shadowImage = UIImage()
        }
        setupNavigationBarTitle()
    }
    
    /**
    Changes the navigation title style
    */
    func setupNavigationBarTitle() {
        // navigation title style
        let fontSize: CGFloat = 18
        let titleAttribute = [NSForegroundColorAttributeName: UIColor(r: 69, g: 85, b: 96),
            NSFontAttributeName:UIFont(name: Fonts.Regular, size: fontSize)!]
        navigationController?.navigationBar.titleTextAttributes = titleAttribute
    }
    
    /**
    Add right button to the navigation bar
    
    - parameter title:    the butotn title
    - parameter selector: the selector to invoke when tapped
    */
    func addRightButton(title: String, selector: Selector) {
        // Right navigation button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: createBarButton(title, selector: selector))
    }
    
    /**
    Add left button to the navigation bar
    
    - parameter title:    the butotn title
    - parameter selector: the selector to invoke when tapped
    */
    func addLeftButton(title: String, selector: Selector) {
        // Left navigation button
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: createBarButton(title, selector: selector))
    }
    
    /**
    Create button for the navigation bar
    
    - parameter title:    the butotn title
    - parameter selector: the selector to invoke when tapped
    
    - returns: the view
    */
    func createBarButton(title: String, selector: Selector) -> UIView {
        // Right navigation button
        let customBarButtonView = UIView(frame: CGRectMake(0, 0, 50, 30))
        let b = UIButton()
        b.addTarget(self, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        b.frame = CGRectMake(-5, 0, 60, 30);
        b.setAttributedTitle(createAttributedStringForNavigation(title), forState: UIControlState.Normal)
        
        customBarButtonView.addSubview(b)
        return customBarButtonView
    }
    
    /**
    Creates attributed string from given text.
    Returns uppercase string with a special font.
    
    - parameter text: the text
    
    - returns: NSMutableAttributedString
    */
    func createAttributedStringForNavigation(text: String) -> NSMutableAttributedString {
        let string = NSMutableAttributedString(string: text, attributes: [
            NSFontAttributeName: UIFont(name: Fonts.Regular, size: 18.0)!,
            NSForegroundColorAttributeName: UIColor(r: 0, g: 157, b: 206)
            ])
        return string
    }
    
    /**
    Initialize back button for current view controller
    */
    func addBackButton() {
        let customBarButtonView = UIView(frame: CGRectMake(0, 0, 40, 30))
        // Button
        let button = UIButton()
        button.addTarget(self, action: "backButtonAction", forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(-17, 0, 57, 30) // position like in design
        
        // Button icon
        button.setImage(UIImage(named: "iconBack"), forState: UIControlState.Normal)
        
        // Set custom view for bar button
        customBarButtonView.addSubview(button)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBarButtonView)
    }
    
    /**
    "Back" button action handler
    */
    func backButtonAction() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /**
    Add right button with given icon
    
    - parameter iconName: the name of the icon
    - parameter selector: the selector to invoke when tapped
    */
    func addRightButton(iconName iconName: String, selector: Selector) {
        let customBarButtonView = UIView(frame: CGRectMake(0, 0, 40, 30))
        // Button
        let button = UIButton()
        button.addTarget(self, action: selector, forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 59, 30) // position like in design
        
        // Button icon
        button.setImage(UIImage(named: iconName), forState: UIControlState.Normal)
        
        // Set custom view for bar button
        customBarButtonView.addSubview(button)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: customBarButtonView)
    }
}

/// the duration of the loading emulation
let LOADING_EMULATION_DURATION: NSTimeInterval = 0.5

/**
* Class for a general loading view (for api calls).
*
* @author Alexander Volkov
* @version 1.0
*/
class LoadingView: UIView {
    
    /// loading indicator
    var activityIndicator: UIActivityIndicatorView!
    
    /// flag: true - the view is terminated, false - else
    var terminated = false
    
    /// flag: true - the view is shown, false - else
    var didShow = false
    
    /// the reference to the parent view
    var parentView: UIView?
    
    /**
    Initializer
    
    - parameter parentView: the parent view
    - parameter dimming:    true - need to add semitransparent overlay, false - just loading indicator
    */
    init(_ parentView: UIView?, dimming: Bool = true) {
        super.init(frame: parentView?.bounds ?? UIScreen.mainScreen().bounds)
        
        self.parentView = parentView
        
        setupUI(dimming)
    }
    
    /**
    Required initializer
    */
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /**
    Adds loading indicator and changes colors
    
    - parameter dimming: true - need to add semitransparent overlay, false - just loading indicator
    */
    private func setupUI(dimming: Bool) {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.center = self.center
        activityIndicator.frame.origin.x = UIScreen.mainScreen().bounds.width / 2
        self.addSubview(activityIndicator)
        
        if dimming {
            self.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
             activityIndicator.activityIndicatorViewStyle = .Gray
        }
        else {
            self.backgroundColor = UIColor.clearColor()
        }
        self.alpha = 0.0
    }
    
    /**
    Removes the view from the screen
    */
    func terminate() {
        terminated = true
        if !didShow { return }
        UIView.animateWithDuration(0.25, animations: { _ in
            self.alpha = 0.0
            }, completion: { success in
                self.activityIndicator.stopAnimating()
                self.removeFromSuperview()
        })
    }
    
    /**
    Show the view
    */
    func show() {
        didShow = true
        if !terminated {
            if let view = parentView {
                view.addSubview(self)
                return
            }
            UIApplication.sharedApplication().delegate!.window!?.addSubview(self)
        }
    }
    
    /**
    Change alpha after the view is shown
    */
    override func didMoveToSuperview() {
        activityIndicator.startAnimating()
        UIView.animateWithDuration(0.25) {
            self.alpha = 0.75
        }
    }
}

/**
* Helpful extensions related to this app
*
* @author Alexander Volkov
* @version 1.0
*/
extension UIViewController {
    
    /// gets the root view controller
    var rootController: ContentViewController? {
        var parent: UIViewController? = self
        while (parent != nil) {
            if let parent = parent as? ContentViewController {
                return parent
            }
            parent = parent?.parentViewController
        }
        return nil
    }
    
    /**
    Open Dashboard
    
    - parameter animated: the animation flag
    */
    func openDashboard(animated: Bool) {
        if let vc = create(DashboardViewController) {
            if let root = rootController {
                root.setContentViewController(vc.wrapInNavigationController(), animated: animated)
            }
        }
    }
    
    /**
    Open Login screen from any of the content screens
    */
    func returnToLoginScreen() {
        // clean up any stored user information
        AuthenticationUtil.sharedInstance.cleanUp()
        
        // take the user back to the Sign In screen
        MenuViewControllerSelectedIndex = 0
        if let vc = rootController {
            if let root = vc as? RootViewController {
                root.openLoginScreen()
            }
            else {
                vc.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        closeMenu()
    }
    
    /**
    Add menu button
    */
    func addMenuButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "iconMenu"),
            style: .Plain, target: self, action: "showLeftSideMenuAction")
    }
    
    /**
    Add "Search" button
    */
    func addSearchButton() {
        self.navigationItem.rightBarButtonItem = createSearchItem()
    }
    
    /**
    Create "Search" bar button item
    
    - returns: the bar button item
    */
    func createSearchItem() -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "iconSearch"),
            style: .Plain, target: self, action: "searchButtonAction")
    }
    
    /**
    "Menu" button action handler
    */
    func showLeftSideMenuAction() {
        if let root = rootController {
            if let menu = root.getOpenedMenu() {
                menu.removeFromParent()
            }
            if let vc = create(MenuViewController.self) {
                root.showViewControllerFromSide(vc, inContainer: root.view, bounds: root.view.bounds, side: .LEFT)
            }
        }
    }
    
    /**
    Closes menu if opened
    */
    func closeMenu() {
        if let root = rootController {
            if let menu = root.getOpenedMenu() {
                dismissViewControllerToSide(menu, side: .LEFT, nil)
            }
        }
    }
    
    /**
    Check if menu is opened and return corresponding view controller
    
    - returns: menu view controller or nil
    */
    func getOpenedMenu() -> MenuViewController? {
        for viewController in self.childViewControllers {
            if let menuVC = viewController as? MenuViewController {
                return menuVC
            }
        }
        return nil
    }
    
    /**
    "Search" button action handler. Should be overridden in future.
    */
    func searchButtonAction() {
        showStub()
    }
}