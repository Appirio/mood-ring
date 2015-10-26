//
//  MyRatingViewController.swift
//  MoodRing
//
//  Created by Alexander Volkov on 10.10.15.
//  Modified by TCASSEMBLER in 20.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* My Rating screen
*
* @author Alexander Volkov, TCASSEMBLER
* @version 1.1
*
* changes:
* 1.1:
* - API integration
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
    @IBOutlet weak var noDataLabel: UILabel!
    
    /// the bottom lines in buttons
    var bottomLines = [UIView]()
    
    /// the projects to show
    var projects = [ProjectUser]()
    
    /// the selected cell
    var selectedIndex: NSIndexPath?
    
    /// Project filter: If not nil, the indicates which projects to show. If nil, then show all projects
    private var projectsStatusToRequest: ProjectStatus? = .Active
    
    /// the API
    private var api = MoodRingApi.sharedInstance
    
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
        
        // Show user details
        let loadingIndicator = LoadingView(self.topView, dimming: false)
        loadingIndicator.show()
        api.getAvgRatingHistory(AuthenticationUtil.sharedInstance.currentUser, callback: { (ratings) -> () in
            // User details
            if let vc = self.create(UserDetailsViewController.self) {
                vc.user = AuthenticationUtil.sharedInstance.currentUser
                vc.ratings = ratings
                
                vc.avgRatingOnAllProjects = AuthenticationUtil.sharedInstance.currentUser.avgAllProjectsRating
                vc.showThisProjectView = false
                vc.showBarDiagram = false
                vc.showSmiley = false
                self.loadViewController(vc, self.topView)
            }
            loadingIndicator.terminate()
            }, failure: createGeneralFailureCallback(loadingIndicator))
        
        loadProjects()
    }
    
    /**
    Load projects
    */
    func loadProjects() {
        self.projects = []
        self.tableView.reloadData()
        self.noDataLabel.hidden = true
        
        // Emulate project loading
        let loadingIndicator = LoadingView(self.listView, dimming: true)
        loadingIndicator.show()
        api.getProjectUsers(AuthenticationUtil.sharedInstance.currentUser,
            status: projectsStatusToRequest, callback: { (projects) -> () in
            self.projects = projects
            self.tableView.reloadData()
            if projects.isEmpty {
                self.noDataLabel.hidden = false
                self.noDataLabel.text = "MESSAGE_NO_MY_PROJECTS".localized()
            }
            loadingIndicator.terminate()
            }, failure: createGeneralFailureCallback(loadingIndicator))
    }
    
    /**
    One of the filter buttons action handler
    
    - parameter sender: the button
    */
    @IBAction func buttonAction(sender: UIButton) {
        highlightButton(sender)
        selectedIndex = nil
        
        // Change project filter
        switch sender {
        case button1:
            projectsStatusToRequest = .Active
        case button2:
            projectsStatusToRequest = .Completed
        default:
            projectsStatusToRequest = nil
        }

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
        let projectUser = projects[indexPath.row]
        if let vc = create(ProjectDetailsViewController.self) {
            vc.project = projectUser.project
            vc.myAverageRating = projectUser.avgProjectUserRating
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /**
    Open User Rating screen
    
    - parameter indexPath: the indexPath
    */
    func openUserRatingForIndexPath(indexPath: NSIndexPath) {
        let projectUser = projects[indexPath.row]
        if let vc = create(UserRatingInProjectViewController.self) {
            vc.projectUser = projectUser
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
* @author Alexander Volkov
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
    func configure(data: ProjectUser, indexPath: NSIndexPath) {
        self.indexPath = indexPath
        titleLabel.text = data.project.title
        
        // project icon
        iconView.image = UIImage(named: "defaultProjectIcon")
        iconBg.backgroundColor = data.project.tintColor
        UIImage.loadAsync(data.project.iconURL) { (image) -> () in
            self.iconView.image = image
        }
        
        // Average Rating for current user in given project
        projectRating.text = data.avgProjectUserRating.formatRating()
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
