//
//  BarDiagram.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 11.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import Foundation

/**
* Graph diagram (polyline)
*
* @author TCASSEMBLER
* @version 1.0
*/
@IBDesignable
public class BarDiagram: Diagram {
    
    /// the animation duration time
    let ANIMATION_DURATION: NSTimeInterval = 2
    
    /*
    Data set for the graph.
    Initially contains sample date to make the UI component visual.
    */
    public var data: [Int] = [5, 3, 2, 4, 5, 0, 3, 3, 4, 4] {
        didSet {
            self.updateMaxGraphValue()
            self.setNeedsLayout()
        }
    }
    
    /// the colors for bars
    public var colors: [UIColor] = [UIColor.redColor(),
        UIColor.orangeColor(),
        UIColor.blueColor(),
        UIColor.greenColor(),
        UIColor.yellowColor()
        ] {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// the default bar color
    public var defaultLineColor = UIColor(red: 129/255, green: 189/255, blue: 38/255, alpha: 1)
    
    /// Maximum value on the graph. Recalculated when the data is changed
    @IBInspectable var maxOy: Int = 0
    
    /**
    Updates maximum grapg value
    */
    public func updateMaxGraphValue() {
        var max = 0
        for item in data {
            if item > max {
                max = item
            }
        }
        self.maxOy = max
    }
    
    
    /**
    Get the height of the graph area
    
    - returns: the height of the graph
    */
    override func getTotalGraphHeight() -> CGFloat {
        return self.bounds.height - graphBottomMargin
    }
    
    /**
    Add graph
    */
    override func layoutDiagram() {
        updateMaxGraphValue()
        let graphHeight = getTotalGraphHeight()
        let graphWidth = self.bounds.width - graphSideMargin * 2
        let x0 = graphSideMargin
        let y0 = graphBottomMargin
        let spaceBetweenBars: CGFloat = 1
        
        let n = data.count
        if n > 0 {
            let delta = graphWidth / CGFloat(n)
            let barWidth = delta - spaceBetweenBars
            self.lineWidth = barWidth
            let xShift = delta / 2
            
            for i in 0..<n {
                let x = x0 + xShift + CGFloat(i) * delta
                let y1 = y0
                let y2 = y0 + graphHeight
                let line = createLine(CGPoint(x: x, y: y1), CGPoint(x: x, y: y2), color: defaultLineColor)
                line.strokeStart = 0.5
                line.strokeColor = defaultLineColor.CGColor
                line.anchorPoint = CGPoint(x: 0, y: 0)
                if data[i] > 0 {
                    layer.addSublayer(line)
                }
                addedSublayers.append(line)
            }
        }
    }
    
    /**
    Animate bar
    */
    public func animateBarDiagram() {
        let n = data.count
        if n > 0 {
            CATransaction.begin()
            CATransaction.setCompletionBlock({ () -> Void in
                
            })
            for i in 0..<min(n, self.addedSublayers.count) {
                if let line = self.addedSublayers[i] as? CAShapeLayer {
                    let index = max(0, self.data[i] - 1) // [1...5] -> [0...4]
                    let targetColor = self.colors[index % self.colors.count]
                    let targetLengthPercent: CGFloat = 1 - (CGFloat(self.data[i])) / 5
                    line.removeAllAnimations()
                    line.strokeStart = targetLengthPercent
                    line.strokeColor = targetColor.CGColor
                }
            }
            CATransaction.commit()
        }
    }
    
    /**
    Reset bars
    */
    override func resetAnimatedValues() {
        let n = data.count
        if n > 0 {
            for i in 0..<min(n, addedSublayers.count) {
                if let line = addedSublayers[i] as? CAShapeLayer {
                    line.strokeStart = 0.5
                    line.strokeColor = defaultLineColor.CGColor
                    line.removeAllAnimations()
                }
            }
        }
    }
}