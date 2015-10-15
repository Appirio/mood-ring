//
//  UserDetailsViewController.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 10.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit
import UIComponents

/**
* User details for Member Details and other screens
*
* @author TCASSEMBLER
* @version 1.0
*/
class UserDetailsViewController: UIViewController {

    /// outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var smileView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var thisProjectRatingView: UIView!
    @IBOutlet weak var thisProjectRating: UILabel!
    @IBOutlet weak var thisProjectLabel: UILabel!
    @IBOutlet weak var allProjectsView: UIView!
    @IBOutlet weak var allProjectRating: UILabel!
    @IBOutlet weak var allProjectsLabel: UILabel!
    @IBOutlet weak var barDiagramView: BarDiagram!
    @IBOutlet weak var detailsLeftMargin: NSLayoutConstraint!
    @IBOutlet weak var graphView: GraphDiagram!
    
    /// the user to show
    var user: User!
    
    /// the current project rating
    var avgRatingOnThisProject: Float = 0
    
    /// the average rating for all projects
    var avgRatingOnAllProjects: Float = 0
    
    /// the alternative title for "this project"
    var avgRatingOnThisProjectLabelText: String?
    
    /// flag: true - will show a rating for this project
    var showThisProjectView = true
    
    /// flag: true - will show bar diagram, false - else
    var showBarDiagram = true
    
    /// flag: true - will show smiley icon, false - else
    var showSmiley = true
    
    /**
    Setup UI
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        iconView.makeRound()
        barDiagramView.hidden = !showBarDiagram
        smileView.hidden = !showSmiley
        if let title = avgRatingOnThisProjectLabelText {
            self.thisProjectLabel.text = title
        }
        if !showThisProjectView {
            thisProjectLabel.text = avgRatingOnThisProjectLabelText ?? allProjectsLabel.text
            detailsLeftMargin.constant = 4.5 // margin like in design
        }
        allProjectsView.hidden = !showThisProjectView
        
        self.graphView.graphHeightPercent = 0
        
        // Bar diagram
        barDiagramView.graphBottomMargin = 0
        
        updateUI(user)
    }
    
    /**
    Animate the graph when appear
    
    - parameter animated: the animation flag
    */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        delay(0.3) { () -> () in
            self.graphView.animateFromLine()
            self.barDiagramView.animateBarDiagram()
        }
    }
    
    /**
    Turn off animation if the view will disappear
    
    - parameter animated: the animation flag
    */
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.graphView.stopAnimation()
        self.barDiagramView.stopAnimation()
    }
    
    /**
    Update UI with data
    
    - parameter data: the user's data
    */
    func updateUI(data: User) {
        iconView.image = nil
        UIImage.loadAsync(data.iconUrl) { (image) -> () in
            self.iconView.image = image
        }
        
        smileView.applyFunFactor(data.funFactor, addWhiteBorder: 2)
        titleLabel.text = data.fullName.uppercaseString
        
        thisProjectRating.text = avgRatingOnThisProject.formatFullRating()
        allProjectRating.text = avgRatingOnAllProjects.formatFullRating()
        
        // Copy statistic from right to left
        if !showThisProjectView {
            thisProjectRating.text = allProjectRating.text
        }
        
        // Update bar diagram
        barDiagramView.data = Int.generateRandomSampleValuesForBarDiagram()
        barDiagramView.colors = UIColor.funFactorColors()
    }
    
}
