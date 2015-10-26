//
//  HistoryViewController.swift
//  MoodRing
//
//  Created by Alexander Volkov on 10.10.15.
//  Modified by TCASSEMBLER in 20.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* History screen
*
* @author Alexander Volkov, TCASSEMBLER
* @version 1.1
*
* changes:
* 1.1:
* - API integration
*/
class HistoryViewController: UIViewController {
    
    /// outlets
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var noDataLabel: UILabel!

    /// the project
    var project: Project!
    
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
    Load the list of users
    */
    func loadUsersList() {
        noDataLabel.hidden = true
        
        // Load data
        let loadingIndicator = LoadingView(self.listView)
        loadingIndicator.show()
        api.getRatingHistory(project, date: self.currentDate, callback: { (ratingHistory) -> () in
            loadingIndicator.terminate()
            if !ratingHistory.isEmpty {
                if let dataForGivenDate = ratingHistory[self.currentDate.beginningOfDay()] {
                    
                    if let vc = self.create(UserListViewController.self) {
                        vc.items = UserListViewController.convertToUserListItems(dataForGivenDate)
                        vc.showHeader = false
                        self.listViewController = vc
                        self.loadViewController(vc, self.listView)
                    }
                    return
                }
                else {
                    self.noDataLabel.text = "NO_DATA_FOR_PERIOD".localized()
                }
            }
            else {
                self.noDataLabel.text = "NO_DATA_FOR_PROJECT".localized()
            }
            self.noDataLabel.hidden = false
            }, failure: createGeneralFailureCallback(loadingIndicator))
    }
}
