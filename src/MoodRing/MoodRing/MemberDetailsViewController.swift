//
//  MemberDetailsViewController.swift
//  MoodRing
//
//  Created by Alexander Volkov on 10.10.15.
//  Modified by TCASSEMBLER in 20.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* Member Details screen
*
* @author Alexander Volkov, TCASSEMBLER
* @version 1.1
*
* changes:
* 1.1:
* - API integration
*/
class MemberDetailsViewController: UIViewController {
    
    /// outlets
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    /// the user data to show
    var projectUser: ProjectUser!
    
    /// the reference to list view controller
    private var listViewController: UserListViewController?
    
    /// the API
    private var api = MoodRingApi.sharedInstance
    
    /// current selected date
    private var currentDate = NSDate()
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        addBackButton()
        
        loadData()
    }
    
    /**
    Load and show data.
    Currently the loading is emulated. Will be changed in future to load data from a data source
    */
    func loadData() {
        
        // User Details
        loadUserDetails()
        
        // Filter
        if let vc = create(FilterViewController.self) {
            vc.dateChanged = { (date)->() in
                self.currentDate = date
                
                // Reload user's list
                self.listViewController?.removeFromParent()
                self.loadUsersList()
            }
            self.loadViewController(vc, filterView)
        }
        
        // List of users
        loadUsersList()
    }
    
    /**
    Load user details
    */
    func loadUserDetails() {
        // Load user details
        let loadingIndicator = LoadingView(self.topView, dimming: false)
        loadingIndicator.show()
        
        // Get ratings for plot graph
        api.getAvgRatingHistory(projectUser, callback: { (ratings) -> () in
            
            // Get fun factors for bar graph
            self.api.getFunFactorHistory(self.projectUser.user, callback: { (funFactors) -> () in
                
                self.addUserDetailsSection(self.projectUser, ratings: ratings, funFactors: funFactors)
                loadingIndicator.terminate()
                
                }, failure: self.createGeneralFailureCallback(loadingIndicator))
            }, failure: createGeneralFailureCallback(loadingIndicator))
    }
    
    /**
    Add User Details view and fill with given data
    
    - parameter projectUser: the user's data to show
    - parameter ratings:     the list of ratings to show
    - parameter funFactors:  the list of fun factors to show
    */
    func addUserDetailsSection(projectUser: ProjectUser, ratings: [Rating], funFactors: [FunFactorItem]) {
        // User Details section
        if let vc = self.create(UserDetailsViewController.self) {
            vc.user = projectUser.user
            vc.ratings = ratings
            vc.funFactors = funFactors
            vc.avgRatingOnThisProject = projectUser.avgProjectUserRating
            vc.avgRatingOnAllProjects = projectUser.user.avgAllProjectsRating
            self.loadViewController(vc, self.topView)
        }
    }

    /**
    Load a list of users
    */
    func loadUsersList() {
        noDataLabel.hidden = true
        let loadingIndicator = LoadingView(self.listView)
        loadingIndicator.show()
        
        api.getRatingHistory([projectUser], date: self.currentDate, callback: { (ratingHistory) -> () in
            loadingIndicator.terminate()
            if !ratingHistory.isEmpty {
                if let dataForGivenDate = ratingHistory[self.currentDate.beginningOfDay()] {
                    
                    self.addUsersList(UserListViewController.convertToUserListItems(dataForGivenDate))
                    return
                }
                else {
                    self.noDataLabel.text = "NO_DATA_FOR_PERIOD".localized()
                }
            }
            else {
                self.noDataLabel.text = "NO_DATA_FOR_USER".localized()
            }
            self.noDataLabel.hidden = false
        }, failure: createGeneralFailureCallback(loadingIndicator))
    }
    
    /**
    Add a list of users with given data
    
    - parameter items: the items to show in the table
    */
    func addUsersList(items: [UserListItem]) {
        if let vc = self.create(UserListViewController.self) {
            vc.items = items
            self.listViewController = vc
            self.loadViewController(vc, self.listView)
        }
    }
}
