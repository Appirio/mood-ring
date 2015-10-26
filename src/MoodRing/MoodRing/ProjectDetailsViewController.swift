//
//  ProjectDetailsViewController.swift
//  MoodRing
//
//  Created by Alexander Volkov on 09.10.15.
//  Modified by TCASSEMBLER in 20.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit
import UIComponents

/// option: true - will enable "Rate" button even if the user already added rating for this person today, false - else
let OPTION_ENABLE_MULTIPLE_RATINGS_FROM_ONE_PERSON = false

/**
* Project Details screen
*
* @author Alexander Volkov, TCASSEMBLER
* @version 1.1
*
* changes:
* 1.1:
* - API integration
*/
class ProjectDetailsViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    /// outlets
    @IBOutlet weak var topView: UIView!
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
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var noGraphData: UILabel!
    
    /// the project
    var project: Project!
    
    /// the current user average rating for this project
    var myAverageRating: Float?
    
    // flag: true - show UI for manager role, false - for a common user
    var isManager = AuthenticationUtil.sharedInstance.isManager
    
    /// the user's to show
    private var projectUsers: [ProjectUser] = []

    /// the API
    private var api = MoodRingApi.sharedInstance
    
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
        loadData()
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
    Load data from the server and update UI
    */
    func loadData() {
        loadRatingHistoryAndUpdateUI()
        
        // Reset screen
        projectUsers = []
        collectionView.reloadData()
        for stat in funFactorStatistic {
            stat.text = "0"
        }
        noDataLabel.hidden = true
        
        // Load data
        let loadingIndicator = LoadingView(self.collectionView, dimming: true)
        loadingIndicator.show()
        
        api.getProjectUsersWithCurrentFunFactors(self.project,
            addRatingDateByUser: !isManager ? AuthenticationUtil.sharedInstance.currentUser : nil,
            callback: { (projectUsers) -> () in
                self.projectUsers = projectUsers
                self.collectionView.reloadData()
                if projectUsers.isEmpty {
                    self.noDataLabel.hidden = false
                    self.noDataLabel.text = "NO_PROJECT_MEMBERS".localized()
                }
                if self.isManager {
                    self.updateFunFactorStatistic()
                }
                loadingIndicator.terminate()
        }, failure: createGeneralFailureCallback(loadingIndicator))
    }
    
    /**
    Load rating history and update plot graph
    */
    func loadRatingHistoryAndUpdateUI() {
        self.graphView.hidden = true
        
        let loadingIndicator = LoadingView(self.topView, dimming: false)
        loadingIndicator.show()
        api.getAvgRatingHistory(project, callback: { (ratings) -> () in
            if ratings.count >= MIN_PLOT_GRAPH_POINTS {
                self.graphView.hidden = false
                self.graphView.data = ratings.map({$0.rating})
            }
            if self.graphView.hidden {
                self.noGraphData.hidden = false
                self.noGraphData.text = self.noGraphData.text?.uppercaseString
            }
            loadingIndicator.terminate()
            }, failure: createGeneralFailureCallback(loadingIndicator))
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
        otherRating.text = (isManager ? data.avgRating : (myAverageRating ?? 0)).formatRating()
        otherRatingTitleLabel.text = isManager ? "AVG_RATING".localized() : "MY_AVG".localized()
        
        if !funIcon.hidden {
            funIcon.applyFunFactor(data.funFactor, addWhiteBorder: 2)
        }
        
        // Today stat
        todayStatHeight.constant = isManager ? 77 : 3
        
        if isManager {
            updateFunFactorStatistic()
        }
    }
    
    /**
    Update fun factor statistic
    */
    func updateFunFactorStatistic() {
        var funFactorStat = [Int:Int]()
        for projectUser in projectUsers {
            let index = projectUser.user.getFunFactor()
            funFactorStat[index] = (funFactorStat[index] ?? 0) + 1
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
        return projectUsers.count
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
        let projectUser = projectUsers[indexPath.row]
        cell.configure(projectUser, isManager: isManager, isRated: projectUser.isRatedByCurrentUser
            && !OPTION_ENABLE_MULTIPLE_RATINGS_FROM_ONE_PERSON )
        cell.parent = self
        cell.indexPath = indexPath
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
        let projectUser = projectUsers[indexPath.row]
        if let vc = create(MemberDetailsViewController.self) {
            vc.projectUser = projectUser
            self.navigationController?.pushViewController(vc, animated: true)
        }
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
    }
    
    /**
    Mark user as reated at given indexPath.
    
    - parameter rating:    the rating set by current user
    - parameter comment:   the comment
    - parameter indexPath: the indexPath
    */
    func setUserRated(rating: Float, comment: String, atIndexPath indexPath: NSIndexPath) {
        let projectUser = projectUsers[indexPath.row]
        projectUser.isRatedByCurrentUser = true
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
    
    /// the related project user
    var projectUser: ProjectUser!
    
    /**
    Update UI with data
    
    - parameter data:      the user's data
    - parameter isManager: true - need to hide "Rate" button, false - else
    - parameter isRated:   true - disable "Rate" button, false - else
    */
    func configure(data: ProjectUser, isManager: Bool, isRated: Bool) {
        self.projectUser = data
        iconView.image = UIImage(named: "noProfileIcon")
        iconView.makeRound()
        UIImage.loadAsync(data.user.iconUrl) { (image) -> () in
            self.iconView.image = image
        }
        
        smileView.applyFunFactor(data.user.getFunFactor())
        funFactorBgView.makeRound()
        titleLabel.text = data.user.fullName
        ratingLabel.text = data.avgProjectUserRating.formatRating()
        rateButton.hidden = isManager || data.user.id.hasPrefix(AuthenticationUtil.sharedInstance.currentUser.id)
        rateButton.enabled = !isRated
    }
    
    /**
    "Rate" button action handler
    
    - parameter sender: the button
    */
    @IBAction func rateButtonAction(sender: AnyObject) {
        if let vc = parent.create(RateUserViewController.self) {
            vc.projectUser = projectUser
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
            vc.user = projectUser.user
            if let root = parent.rootController {
                root.showViewControllerFromSide(vc, inContainer: root.view, bounds: root.view.bounds, side: .BOTTOM)
            }
        }
    }
}
