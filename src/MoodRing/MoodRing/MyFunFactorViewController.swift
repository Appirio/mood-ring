//
//  MyFunFactorViewController.swift
//  MoodRing
//
//  Created by Alexander Volkov on 10.10.15.
//  Modified by TCASSEMBLER in 20.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit
import UIComponents

/// the sample comment for current fun factor state
let SAMPLE_CURRENT_COMMENT = "All projects went well"

/**
* My Fun Factor screen
*
* @author Alexander Volkov, TCASSEMBLER
* @version 1.1
*
* changes:
* 1.1:
* - API integration
*/
class MyFunFactorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    /// outlets
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var smileView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var listView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var barDiagramView: BarDiagram!
    @IBOutlet weak var noDataLabel: UILabel!
    
    /// the items to show
    var items = [FunFactorItem]()
    
    /// the API
    private var api = MoodRingApi.sharedInstance
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        addMenuButton()
        iconView.makeRound()
        
        tableView.separatorInsetAndMarginsToZero()
        tableView.separatorColor = UIColor.clearColor()
        
        // Bar diagram
        barDiagramView.graphBottomMargin = 0
        
        loadData()
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
    Load data and show
    */
    func loadData() {
        // Reset UI
        titleLabel.text = ""
        noDataLabel.hidden = true
        barDiagramView.hidden = true
        
        // Load fun factor history
        let loadingIndicator = LoadingView(self.listView, dimming: true)
        loadingIndicator.show()
        api.getFunFactorHistory(AuthenticationUtil.sharedInstance.currentUser, callback: { (items) -> () in
            
            self.items = items
            self.tableView.reloadData()
            if items.isEmpty {
                self.noDataLabel.hidden = false
                self.noDataLabel.text = "NO_FUN_FACTOR_HISTORY".localized()
            }
            
            // Bar diagram
            self.barDiagramView.hidden = false
            var data: [Int] = [0]
            data.appendContentsOf(items.sort({$0.date.compare($1.date) == .OrderedAscending}).map({$0.funFactor + 1}))
            data.append(0)
            self.barDiagramView.data = data
            
            loadingIndicator.terminate()
            
            // Assign last fun factor to the current user
            if !items.isEmpty {
                AuthenticationUtil.sharedInstance.currentUser.funFactor = items[0]
            }
            self.updateUI(AuthenticationUtil.sharedInstance.currentUser)
            
        }, failure: createGeneralFailureCallback(loadingIndicator))
    }
    
    /**
    Update UI with data
    
    - parameter data: the user's data
    */
    func updateUI(data: User) {
        
        // Top area
        UIImage.loadAsync(data.iconUrl) { (image) -> () in
            self.iconView.image = image
        }
        
        let funFactorItem = AuthenticationUtil.sharedInstance.currentUser.getFunFactorItem()
        smileView.applyFunFactor(funFactorItem.funFactor,
            addWhiteBorder: 2, addShadow: 2)
        topView.backgroundColor = UIColor.funFactorColor(funFactorItem.funFactor)
        let comment = funFactorItem.comment
        if !comment.isEmpty {
            titleLabel.text = "\"\(comment)\""
        }
        
        // Update bar diagram
        barDiagramView.colors = UIColor.funFactorColors()
        
        delay(0.3) { () -> () in
            self.barDiagramView.animateBarDiagram()
        }
    }
    
    // MARK: UITableViewDataSource, UITableViewDelegate
    
    /**
    Get number of cells
    
    - parameter tableView: the tableView
    - parameter section:   the section index
    
    - returns: number of items
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    /**
    Get cell for the indexPath
    
    - parameter tableView: the tableView
    - parameter indexPath: the indexPath
    
    - returns: the cell
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.getCell(indexPath, ofClass: MyFunFactorTableViewCell.self)
        let item = items[indexPath.row]
        cell.configure(item)
        return cell
    }
}

/**
* Cell for a list in My Fun Factor screen
*
* @author Alexander Volkov
* @version 1.0
*/
class MyFunFactorTableViewCell: ZeroMarginsCell {
    
    /// outlets
    @IBOutlet weak var smileView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    /**
    Setup UI
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
    }
    
    /**
    Update UI with data
    
    - parameter funFactorItem: the fun factor item
    */
    func configure(funFactorItem: FunFactorItem) {
        
        // Smiley
        smileView.applyFunFactor(funFactorItem.funFactor)
        commentLabel.text = funFactorItem.comment.isEmpty ? "" : "\"\(funFactorItem.comment)\""
        dateLabel.text = funFactorItem.date.formatDate().uppercaseString
    }
}