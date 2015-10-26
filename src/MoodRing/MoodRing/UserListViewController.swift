//
//  UserListViewController.swift
//  MoodRing
//
//  Created by Alexander Volkov on 10.10.15.
//  Modified by TCASSEMBLER in 20.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit

/// type alias for item in UserListViewController
typealias UserListItem = (user: User, funFactorItem: FunFactorItem, rating: Float, comment: String)

/**
* User list for Member Details and other screens
*
* @author Alexander Volkov, TCASSEMBLER
* @version 1.1
*
* changes:
* 1.1:
* - UserListItem typealias support
* - noDataLabel added
*/
class UserListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    /// outlets
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    /// the users, comments and other data to show
    var items = [UserListItem]()
    
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
        
        noDataLabel.hidden = !items.isEmpty
        noDataLabel.text = "NO_DATA".localized()
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
        cell.configure(item, showSmile: showSmiley, showRating: showRating)
        return cell
    }
    
    // MARK: Helpful methods
    
    /**
    Convert a list of Rating objects to list of UserListItem
    
    - parameter ratingHistory: the rating history list
    
    - returns: the list ready to be shown in UserListViewController
    */
    class func convertToUserListItems(ratingHistory: [Rating]) -> [UserListItem] {
        var items = [UserListItem]()
        let defaultFunFactor = FunFactorItem.getDefaultFunFactor()
        for item in ratingHistory {
            items.append((user: item.ratedBy!,
                funFactorItem: defaultFunFactor, // will not be shown
                rating: item.rating,
                comment: item.comment))
        }
        return items
    }
}

/**
* Cell for the user list
*
* @author Alexander Volkov
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
    
    - parameter data:       the data to show
    - parameter showSmile:  true - show smile icon, false - else
    - parameter showRating: true - show rating, false - else
    */
    func configure(data: UserListItem, showSmile: Bool, showRating: Bool) {
        iconView.image = UIImage(named: "noProfileIcon")
        iconView.makeRound()
        UIImage.loadAsync(data.user.iconUrl) { (image) -> () in
            self.iconView.image = image
        }
        
        // Smiley
        smileView.hidden = !showSmile
        if showSmile {
            smileView.applyFunFactor(data.funFactorItem.funFactor, addWhiteBorder: 2)
        }
        
        titleLabel.text = data.user.fullName
        commentLabel.text = data.comment.isEmpty ? "" : "\"\(data.comment)\""
        
        ratingLabel.hidden = !showRating
        if showRating {
            ratingLabel.text = data.rating.formatRating()
        }
    }
}