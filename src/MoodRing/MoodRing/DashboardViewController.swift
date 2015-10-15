//
//  DashboardViewController.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 08.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/// the sample projects for Dashboard screen
let SAMPLE_DASHBOARD_PROJECTS = [
    Project(id: "0", title: "HEALTHCARE PROJECT ABC", rating: 3.86, avgRating: 5, iconURL: "p1",
        tintColor: UIColor.raspberry(), funFactor: 3),
    Project(id: "1", title: "LOREM TECHNOLOGY PROJECT", rating: 4.86, avgRating: 4, iconURL: "p2",
        tintColor: UIColor.dark(), funFactor: 3),
    Project(id: "2", title: "ACME FINANCIAL PROJECT #1", rating: 3.86, avgRating: 3.5, iconURL: "p3",
        tintColor: UIColor.orange(), funFactor: 2),
    Project(id: "3", title: "ACME FINANCIAL PROJECT #2", rating: 3.86, avgRating: 3.6, iconURL: "p4",
        tintColor: UIColor.darkBlue(), funFactor: 4),
    Project(id: "4", title: "ACME FINANCIAL PROJECT #3", rating: 3.6, avgRating: 3.2, iconURL: "p3",
        tintColor: UIColor.orange(), funFactor: 4),
    Project(id: "5", title: "ACME FINANCIAL PROJECT #4", rating: 3.8, avgRating: 3.0, iconURL: "p3",
        tintColor: UIColor.orange(), funFactor: 4),
]

/**
* Dashboard screen
*
* @author TCASSEMBLER
* @version 1.0
*/
class DashboardViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /// outlets
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var smileImage: UIImageView!
    @IBOutlet weak var tapHelpLabel: UILabel!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var smileSize: NSLayoutConstraint!
    @IBOutlet weak var smileTopMargin: NSLayoutConstraint!
    @IBOutlet weak var smileButton: UIButton!
    @IBOutlet var statisticViews: [UILabel]!
    @IBOutlet weak var listView: UIView!
    
    /// the bottom lines in buttons
    var bottomLines = [UIView]()
    
    /// the projects to show
    var projects: [Project] = []
    
    /// flag: true - is manager's dashboard, false - for common user
    var isManager = AuthenticationUtil.sharedInstance.isManager
    
    /// current fun factor index
    var currentFunFactor: Int? {
        didSet {
            updateFunFactor()
        }
    }
    
    /// the default color for topView
    private var defaultTopViewColor: UIColor!
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        addMenuButton()
        addSearchButton()
        
        // Top area
        defaultTopViewColor = topView.backgroundColor
        
        // Buttons
        for b in buttons {
            let border = b.addBottomBorder(height: 3)
            bottomLines.append(border)
            border.hidden = true
        }
        highlightButton(button1)
        
        // Table
        tableView.separatorInsetAndMarginsToZero()
        
        loadData()
    }
    
    /**
    Updates fun factor
    */
    func updateFunFactor() {
        tapHelpLabel?.hidden = currentFunFactor != nil
        smileSize?.constant = currentFunFactor == nil ? 56 : 70 // like in design
        smileTopMargin?.constant =  currentFunFactor == nil ? 19 : 22 // like in design
        if let currentFunFactor = currentFunFactor {
            smileImage?.applyFunFactor(currentFunFactor, addWhiteBorder: 5, addShadow: 3)
            topView?.backgroundColor = UIColor.funFactorColor(currentFunFactor)
            for view in statisticViews {
                view.hidden = false
            }
        }
            // Gray smiley means that nothing is selected
        else {
            smileImage?.applyFunFactor(-1, addWhiteBorder: 4, addShadow: 2)
            smileImage?.image = UIImage(named: "smile3")
            smileImage?.tintColor = UIColor(r: 204, g: 204, b: 204)
            topView?.backgroundColor = defaultTopViewColor
            for view in statisticViews {
                view.hidden = true
            }
        }
        smileButton?.superview?.bringSubviewToFront(smileButton)
    }
    
    /**
    Load data. Will be updated in future.
    */
    func loadData() {
        updateFunFactor()
        // Emulate loading
        projects = []
        tableView.reloadData()
        let loadingIndicator = LoadingView(self.listView, dimming: true)
        loadingIndicator.show()
        delay(LOADING_EMULATION_DURATION) { () -> () in
            
            self.projects = SAMPLE_DASHBOARD_PROJECTS
            self.tableView.reloadData()
            loadingIndicator.terminate()
        }
    }
    
    /**
    One of the filter buttons action handler
    
    - parameter sender: the button
    */
    @IBAction func buttonAction(sender: UIButton) {
        highlightButton(sender)
        loadData()
    }
    
    /**
    Highlight given button
    
    - parameter button: the button
    */
    func highlightButton(button: UIButton) {
        if let index = buttons.indexOf(button) {
            for line in bottomLines {
                line.hidden = true
            }
            bottomLines[index].hidden = false
        }
    }
    
    /**
    "Set Fun Factor" button action handler
    
    - parameter sender: the button
    */
    @IBAction func setFunFactorAction(sender: AnyObject) {
        if let vc = create(SetFunFactorViewController.self) {
            vc.selectedIndex = currentFunFactor
            vc.delegate = { (index, comment) -> () in
                self.currentFunFactor = index
            }
            self.presentViewController(vc.wrapInNavigationController(), animated: true, completion: nil)
        }
    }
    
    /**
    Show Search view
    */
    override func searchButtonAction() {
        if let vc = create(SearchViewController.self) {
            if let root = rootController {
                root.loadViewController(vc, root.view)
            }
        }
    }
    
    // MARK: UITableViewDataSource, UITableViewDelegate
    
    /**
    Get number of cells
    
    - parameter tableView: the tableView
    - parameter section:   the section index
    
    - returns: number of projects
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    /**
    Get cell for the indexPath
    
    - parameter tableView: the tableView
    - parameter indexPath: the indexPath
    
    - returns: the cell
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.getCell(indexPath, ofClass: DashboardTableViewCell.self)
        cell.configure(projects[indexPath.row], isManager: isManager)
        return cell
    }
    
    /**
    Tap on a cell action handler
    
    - parameter tableView: the tableView
    - parameter indexPath: the indexPath
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let vc = create(ProjectDetailsViewController.self) {
            vc.project = projects[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

/**
* Cell for the dashboard project list
*
* @author TCASSEMBLER
* @version 1.0
*/
class DashboardTableViewCell: ZeroMarginsCell {
    
    /// outlets
    @IBOutlet weak var iconBg: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var projectRating: UILabel!
    @IBOutlet weak var otherRatingTitleLabel: UILabel!
    @IBOutlet weak var otherRating: UILabel!
    @IBOutlet weak var funIcon: UIImageView!
    @IBOutlet weak var funIconViewWidth: NSLayoutConstraint!
    
    /**
    Setup UI
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        iconBg.makeRound()
        selectionStyle = .None
    }
    
    /**
    Update UI with data
    
    - parameter data:   the project data
    - parameter isManager: true - should show funIcon, false - else
    */
    func configure(data: Project, isManager: Bool) {
        titleLabel.text = data.title
        funIcon.hidden = !isManager
        funIconViewWidth.constant = isManager ? 85 : 39 // compliance to the design
            
        // project icon
        iconView.image = UIImage(named: "defaultProjectIcon")
        iconBg.backgroundColor = data.tintColor
        UIImage.loadAsync(data.iconURL) { (image) -> () in
            self.iconView.image = image
        }
        
        projectRating.text = data.rating.formatRating()
        otherRating.text = data.avgRating.formatRating()
        otherRatingTitleLabel.text = isManager ? "AVG_RATING".localized() : "MY_AVG".localized()
        
        funIcon.applyFunFactor(data.funFactor)
    }
}

/**
* Helpfull classs to store border and shadow view reference
*
* @author TCASSEMBLER
* @version 1.0
*/
class SmileyImageView: UIImageView {
    
    /// the border view
    var borderView: UIView?
    
    /// the border view
    var shadowView: UIView?
}

/**
* Helpful methods related to the design
*
* @author TCASSEMBLER
* @version 1.0
*/
extension UIImageView {
    
    /**
    Changes fun factor image
    
    - parameter index:          the index of the fun factor
    - parameter addWhiteBorder: flag - add border with given width, false - do not add
    - parameter addShadow:      flag - add shadow with given shift, false - do not add
    */
    func applyFunFactor(index: Int?, addWhiteBorder: CGFloat? = nil, addShadow:
        CGFloat? = nil){
            if hidden {
                return
            }
        if let index = index {
            if index >= 0 {
                self.image = UIImage(named: "smile\(index+1)")
                self.tintColor = UIColor.funFactorColor(index)
            }
        }
        if let borderWidth = addWhiteBorder {
            if let s = self as? SmileyImageView {
                s.borderView?.removeFromSuperview()
                s.shadowView?.removeFromSuperview()
            }
            if let shift = addShadow {
                let shadow = self.addBorderView(borderWidth, color: UIColor(white: 0, alpha: 0.1),
                    shift: CGSizeMake(shift, shift))
                (self as? SmileyImageView)?.shadowView = shadow
            }
            let border = self.addBorderView(borderWidth)
            (self as? SmileyImageView)?.borderView = border
            
        }
        
    }
}