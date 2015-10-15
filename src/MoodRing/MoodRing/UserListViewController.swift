//
//  UserListViewController.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 10.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/**
* User list for Member Details and other screens
*
* @author TCASSEMBLER
* @version 1.0
*/
class UserListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /// outlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    /// the users and comments to show
    var items = [(User, String)]()
    
    /// UI option: true - show the header on top ("Rate By"), false - else
    var showHeader = true
    
    /// UI option: true - show smiley, false - else
    var showSmiley = false
    
    /// UI option: true - show user rating, false - else
    var showRating = true
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorInsetAndMarginsToZero()
        tableView.separatorColor = UIColor.separatorColor()
            
        // Show/hide header
        if !showHeader {
            headerViewHeight.constant = 2.5 // keep gray line
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
        let cell = tableView.getCell(indexPath, ofClass: UserListTableViewCell.self)
        let item = items[indexPath.row]
        cell.configure(item.0, comment: item.1, showSmile: showSmiley, showRating: showRating)
        return cell
    }
}

/**
* Cell for the user list
*
* @author TCASSEMBLER
* @version 1.0
*/
class UserListTableViewCell: ZeroMarginsCell {
    
    /// outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var smileView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    /**
    Setup UI
    */
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .None
        self.contentView.addBottomBorder(height: 2, color: UIColor.separatorColor())
    }
    
    /**
    Update UI with data
    
    - parameter data:       the project data
    - parameter comment:    the comment to show
    - parameter showSmile:  true - show smile icon, false - else
    - parameter showRating: true - show rating, false - else
    */
    func configure(data: User, comment: String, showSmile: Bool, showRating: Bool) {
        iconView.image = nil
        iconView.makeRound()
        UIImage.loadAsync(data.iconUrl) { (image) -> () in
            self.iconView.image = image
        }
        
        // Smiley
        smileView.hidden = !showSmile
        if showSmile {
            smileView.applyFunFactor(data.funFactor, addWhiteBorder: 2)
        }
        
        titleLabel.text = data.fullName
        commentLabel.text = "\"\(comment)\""
        
        ratingLabel.hidden = !showRating
        if showRating {
            ratingLabel.text = data.rating.formatRating()
        }
    }
}