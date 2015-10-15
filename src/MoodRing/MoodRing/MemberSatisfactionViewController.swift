//
//  MemberSatisfactionViewController.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 10.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit
import UIComponents

/// sample users for the screen
let SAMPLE_OVERALL_SATISFACTION_USERS = [
    User(id: "6", "John Doe", rating: 5, funFactor: 4, iconUrl: "ava5"),
    User(id: "1", "Jackblack Longnamous", rating: 3.86, funFactor: 4, iconUrl: "ava0"),
    User(id: "2", "Jane Snow", rating: 4, funFactor: 3, iconUrl: "ava1"),
    User(id: "3", "John Scott", rating: 4, funFactor: 3, iconUrl: "ava2"),
    User(id: "4", "Greg Water", rating: 3, funFactor: 2, iconUrl: "ava3")
]

/**
* Overall Members' Satisfaction screen
*
* @author TCASSEMBLER
* @version 1.0
*/
class MemberSatisfactionViewController: UIViewController {

    /// outlets
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var iconBg: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var smileView: UIImageView!
    @IBOutlet weak var filterView: UIView!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var barDiagramView: BarDiagram!
    
    /// the project
    var project: Project!
    
    /// the project's fun factor
    var overAllProjectFunFactor = 2
    
    /// the reference to list view controller
    private var listViewController: UserListViewController?
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        addBackButton()
        
        iconBg.makeRound()
        
        // Bar diagram
        barDiagramView.graphBottomMargin = 0
    }
    
    /**
    Update UI
    
    - parameter animated: the animation flag
    */
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateUI(project)
    }
    
    /**
    Turn off animation if the view will disappear
    
    - parameter animated: the animation flag
    */
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.barDiagramView.stopAnimation()
    }
    
    /**
    Update UI with data
    */
    func updateUI(data: Project) {
        
        // project icon
        iconView.image = UIImage(named: "defaultProjectIcon")
        iconBg.backgroundColor = data.tintColor
        UIImage.loadAsync(data.iconURL) { (image) -> () in
            self.iconView.image = image
        }
        smileView.applyFunFactor(overAllProjectFunFactor, addWhiteBorder: 2, addShadow: 2)
        topView.backgroundColor = UIColor.funFactorColor(overAllProjectFunFactor)
        loadData()
    }
    
    /**
    Load and show data.
    Currently the loading is emulated. Will be changed in future to load data from a data source
    */
    func loadData() {
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
        
        // Update bar diagram
        barDiagramView.data = Int.generateRandomSampleValuesForBarDiagram()
        barDiagramView.colors = UIColor.funFactorColors()
        
        delay(0.3) { () -> () in
            self.barDiagramView.animateBarDiagram()
        }
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
            for i in 0..<SAMPLE_OVERALL_SATISFACTION_USERS.count {
                items.append((SAMPLE_OVERALL_SATISFACTION_USERS[i],
                    SAMPLE_COMMENTS[(2 + i) % SAMPLE_COMMENTS.count])) // first 2 comments like in design
            }
            
            if let vc = self.create(UserListViewController.self) {
                vc.items = items
                vc.showHeader = false
                vc.showSmiley = true
                vc.showRating = false
                self.listViewController = vc
                self.loadViewController(vc, self.listView)
            }
            listLoadingIndicator.terminate()
        }
    }
}
