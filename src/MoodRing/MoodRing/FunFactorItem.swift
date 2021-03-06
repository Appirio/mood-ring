//
//  FunFactorItem.swift
//  MoodRing
//
//  Created by Alexander Volkov on 10.10.15.
//  Modified by TCASSEMBLER in 20.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import Foundation

/**
* Model class for rows in "My Fun Factor" screen
*
* @author Alexander Volkov, TCASSEMBLER
* @version 1.1
*
* changes:
* 1.1:
* - default FunFactorItem method
*/
class FunFactorItem {
 
    /// the fun factor
    let funFactor: Int
    
    ///  the related comment
    let comment: String
    
    /// the date of the fun factor change
    let date: NSDate
    
    /**
    Instantiate new FunFactorItem
    
    - parameter funFactor: the fun factor index
    - parameter comment:   the comment
    - parameter date:      the date of the fun factor change
    
    - returns: the instance
    */
    init(funFactor: Int, comment: String, date: NSDate = NSDate()) {
        self.funFactor = funFactor
        self.comment = comment
        self.date = date
    }
    
    /**
    Get default fun factor item if nothing is specified
    
    - returns: the default fun factor
    */
    class func getDefaultFunFactor() -> FunFactorItem {
        return FunFactorItem(funFactor: 2, comment: "", date: NSDate())
    }
}