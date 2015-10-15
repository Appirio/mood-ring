//
//  HistoryViewController.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 10.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/// sample users for the screen
let SAMPLE_HISTORY_USERS = [
    User(id: "1", "Jackblack Longnamous", rating: 5, funFactor: 4, iconUrl: "ava0"),
    User(id: "2", "Jane Snow", rating: 4, funFactor: 3, iconUrl: "ava1"),
    User(id: "3", "John Scott", rating: 4, funFactor: 3, iconUrl: "ava2"),
    User(id: "4", "Greg Water", rating: 3, funFactor: 2, iconUrl: "ava3"),
    User(id: "5", "Tom Jones", rating: 3, funFactor: 3, iconUrl: "ava4")
]


/**
* History screen
*
* @author TCASSEMBLER
* @version 1.0
*/
class HistoryViewController: UIViewController {
    
    /// outlets
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var listView: UIView!

    /// the project
    var project: Project!
    
    /// the reference to list view controller
    private var listViewController: UserListViewController?

    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        addBackButton()
    }

    /**
    Update UI
    
    - parameter animated: the animation flag
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        loadHistoryData(project)
    }

    /**
    Load and show data.
    Currently the loading is emulated. Will be changed in future to load data from a data source
    
    - parameter project: the project
    */
    func loadHistoryData(project: Project) {
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
    Load the list of users
    */
    func loadUsersList() {
        // Emulate loading the list of users
        let listLoadingIndicator = LoadingView(self.listView)
        listLoadingIndicator.show()
        delay(LOADING_EMULATION_DURATION) { () -> () in
            var items = [(User, String)]()
            for i in 0..<SAMPLE_HISTORY_USERS.count {
                items.append((SAMPLE_HISTORY_USERS[i],
                    SAMPLE_COMMENTS[i % SAMPLE_COMMENTS.count])) // first 2 comments like in design
            }
            
            if let vc = self.create(UserListViewController.self) {
                vc.items = items
                vc.showHeader = false
                self.listViewController = vc
                self.loadViewController(vc, self.listView)
            }
            listLoadingIndicator.terminate()
        }
    }
}
