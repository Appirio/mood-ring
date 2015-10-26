//
//  HelpfulFunctions.swift
//  MoodRing
//
//  Created by Alexander Volkov on 08.10.15.
//  Modified by TCASSEMBLER in 20.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import UIKit
/**
A set of helpful functions and extensions
*/

/**
* Extends UIColor with color methods from design.
*
* @author Alexander Volkov, TCASSEMBLER
* @version 1.1
*
* changes:
* 1.1:
* - new method fromString()
*/
extension UIColor {
    
    /**
    Creates new color with RGBA values from 0-255 for RGB and a from 0-1
    
    - parameter r: the red color
    - parameter g: the green color
    - parameter b: the blue color
    - parameter a: the alpha color
    */
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: a)
    }
    
    /**
    Creates new color with RGBA values from 0-255 for RGB and a from 0-1
    
    - parameter g: the gray color
    - parameter a: the alpha color
    */
    convenience init(gray: CGFloat, a: CGFloat = 1) {
        self.init(r: gray, g: gray, b: gray, a: a)
    }
    
    /**
    Get UIColor from hex string, e.g. "FF0000" -> red color
    
    - parameter hexString: the hex string
    
    - returns: the UIColor instance or nil
    */
    class func fromString(hexString: String) -> UIColor? {
        if hexString.length == 6 {
            let redStr = hexString.substringToIndex(hexString.startIndex.advancedBy(2))
            let greenStr = hexString.substringWithRange(Range<String.Index>(
                start: hexString.startIndex.advancedBy(2),
                end: hexString.startIndex.advancedBy(4)))
            let blueStr = hexString.substringFromIndex(hexString.startIndex.advancedBy(4))
            return UIColor(r: CGFloat(redStr.intFromHex()),
                g: CGFloat(greenStr.intFromHex()),
                b: CGFloat(blueStr.intFromHex()))
        }
        return nil
    }

    /**
    orange color
    
    - returns: UIColor instance
    */
    class func orange() -> UIColor {
        return UIColor(r: 241, g: 145, b: 56)
    }
    
    /**
    raspberry color
    
    - returns: UIColor instance
    */
    class func raspberry() -> UIColor {
        return UIColor(r: 193, g: 43, b: 89)
    }
    
    /**
    dark color for project icons
    
    - returns: UIColor instance
    */
    class func dark() -> UIColor {
        return UIColor(r: 70, g: 86, b: 96)
    }
    
    /**
    dark blue color for project icons
    
    - returns: UIColor instance
    */
    class func darkBlue() -> UIColor {
        return UIColor(r: 106, g: 155, b: 199)
    }
    
    /**
    blue color for project icons
    
    - returns: UIColor instance
    */
    class func blue() -> UIColor {
        return UIColor(r: 30, g: 158, b: 204)
    }
    
    /**
    tableView separator color
    
    - returns: UIColor instance
    */
    class func separatorColor() -> UIColor {
        return UIColor(r: 234, g: 235, b: 236)
    }
    
    /**
    Fun Factor colors array
    
    - returns: the array of colors
    */
    class func funFactorColors() -> [UIColor] {
        struct Static {
            static var colors: [UIColor] = [
                UIColor(r: 226, g: 37, b: 56),
                UIColor(r: 250, g: 82, b: 31),
                UIColor(r: 67, g: 122, b: 187),
                UIColor(r: 129, g: 189, b: 38),
                UIColor(r: 89, g: 152, b: 26)
            ]
        }
        return Static.colors
    }
    
    /**
    Get fun factor color for given index
    
    - parameter index: the index of the fun factor
    
    - returns: the color
    */
    class func funFactorColor(index: Int) -> UIColor {
        let colors = UIColor.funFactorColors()
        return colors[index % colors.count] // for safety will apply %
    }
}


/**
* Extenstion adds helpful methods to String
*
* @author Alexander Volkov, TCASSEMBLER
* @version 1.1
*
* changes:
* 1.1:
* - new method intFromHex()
*/
extension String {
    
    /// Get length of the string
    var length: Int {
        return (self as NSString).length
    }
    
    /**
    Get string without spaces at the end and at the start.
    
    - returns: trimmed string
    */
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
    /**
    Checks if string contains given substring
    
    - parameter substring:     the search string
    - parameter caseSensitive: flag: true - search is case sensitive, false - else
    
    - returns: true - if the string contains given substring, false - else
    */
    func contains(substring: String, caseSensitive: Bool = true) -> Bool {
        if let _ = self.rangeOfString(substring,
            options: caseSensitive ? NSStringCompareOptions(rawValue: 0) : .CaseInsensitiveSearch) {
                return true
        }
        return false
    }
    
    /**
    Creates attributed string for address labels
    
    - parameter lineSpacing: the line spacing attribute value
    
    - returns: NSMutableAttributedString
    */
    func createAttributedAddressString(lineSpacing: CGFloat = 3.5,
        addCenterAlignment: Bool = false) -> NSMutableAttributedString {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = lineSpacing
            if addCenterAlignment {
                paragraphStyle.alignment = .Center
            }
            let attributedString = NSMutableAttributedString(string: self, attributes: [
                NSParagraphStyleAttributeName: paragraphStyle
                ])
            return attributedString
    }
    
    /**
    Shortcut method for stringByReplacingOccurrencesOfString
    
    - parameter target:     the string to replace
    - parameter withString: the string to add instead of target
    
    - returns: a result of the replacement
    */
    func replace(target: String, withString: String) -> String {
        return self.stringByReplacingOccurrencesOfString(target, withString: withString,
            options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
    
    /**
    Checks if the string is number
    
    - returns: true if the string presents number
    */
    func isNumber() -> Bool {
        let formatter = NSNumberFormatter()
        if let _ = formatter.numberFromString(self) {
            return true
        }
        return false
    }
    
    /**
    Checks if the string is positive number
    
    - returns: true if the string presents positive number
    */
    func isPositiveNumber() -> Bool {
        let formatter = NSNumberFormatter()
        if let number = formatter.numberFromString(self) {
            if number.doubleValue > 0 {
                return true
            }
        }
        return false
    }
    
    /**
    Get URL encoded string.
    
    - returns: URL encoded string
    */
    public func urlEncodedString() -> String {
        let set = NSCharacterSet.URLQueryAllowedCharacterSet().mutableCopy() as! NSMutableCharacterSet;
        set.removeCharactersInString(":?&=@+/'");
        return self.stringByAddingPercentEncodingWithAllowedCharacters(set as NSCharacterSet)!
    }
    
    /**
    Get a localized string
    
    - returns: the localized string.
    */
    func localized() -> String {
        return NSLocalizedString(self, comment: self)
    }
    
    /**
    Remove html tags
    
    - returns: plain text string
    */
    func getClearText() -> String {
        return self.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "",
            options: .RegularExpressionSearch, range: nil)
    }

    /**
    Get Int value from hex string, e.g. "FF" -> 255
    
    - returns: the int value
    */
    func intFromHex() -> Int {
        return Int(UInt8(strtoul(self, nil, 16)))
    }
}

/**
Shows an alert with the title and message.

- parameter title:   the title
- parameter message: the message
*/
func showAlert(title: String, message: String) {
    UIViewController.getCurrentViewController()?.showAlert(title, message)
}

/**
Show alert message about stub functionalify
*/
func showStub() {
    showAlert("Stub", message: "This feature will be implemented in future")
}

/**
Delays given callback invocation

- parameter time:     the delay in seconds
- parameter callback: the callback to invoke after 'delay' seconds
*/
func delay(delay: NSTimeInterval, _ callback: ()->()) {
    let delay = delay * Double(NSEC_PER_SEC)
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay));
    dispatch_after(popTime, dispatch_get_main_queue(), {
        callback()
    })
}

/**
Asynchronously invokes callback

- parameter callback: the callback to invoke
*/
func async(callback: ()->()) {
    delay(0) { () -> () in
        callback()
    }
}

/**
* Extenstion adds helpful methods to Float
*
* @author Alexander Volkov
* @version 1.0
*/
extension Float {
    
    /**
    Get uniform random value between 0 and maxValue
    
    - parameter maxValue: the limit of the random values
    
    - returns: random Float
    */
    static func random(maxValue: UInt32) -> Float {
        let floating: UInt32 = 100
        return Float(arc4random_uniform(maxValue * floating)) / Float(floating)
    }
    
    func isInteger() -> Bool {
        return  self == Float(Int(self))
    }
    
    /**
    Returns string to show as a currency.
    For dollar values, all stats that are less than $1 should be rounded to the nearest 10 cents.
    Examples: 1.23 -> "1", "0.53" -> "0.5", "0.98" -> "1.0", "4.0 -> "4"
    
    - returns: string
    */
    func currencyString() -> String {
        if self >= 1  || self == 0 {
            return NSString.localizedStringWithFormat("%.f", round(self)) as String
        }
        else {
            let value = round(self * 10) / 10
            return NSString.localizedStringWithFormat("%.1f", value) as String
        }
    }
    
    /**
    Format rating value, e.g. 3.0 -> "3", 3.40 -> "3.4", 3.531 -> "3.53"
    
    - returns: string
    */
    func formatRating() -> String {
        if isInteger() {
            return NSString.localizedStringWithFormat("%.f", round(self)) as String
        }
        else {
            let value = self * 10
            if value.isInteger() {
                return NSString.localizedStringWithFormat("%.1f", value / 10) as String
            }
            else {
                return NSString.localizedStringWithFormat("%.2f", self) as String
            }
        }
    }
    
    /**
    Format rating value, e.g. 3.0 -> "3.00", 3.40 -> "3.40", 3.531 -> "3.53"
    
    - returns: string
    */
    func formatFullRating() -> String {
        return NSString.localizedStringWithFormat("%.2f", self) as String
    }
}

/**
* Structure contains common date parsers
*
* @author TCASSEMBLER
* @version 1.0
*/
struct DateFormatters {
    
    /// Full date format
    static var fullDate: NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ" // if hours are [0-23]
        f.locale = NSLocale.currentLocale()
        return f
        }()
    static var fullDateStringLength = 28
    
    /// Human readable format
    static var humanReadable: NSDateFormatter = {
        let f = NSDateFormatter()
        f.dateFormat = "MMM dd,yyyy"
        return f
        }()
}

/**
* Helpfull methods
*
* @author Alexander Volkov, TCASSEMBLER
* @version 1.1
*
* changes:
* 1.1:
* - new methods beginningOfDay(), parseFullDate()
*/
extension NSDate {
   
    /**
    Get NSDate that corresponds to the start of current day.
    
    - returns: the date
    */
    func beginningOfDay() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.Day],
            fromDate:self)
        
        return calendar.dateFromComponents(components)!
    }
    
    /**
    Get NSDate that corresponds to the end of current day.
    
    - returns: the date
    */
    func endOfDay() -> NSDate {
        var date = nextDayStart()
        date = date.dateByAddingTimeInterval(-1)
        return date
    }
    
    /**
    Get the next day start
    
    - returns: the date
    */
    func nextDayStart() -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.day = 1
        
        let date = calendar.dateByAddingComponents(components, toDate: self.beginningOfDay(),
            options: NSCalendarOptions(rawValue: 0))!
        return date
    }
    
    /**
    Format date for UI
    
    - parameter dateFormetter: the date formatter
    - parameter uppercase:    true - will use uppercaseString, false - else
    
    - returns: human readable representation of the date
    */
    func formatDate(var dateFormetter: NSDateFormatter? = nil, uppercase: Bool = true) -> String {
        if dateFormetter == nil {
            dateFormetter = DateFormatters.humanReadable
        }
        if isToday() {
            return "TODAY".localized()
        }
        else if isYesterday() {
            return "YESTERDAY".localized()
        }
        else {
            let str = dateFormetter!.stringFromDate(self)
            return uppercase ? str.uppercaseString : str
        }
    }
    
    /**
    Check if this is today date
    
    - returns: true - if today, false - else
    */
    func isToday() -> Bool {
        return isSameDay(NSDate())
    }
    
    /**
    Check if this is yesterday date
    
    - returns: true - if yesterday, false - else
    */
    func isYesterday() -> Bool {
        return isSameDay(NSDate().addDays(-1))
    }
    
    /**
    Check if the date corresponds to the same day
    
    - parameter date: the date to check
    
    - returns: true - if the date has same year, month and day
    */
    func isSameDay(date: NSDate) -> Bool {
        let calendar = NSCalendar.currentCalendar()
        let comps1 = calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.Day], fromDate:self)
        let comps2 = calendar.components([NSCalendarUnit.Month, NSCalendarUnit.Year, NSCalendarUnit.Day], fromDate:date)
        
        return (comps1.day == comps2.day) && (comps1.month == comps2.month) && (comps1.year == comps2.year)
    }
    
    /**
    Add days to the date
    
    - parameter daysToAdd: the number of days to add
    
    - returns: changed date
    */
    func addDays(daysToAdd: Int) -> NSDate {
        let calendar = NSCalendar.currentCalendar()
        
        let components = NSDateComponents()
        components.day = daysToAdd
        
        let date = calendar.dateByAddingComponents(components, toDate: self, options: NSCalendarOptions())!
        return date
    }
    
    /**
    Parse date string, e.g. 2014-11-17
    
    - parameter string: the date string
    
    - returns: date object or nil
    */
    class func parseDate(var string: String) -> NSDate? {
        struct Static {
            static var dateParser: NSDateFormatter = {
                let f = NSDateFormatter()
                f.dateFormat = "yyyy-MM-dd"
                f.locale = NSLocale.currentLocale()
                return f
                }()
            static var dateStringLength = 10
        }
        
        string = string.substringToIndex(string.startIndex.advancedBy(Static.dateStringLength))
        return Static.dateParser.dateFromString(string)
    }
    
    /**
    Parse full date string, e.g. 2015-10-16T15:56:51.000+0000
    
    - parameter string: the date string
    
    - returns: date object or nil
    */
    class func parseFullDate(var string: String) -> NSDate? {
        string = string.substringToIndex(string.startIndex.advancedBy(DateFormatters.fullDateStringLength))
        return DateFormatters.fullDate.dateFromString(string)
    }
}

/**
Check if iPhone5 like device

- returns: true - if this device has width as on iPhone5, false - else
*/
func isIPhone5() -> Bool {
    return UIScreen.mainScreen().nativeBounds.width == 640
}

/**
Check if current orientation is Portrait like

- returns: true - if the orientation is Portrait like,
            false - if the orientation is Landscape like,
*/
func isPortraitOrientation() -> Bool {
    let orientation = UIApplication.sharedApplication().statusBarOrientation
    if (orientation == UIInterfaceOrientation.LandscapeRight
        || orientation == UIInterfaceOrientation.LandscapeLeft) {
            return false
    }
    else {
        return true
    }
}

/**
* Extenstion adds helpful methods to Int
*
* @author Alexander Volkov
* @version 1.0
*/
extension Int {
    
    /**
    Get uniform random value between 0 and maxValue
    
    - parameter maxValue: the limit of the random values
    
    - returns: random Int
    */
    static func random(maxValue: UInt32) -> Int {
        return Int(arc4random_uniform(maxValue))
    }
    
    /**
    Generate sample values for bar diagram
    
    - returns: the values
    */
    static func generateRandomSampleValuesForBarDiagram() -> [Int] {
        var values = [Int]()
        values.append(0) // gap at the start
        let days = 6    // number of days
        for _ in 0..<days {
            for _ in 0..<5 { // 5 working days per week
                values.append(Int.random(5) + 1)
            }
            values.append(0)
        }
        return values
    }
}

/**
* Helpful extenstion for arrays
*
* @author TCASSEMBLER
* @version 1.0
*/
extension Array {
    
    /**
    Convert array to hash array
    
    - parameter transform: the transformation of an object to a key
    
    - returns: a hashmap
    */
    func hasmapWithKey<K>(transform: (Element) -> (K)) -> [K:Element] {
        var hashmap = [K:Element]()
        
        for item in self {
            let key = transform(item)
            hashmap[key] = item
        }
        return hashmap
    }
}

/**
* Helpful extenstion for arrays
*
* @author TCASSEMBLER
* @version 1.0
*/
extension Array where Element : Hashable {
    
    /// List of unique values in the array
    var unique: [Element] {
        return Array(Set(self))
    }
}