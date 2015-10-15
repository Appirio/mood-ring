//
//  MyFunFactorViewController.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 10.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit
import UIComponents

/// the sample comment for current fun factor state
let SAMPLE_CURRENT_COMMENT = "All projects went well"

/// the sample fun factor items to show onMy Fun Factor screen
let SAMPLE_FUN_FACTOR_ITEMS = [
    FunFactorItem(funFactor: 4, comment: SAMPLE_CURRENT_COMMENT, date: NSDate()), // Today
    FunFactorItem(funFactor: 3, comment: "Feedback goes here", date: NSDate().addDays(-1)), // Yesterday
    FunFactorItem(funFactor: 1, comment: "Feedback goes here", date: NSDate.parseDate("2014-08-21") ?? NSDate()),
    FunFactorItem(funFactor: 2, comment: "Feedback goes here", date: NSDate.parseDate("2014-08-20") ?? NSDate()),
    FunFactorItem(funFactor: 4, comment: "Feedback goes here", date: NSDate.parseDate("2014-08-20") ?? NSDate())
]


/**
* My Fun Factor screen
*
* @author TCASSEMBLER
* @version 1.0
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
    
    /// the items to show
    var items = [FunFactorItem]()
    
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
        // Emulate loading
        let loadingIndicator = LoadingView(self.listView, dimming: true)
        loadingIndicator.show()
        delay(LOADING_EMULATION_DURATION) { () -> () in
            
            self.items = SAMPLE_FUN_FACTOR_ITEMS
            self.tableView.reloadData()
            loadingIndicator.terminate()
        }
        updateUI(AuthenticationUtil.sharedInstance.currentUser)
    }
    
    /**
    Update UI with data
    
    - parameter data: the user's data
    */
    func updateUI(data: User) {
        
        // Top area
        iconView.image = nil
        UIImage.loadAsync(data.iconUrl) { (image) -> () in
            self.iconView.image = image
        }
        
        smileView.applyFunFactor(AuthenticationUtil.sharedInstance.currentUser.funFactor,
            addWhiteBorder: 2, addShadow: 2)
        topView.backgroundColor = UIColor.funFactorColor(AuthenticationUtil.sharedInstance.currentUser.funFactor)
        titleLabel.text = "\"\(SAMPLE_CURRENT_COMMENT)\""
        
        // Update bar diagram
        barDiagramView.data = Int.generateRandomSampleValuesForBarDiagram()
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
* @author TCASSEMBLER
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
        commentLabel.text = "\"\(funFactorItem.comment)\""
        dateLabel.text = funFactorItem.date.formatDate().uppercaseString
    }
}