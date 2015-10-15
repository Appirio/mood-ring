//
//  MemberDetailsViewController.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 10.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/// sample comments
let SAMPLE_COMMENTS = ["He has been doing great.",
                    "Feedback goes here",
                    "All projects went well.",
                    "Everything goes as we planned."]

/// sample users for the lists
let SAMPLE_MEMBER_DETAILS_USERS = [
    User(id: "6", "John Doe", rating: 5, funFactor: 1, iconUrl: "ava5"),
    User(id: "2", "Jane Snow", rating: 4, funFactor: 3, iconUrl: "ava1"),
    User(id: "3", "John Scott", rating: 4, funFactor: 4, iconUrl: "ava2"),
    User(id: "4", "Greg Water", rating: 3, funFactor: 2, iconUrl: "ava3"),
    User(id: "5", "Tom Jones", rating: 3, funFactor: 3, iconUrl: "ava4"),
]

/**
* Member Details screen
*
* @author TCASSEMBLER
* @version 1.0
*/
class MemberDetailsViewController: UIViewController {

    /// The sample value for "AVG ON ALL PROJECTS". Will be loaded in future from a data source
    let SAMPLE_ALL_PROJECTS_RATING: Float = 4.25
    
    /// outlets
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var listView: UIView!
    
    /// the user data to show
    var userData: User!
    
    /// the related project
    var project: Project!
    
    /// the average rating for all projects
    var avgRatingOnThisProject: Float = 0
    
    /// the reference to list view controller
    private var listViewController: UserListViewController?
    
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
        // Emulate loading user details
        let detailsLoadingIndicator = LoadingView(self.topView, dimming: false)
        detailsLoadingIndicator.show()
        delay(LOADING_EMULATION_DURATION) { () -> () in
            
            // User details
            self.addUserDetailsSection(self.userData)
            detailsLoadingIndicator.terminate()
        }
    }
    
    /**
    Add User Details view and fill with given data
    
    - parameter userData: the user's data to show
    */
    func addUserDetailsSection(userData: User) {
        // User Details section
        if let vc = self.create(UserDetailsViewController.self) {
            vc.user = userData
            vc.avgRatingOnThisProject = self.avgRatingOnThisProject
            vc.avgRatingOnAllProjects = self.SAMPLE_ALL_PROJECTS_RATING
            self.loadViewController(vc, self.topView)
        }
    }

    /**
    Load a list of users
    */
    func loadUsersList() {
        loadSampleUsersList(SAMPLE_MEMBER_DETAILS_USERS)
    }
    
    /**
    The method used in the prototype to load sample items
    */
    func loadSampleUsersList(sampleUsers: [User]) {
        // Emulate loading the list of users
        let listLoadingIndicator = LoadingView(self.listView)
        listLoadingIndicator.show()
        delay(LOADING_EMULATION_DURATION) { () -> () in
            var items = [(User, String)]()
            for i in 0..<sampleUsers.count {
                items.append((sampleUsers[i], SAMPLE_COMMENTS[i % SAMPLE_COMMENTS.count]))
            }
            
            self.addUsersList(items)
            listLoadingIndicator.terminate()
        }
    }
    
    /**
    Add a list of users with given data
    
    - parameter items: the items to show in the table
    */
    func addUsersList(items: [(User, String)]) {
        if let vc = self.create(UserListViewController.self) {
            vc.items = items
            self.listViewController = vc
            self.loadViewController(vc, self.listView)
        }
    }
}
