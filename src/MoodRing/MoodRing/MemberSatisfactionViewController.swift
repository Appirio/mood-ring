//
//  MemberSatisfactionViewController.swift
//  MoodRing
//
//  Created by Alexander Volkov on 10.10.15.
//  Modified by TCASSEMBLER in 20.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit
import UIComponents

/**
* Overall Members' Satisfaction screen
*
* @author Alexander Volkov, TCASSEMBLER
* @version 1.1
*
* changes:
* 1.1:
* - API integration
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
    @IBOutlet weak var noDataLabel: UILabel!
    
    /// the project
    var project: Project!
    
    /// the project's fun factor
    var overAllProjectFunFactor = 2
    
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
                self.currentDate = date
                
                // Reload user's list
                self.listViewController?.removeFromParent()
                self.loadUsersList()
            }
            self.loadViewController(vc, filterView)
        }
        
        // List of users
        loadUsersList()
        
        // Update bar diagram
        barDiagramView.hidden = true
        api.getFunFactorHistory(project, callback: { (data) -> () in
            self.updateBarDiagram(data)
            }, failure: createGeneralFailureCallback())
        barDiagramView.colors = UIColor.funFactorColors()
    }
    
    /**
    Load the list of users
    */
    func loadUsersList() {
        // Load the list of users
        let listLoadingIndicator = LoadingView(self.listView)
        listLoadingIndicator.show()
        noDataLabel.hidden = true

        api.getFunFactorHistory(project, date: self.currentDate, callback: { (data) -> () in
           listLoadingIndicator.terminate()

            if !data.isEmpty {
                if let dataForGivenDate = data[self.currentDate.beginningOfDay()] {
                    var items = [UserListItem]()
                    for item in dataForGivenDate {
                        items.append((user: item.0, funFactorItem: item.1, rating: 0, comment: item.1.comment))
                    }
                    if let vc = self.create(UserListViewController.self) {
                        vc.items = items
                        vc.showHeader = false
                        vc.showSmiley = true
                        vc.showRating = false
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
        }, failure: createGeneralFailureCallback(listLoadingIndicator))
    }
    
    /**
    Update bar diagram
    
    - parameter data: the fun factors
    */
    func updateBarDiagram(data: [NSDate: [(User, FunFactorItem)]]) {
        
        var funFactors: [FunFactorItem] = []
        for (_,v) in data {
            funFactors.appendContentsOf(v.map({$1}))
        }
        self.barDiagramView.hidden = false
        var data: [Int] = [0]
        data.appendContentsOf(funFactors.sort({$0.date.compare($1.date) == .OrderedAscending}).map({$0.funFactor + 1}))
        data.append(0)
        self.barDiagramView.data = data
        delay(0.3) { () -> () in
            self.barDiagramView.animateBarDiagram()
        }
    }
    
}
