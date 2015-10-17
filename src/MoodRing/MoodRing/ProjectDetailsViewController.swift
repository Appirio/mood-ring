//
//  ProjectDetailsViewController.swift
//  MoodRing
//
//  Created by Alexander Volkov on 09.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit
import UIComponents

/// the sample comment for a fun factor in projects
let SAMPLE_FUN_FACTOR_COMMENT = "Everything goes as we planned"

/**
* Project Details screen
*
* @author Alexander Volkov
* @version 1.0
*/
class ProjectDetailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    /// outlets
    @IBOutlet weak var iconBg: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var projectRating: UILabel!
    @IBOutlet weak var otherRatingView: UIView!
    @IBOutlet weak var otherRatingTitleLabel: UILabel!
    @IBOutlet weak var otherRating: UILabel!
    @IBOutlet weak var funIcon: UIImageView!
    @IBOutlet weak var funIconViewWidth: NSLayoutConstraint!
    @IBOutlet weak var todayStat: UIView!
    @IBOutlet weak var todayStatHeight: NSLayoutConstraint!
    @IBOutlet var smiles: [UIImageView]!
    @IBOutlet var funFactorStatistic: [UILabel]!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var graphView: GraphDiagram!
    
    /// the project
    var project: Project!
    
    // flag: true - show UI for manager role, false - for a common user
    var isManager = AuthenticationUtil.sharedInstance.isManager
    
    /// the user's to show
    private var users: [User] = [
        User(id: "1", "Jackblack Longnamous", rating: 3.86, funFactor: 4, iconUrl: "ava0"),
        User(id: "2", "Jane Snow", rating: 4.25, funFactor: 3, iconUrl: "ava1"),
        User(id: "3", "John Scott", rating: 4.25, funFactor: 4, iconUrl: "ava2"),
        User(id: "4", "Greg Water", rating: 4.25, funFactor: 2, iconUrl: "ava3"),
        User(id: "5", "Tom Jones", rating: 4, funFactor: 3, iconUrl: "ava4"),
        User(id: "6", "John Doe", rating: 2.3, funFactor: 1, iconUrl: "ava5")
    ]
    
    /// the map of the rated users: (userId)->(flag "isRated")
    private var ratedUsers = [String: Bool]()

    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        addBackButton()
        if !isManager {
            addRightButton(iconName: "iconHistory", selector: "openHistory")
        }
        todayStat.addBottomBorder(height: 3, color: UIColor.separatorColor())
        
        // Collection view
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = UICollectionViewScrollDirection.Vertical
        flowLayout.itemSize = CGSizeMake(100.0, 100.0) // the size will be redefined in UICollectionViewDelegate
        
        // Space between cells and between all cell and view bounds
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 1
        flowLayout.sectionInset = UIEdgeInsetsZero
        
        self.collectionView.collectionViewLayout = flowLayout
        
        iconBg.makeRound()

        // reset statistic
        for stat in funFactorStatistic {
            stat.text = "0"
        }
        graphView.graphHeightPercent = 0
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
    Animate the graph when appear
    
    - parameter animated: the animation flag
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        delay(0.3) { () -> () in
            self.graphView.animateFromLine()
        }
    }
    
    /**
    Turn off animation if the view will disappear
    
    - parameter animated: the animation flag
    */
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.graphView.stopAnimation()
    }

    /**
    Update UI with data
    */
    func updateUI(data: Project) {
        self.graphView.stopAnimation()
        
        titleLabel.text = data.title
        funIcon.hidden = !isManager
        funIconViewWidth.constant = isManager ? 100 : 39 // compliance to the design
        
        // project icon
        iconView.image = UIImage(named: "defaultProjectIcon")
        iconBg.backgroundColor = data.tintColor
        UIImage.loadAsync(data.iconURL) { (image) -> () in
            self.iconView.image = image
        }
        
        projectRating.text = data.rating.formatRating()
        otherRating.text = data.avgRating.formatRating()
        otherRatingTitleLabel.text = isManager ? "AVG_RATING".localized() : "MY_AVG".localized()
        
        if !funIcon.hidden {
            funIcon.applyFunFactor(data.funFactor, addWhiteBorder: 2)
        }
        
        // Today stat
        todayStatHeight.constant = isManager ? 77 : 3
        
        // Update fun factor statistic
        var funFactorStat = [Int:Int]()
        for user in users {
            funFactorStat[user.funFactor] = (funFactorStat[user.funFactor] ?? 0) + 1
        }
        for stat in funFactorStatistic {
            let value = funFactorStat[stat.tag] ?? 0
            stat.text = "\(value)"
        }
        
        for smile in smiles {
            smile.applyFunFactor(smile.tag, addWhiteBorder: 2)
        }
    }
    
    /**
    Open History screen
    */
    func openHistory() {
        if let vc = create(HistoryViewController.self) {
            vc.project = self.project
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    /**
    "Show statistic" button action handler
    
    - parameter sender: the button
    */
    @IBAction func showOverallStatisticAction(sender: AnyObject) {
        if let vc = create(MemberSatisfactionViewController.self) {
            vc.project = self.project
            vc.overAllProjectFunFactor = self.project.funFactor // for this prototype we will use the same fun factor
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: UICollectionViewDataSource, UICollectionViewDelegate
    
    /**
    Get number of cells
    
    - parameter collectionView: the collectionView
    - parameter section:        the section index
    
    - returns: the number of users
    */
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }
    
    /**
    Get cell
    
    - parameter collectionView:       the collectionView
    - parameter indexPath:            the indexPath
    
    - returns: the cell
    */
    func collectionView(collectionView: UICollectionView,
        cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("ProjectDetailsCollectionViewCell",
            forIndexPath: indexPath) as! ProjectDetailsCollectionViewCell
        let user = users[indexPath.row]
        cell.configure(user, isManager: isManager, isRated: ratedUsers[user.id] ?? false)
        cell.parent = self
        cell.indexPath = indexPath
        cell.user = user
        return cell
    }
    
    /**
    Get cell size. Calculates depending on isManager flag and screen orientation.
    
    - parameter collectionView:       the collectionView
    - parameter collectionViewLayout: the layout
    - parameter indexPath:            the indexPath
    
    - returns: the size
    */
    func collectionView(collectionView:UICollectionView, layout collectionViewLayout:UICollectionViewLayout,
        sizeForItemAtIndexPath  indexPath:NSIndexPath) -> CGSize {
        let screenWidth = UIScreen.mainScreen().bounds.width
        let n: CGFloat = isPortraitOrientation() ? 2 : 3
        let gapWidth: CGFloat = 1
        let width: CGFloat = (screenWidth - gapWidth * (n - 1)) / n
        let height: CGFloat = isManager ? 150 : 195
        return CGSizeMake(width, height)
    }
    
    /**
    Show Member Details screen when cell tapped
    
    - parameter collectionView:       the collectionView
    - parameter indexPath:            the indexPath
    */
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let user = users[indexPath.row]
        if let vc = create(MemberDetailsViewController.self) {
            vc.userData = user
            vc.avgRatingOnThisProject = user.rating // this is a rating of the user for current project
            self.navigationController?.pushViewController(vc, animated: true)
        }
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    /**
    Mark user as reated at given indexPath.
    Will be modified in future to save the rating into a data source
    
    - parameter rating:    the rating set by current user
    - parameter comment:   the comment
    - parameter indexPath: the indexPath
    */
    func setUserRated(rating: Float, comment: String, atIndexPath indexPath: NSIndexPath) {
        let user = users[indexPath.row]
        ratedUsers[user.id] = true
        collectionView.reloadItemsAtIndexPaths([indexPath])
    }
}

/**
* Cell for a user on Project Details screen
*
* @author Alexander Volkov
* @version 1.0
*/
class ProjectDetailsCollectionViewCell: UICollectionViewCell {
    
    /// outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var smileView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var rateButton: UIButton!
    @IBOutlet weak var funFactorBgView: UIView!
    
    /// the reference to parent view controller
    var parent: ProjectDetailsViewController!
    
    /// the indexPath
    var indexPath: NSIndexPath!
    
    /// the related user
    var user: User!
    
    /**
    Update UI with data
    
    - parameter data:      the user's data
    - parameter isManager: true - need to hide "Rate" button, false - else
    - parameter isRated:   true - disable "Rate" button, false - else
    */
    func configure(data: User, isManager: Bool, isRated: Bool) {
        iconView.image = nil
        iconView.makeRound()
        UIImage.loadAsync(data.iconUrl) { (image) -> () in
            self.iconView.image = image
        }
        
        smileView.applyFunFactor(data.funFactor)
        funFactorBgView.makeRound()
        titleLabel.text = data.fullName
        ratingLabel.text = data.rating.formatRating()
        rateButton.hidden = isManager
        rateButton.enabled = !isRated
    }
    
    /**
    "Rate" button action handler
    
    - parameter sender: the button
    */
    @IBAction func rateButtonAction(sender: AnyObject) {
        if let vc = parent.create(RateUserViewController.self) {
            vc.user = user
            vc.delegate = { (index, comment) -> () in
                let rateValue = Float(index + 1)
                self.parent.setUserRated(rateValue, comment: comment, atIndexPath: self.indexPath)
            }
            parent.presentViewController(vc.wrapInNavigationController(), animated: true, completion: nil)
        }
    }
    
    /**
    "Fun Factor" button action handler
    
    - parameter sender: the button
    */
    @IBAction func funFactorDetailsAction(sender: AnyObject) {
        if let vc = parent.create(FunFactorDetailsViewController.self) {
            vc.user = user
            vc.comment = SAMPLE_FUN_FACTOR_COMMENT
            if let root = parent.rootController {
                root.showViewControllerFromSide(vc, inContainer: root.view, bounds: root.view.bounds, side: .BOTTOM)
            }
        }
    }
}
