//
//  Diagram.swift
//  MoodRing
//
//  Created by Alexander Volkov on 11.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import Foundation

/**
* Abstract class with shared methods for all diagram classes
*
* @author Alexander Volkov
* @version 1.0
*/
public class Diagram: UIView {
    
    /// percent increment used in animation
    var currentAnimationStep: CGFloat = 0.1
    
    /// the width of the lines
    @IBInspectable public var lineWidth: CGFloat = 2
    
    /// bottom margin
    public var graphBottomMargin: CGFloat = 12
    
    /// left and right side margins
    public var graphSideMargin: CGFloat = 0
    
    /// the added layers
    var addedSublayers = [CALayer]()
    
    /// timer used for animation of the diagram
    internal var animationTimer: NSTimer?
    
    /**
    Add bars when layout subviews
    */
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // remove subviews
        for view in self.subviews {
            view.removeFromSuperview()
        }
        // remove all layers
        for layer in addedSublayers {
            layer.removeFromSuperlayer()
        }
        addedSublayers.removeAll(keepCapacity: true)
        
        // Add new graph
        layoutDiagram()
    }
    
    /**
    Get the height of the graph area
    
    - returns: the height of the graph
    */
    func getTotalGraphHeight() -> CGFloat {
        return self.bounds.height - lineWidth - graphBottomMargin
    }
    
    /**
    Method to override
    */
    func layoutDiagram() {
    }
    
    /**
    Adds line as subview
    
    - parameter p1:    start point
    - parameter p2:    end point
    - parameter color: the line color
    
    - returns: the line
    */
    func createLine(p1: CGPoint, _ p2: CGPoint, color: UIColor) -> CAShapeLayer {
        let path = UIBezierPath()
        path.moveToPoint(p1)
        path.addLineToPoint(p2)
        
        let line = CAShapeLayer()
        line.path = path.CGPath
        line.strokeColor = color.CGColor
        line.lineWidth = lineWidth
        line.fillColor = UIColor.clearColor().CGColor
        return line
    }
    
    /**
    Create rectangle
    
    - parameter p1:          the rectangle origin point
    - parameter size:        the size of the rectangel
    - parameter fillColor:   the color
    - parameter strokeColor: the border color
    
    - returns: layer
    */
    func createRect(p1: CGPoint, _ size: CGSize, fillColor: UIColor,
        strokeColor: UIColor = UIColor.clearColor()) -> CAShapeLayer {
        let path = UIBezierPath()
        path.moveToPoint(p1)
        path.addLineToPoint(CGPointMake(p1.x + size.width, p1.y))
        path.addLineToPoint(CGPointMake(p1.x + size.width, p1.y + size.height))
        path.addLineToPoint(CGPointMake(p1.x, p1.y + size.height))
        path.addLineToPoint(p1)
        
        let rect = CAShapeLayer()
        rect.path = path.CGPath
        rect.strokeColor = strokeColor.CGColor
        rect.lineWidth = lineWidth
        rect.fillColor = fillColor.CGColor
        return rect

    }
    
    // MARK: Animation
    
    /**
    Animate graph from horizontal line
    */
    public func animateFromLine() {
        stopAnimation()
        self.animationTimer = NSTimer.scheduledTimerWithTimeInterval(DIAGRAM_ANIMATION_INTERVAL,
            target: self, selector: Selector("animateDiagram"), userInfo: nil, repeats: true)
    }
    
    /**
    Stop animation
    */
    public func stopAnimation() {
        animationTimer?.invalidate()
        currentAnimationStep = DIAGRAM_ANIMATION_STEP
        resetAnimatedValues()
    }
    
    /**
    Method to override. Reset animated values.
    */
    func resetAnimatedValues() {
    }
    
    /**
    Method to override. Increment animated values with given value.
    
    - parameter currentAnimationStep: the value to add
    */
    func incrementAnimatedValues(currentAnimationStep: CGFloat) {
    }
    
    /**
    Method to override. Check if need to stop animation.
    
    - returns: true - if need to stop, false - else
    */
    func isAnimationFinished() -> Bool {
        return true
    }
    
    /**
    Animate sectors in the diagram.
    This method is invoked periodically to increment the percent of total space for all sectors
    */
    func animateDiagram() {
        incrementAnimatedValues(currentAnimationStep)
        
        // Custom Easy Out effect
        currentAnimationStep *= 0.9
        currentAnimationStep = max(currentAnimationStep, 0.002)
        if isAnimationFinished() {
            animationTimer?.invalidate()
            animationTimer = nil
        }
    }
}