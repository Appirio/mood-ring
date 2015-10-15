//
//  MyRatingViewController.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 10.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/// the list of sample projects for "My Rating" screen
let SAMPLE_PROJECTS_MY_RATING = [
    Project(id: "0", title: "HEALTHCARE PROJECT ABC", rating: 5, avgRating: 5, iconURL: "p1",
        tintColor: UIColor.raspberry(), funFactor: 3),
    Project(id: "1", title: "LOREM TECHNOLOGY PROJECT", rating: 4, avgRating: 4, iconURL: "p2",
        tintColor: UIColor.dark(), funFactor: 3),
    Project(id: "2", title: "ACME FINANCIAL PROJECT", rating: 4.5, avgRating: 3.5, iconURL: "p3",
        tintColor: UIColor.orange(), funFactor: 2)
]

/**
* My Rating screen
*
* @author TCASSEMBLER
* @version 1.0
*/
class MyRatingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /// the heights of the cell in different states
    let CELL_HEIGHT_COLLAPSED: CGFloat = 91
    let CELL_HEIGHT_EXPANDED: CGFloat = 91 + 82
    
    /// outlets
    @IBOutlet weak var topView: UIView!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    /// the bottom lines in buttons
    var bottomLines = [UIView]()
    
    /// the projects to show
    var projects = [Project]()
    
    /// the selected cell
    var selectedIndex: NSIndexPath?
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        addMenuButton()
        addSearchButton()
        
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
    Load data. Will be updated in future.
    */
    func loadData() {
        
        // Emulate loading user details
        let detailsLoadingIndicator = LoadingView(self.topView, dimming: false)
        detailsLoadingIndicator.show()
        delay(LOADING_EMULATION_DURATION) { () -> () in
            // User details
            if let vc = self.create(UserDetailsViewController.self) {
                vc.user = AuthenticationUtil.sharedInstance.currentUser
                vc.avgRatingOnAllProjects = AuthenticationUtil.sharedInstance.currentUser.rating
                vc.showThisProjectView = false
                vc.showBarDiagram = false
                vc.showSmiley = false
                self.loadViewController(vc, self.topView)
            }
            detailsLoadingIndicator.terminate()
        }
        
        loadProjects()
    }
    
    /**
    Load projects
    */
    func loadProjects() {
        self.projects = []
        self.tableView.reloadData()
        
        // Emulate project loading
        let projectsLoadingIndicator = LoadingView(self.listView, dimming: true)
        projectsLoadingIndicator.show()
        delay(LOADING_EMULATION_DURATION) { () -> () in
            
            self.projects = SAMPLE_PROJECTS_MY_RATING
            self.tableView.reloadData()
            projectsLoadingIndicator.terminate()
        }
    }
    
    /**
    One of the filter buttons action handler
    
    - parameter sender: the button
    */
    @IBAction func buttonAction(sender: UIButton) {
        highlightButton(sender)
        selectedIndex = nil
        loadProjects()
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
        let cell = tableView.getCell(indexPath, ofClass: MyRatingTableViewCell.self)
        cell.configure(projects[indexPath.row], indexPath: indexPath)
        cell.parent = self
        return cell
    }
    
    /**
    Tap on a cell action handler
    
    - parameter tableView: the tableView
    - parameter indexPath: the indexPath
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == (selectedIndex?.row ?? -1) {
            selectedIndex = nil
            tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        else {
            let indexPathsToReload = selectedIndex == nil ? [NSIndexPath]() : [selectedIndex!]
            selectedIndex = indexPath
            tableView.reloadRowsAtIndexPaths(indexPathsToReload, withRowAnimation: .Fade)
        }
    }
    
    /**
    Open Project Details screen
    
    - parameter indexPath: the indexPath
    */
    func openProjectDetails(indexPath: NSIndexPath) {
        let project = projects[indexPath.row]
        if let vc = create(ProjectDetailsViewController.self) {
            vc.project = project
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /**
    Open User Rating screen
    
    - parameter indexPath: the indexPath
    */
    func openUserRatingForIndexPath(indexPath: NSIndexPath) {
        let project = projects[indexPath.row]
        if let vc = create(UserRatingInProjectViewController.self) {
            vc.userData = AuthenticationUtil.sharedInstance.currentUser
            vc.project = project
            vc.avgRatingOnThisProject = project.rating
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /**
    Get height for the cell
    
    - parameter tableView: the tableView
    - parameter indexPath: the indexPath
    
    - returns: the height
    */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == (selectedIndex?.row ?? -1) {
            return CELL_HEIGHT_EXPANDED
        }
        return CELL_HEIGHT_COLLAPSED
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
    
}

/**
* Cell for the My Rating project list
*
* @author TCASSEMBLER
* @version 1.0
*/
class MyRatingTableViewCell: ZeroMarginsCell {
    
    /// outlets
    @IBOutlet weak var iconBg: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var projectRating: UILabel!

    /// the reference to parent view controller
    var parent: MyRatingViewController?
    
    /// the related indexPath
    var indexPath: NSIndexPath!
    
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
    
    - parameter data:      the project data
    - parameter indexPath: the indexPath
    */
    func configure(data: Project, indexPath: NSIndexPath) {
        self.indexPath = indexPath
        titleLabel.text = data.title
        
        // project icon
        iconView.image = UIImage(named: "defaultProjectIcon")
        iconBg.backgroundColor = data.tintColor
        UIImage.loadAsync(data.iconURL) { (image) -> () in
            self.iconView.image = image
        }
        
        projectRating.text = data.rating.formatRating()
    }
    
    /**
    "View Rating History" button action handler
    
    - parameter sender: the button
    */
    @IBAction func ratingHistoryAction(sender: AnyObject) {
        parent?.openUserRatingForIndexPath(indexPath)
    }
    
    /**
    "View Project Details" button action handler
    
    - parameter sender: the button
    */
    @IBAction func projectDetailsAction(sender: AnyObject) {
        parent?.openProjectDetails(indexPath)
    }
}
