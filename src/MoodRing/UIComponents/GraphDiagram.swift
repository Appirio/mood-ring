//
//  GraphDiagram.swift
//  UIComponents
//
//  Created by Alexander Volkov on 10.10.15.
//  Copyright (c) 2015 TopCoder. All rights reserved.
//

import UIKit

/// max percent increment used in animation
let DIAGRAM_ANIMATION_STEP: CGFloat = 0.10

/// timer interval used for animation
let DIAGRAM_ANIMATION_INTERVAL: NSTimeInterval = 0.010

/**
* Graph diagram (polyline)
*
* @author Alexander Volkov
* @version 1.0
*/
@IBDesignable
public class GraphDiagram: Diagram {
    
    /*
    Data set for the graph.
    Initially contains sample date to make the UI component visual.
    */
    public var data: [Float] = [40, 70, 0, 100, 45, 75, 35, 100, 45, 70, 10, 70, 30, 95] {
        didSet {
            self.updateMaxGraphValue()
            self.setNeedsLayout()
        }
    }
    
    /// Maximum value on the graph. Recalculated when the data is changed
    @IBInspectable var maxOy: Float = 0
    
    // Gradient
    @IBInspectable var plotColor: UIColor = UIColor(red: 30/255, green: 158/255, blue: 204/255, alpha: 1)
    
    /// the upper bound for the top most point of the graph from the total graph height
    @IBInspectable public var graphHeightPercent: CGFloat = 1 {
        didSet {
            if graphHeightPercent > 1 {
                graphHeightPercent = 1
            }
            self.setNeedsLayout()
        }
    }
    
    /**
    Get the height of the graph area (from 1th line to the last one)
    
    - returns: the height of the graph
    */
    override func getTotalGraphHeight() -> CGFloat {
        return super.getTotalGraphHeight() * graphHeightPercent
    }

    /**
    Add graph
    */
    override func layoutDiagram() {
        updateMaxGraphValue()
        let graphHeight = getTotalGraphHeight()
        
        // Gradient layer. The start/end colors can be modified in future to have a nice gradient over the polyline
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [plotColor.CGColor as AnyObject, plotColor.CGColor as AnyObject];
        gradient.startPoint = CGPointMake(0, 0)
        gradient.endPoint = CGPointMake(1, 0)
        
        // Graph shape
        let path = UIBezierPath()
        let dx = (self.bounds.width - graphSideMargin * 2) / (CGFloat(data.count) - 0.5)
        let firstValue = data.count > 0 ? data[0] : 0
        let y0 = self.bounds.height - graphHeight * CGFloat(firstValue) / CGFloat(maxOy) - graphBottomMargin
        path.moveToPoint(CGPointMake(graphSideMargin, y0))
        if data.count > 2 {
            for i in 1..<data.count {
                let x = dx * (CGFloat(i) + 0.5) + graphSideMargin
                let y = self.bounds.height - graphHeight * CGFloat(data[i]) / CGFloat(maxOy) - graphBottomMargin
                path.addLineToPoint(CGPointMake(x, y))
            }
        }
        let line = CAShapeLayer()
        line.path = path.CGPath
        line.lineWidth = lineWidth
        line.strokeColor = UIColor.greenColor().CGColor
        line.fillColor = UIColor.clearColor().CGColor
        
        // Add shape to the gradient rectangle
        gradient.mask = line
        layer.addSublayer(gradient)
        addedSublayers.append(gradient)
    }
    
    /**
    Updates maximum grapg value
    */
    public func updateMaxGraphValue() {
        var max: Float = 0
        for item in data {
            if item > max {
                max = item
            }
        }
        self.maxOy = max
    }
    
    // MARK: Animation
    
    /**
    Reset animated values.
    */
    override func resetAnimatedValues() {
        self.graphHeightPercent = 0
    }
    
    /**
    Increment animated values with given value.
    
    - parameter currentAnimationStep: the value to add
    */
    override func incrementAnimatedValues(currentAnimationStep: CGFloat) {
        self.graphHeightPercent += currentAnimationStep
    }
    
    /**
    Check if need to stop animation.
    
    - returns: true - if need to stop, false - else
    */
    override func isAnimationFinished() -> Bool {
        return self.graphHeightPercent >= 1
    }
    
}
