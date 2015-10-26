//
//  RestDataSource.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 18.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import Foundation

/// type alias for a success callback
typealias SuccessCallback = (JSON)->()

/// type alias for failure callback
typealias FailureCallback = (String)->()

/// common errors
let ERROR_INCORRECT_RESPONSE = "Incorrect response from the server".localized()
let ERROR_UNKNOWN = "Unknown server error".localized()

/**
* Abstract class for implementing different data sources based on REST service requests
*
* @author TCASSEMBLER
* @version 1.0
*/
class RestDataSource: NSObject, SFRestDelegate {
    
    /// the last sent requests
    var requests = [SFRestRequest: (SuccessCallback, FailureCallback)]()
    
    /**
    Send request with given query
    
    - parameter query:    the request SOQL query
    - parameter callback: the callback to return data
    - parameter failure:  the callback to invoke when an error occurred
    */
    func sendQuery(query: String, callback: SuccessCallback, failure: FailureCallback) {
        let request = SFRestAPI.sharedInstance().requestForQuery(query)
        request.parseResponse = false
        
        // save request callbacks
        requests[request] = (callback, failure)
        
        // send request
        SFRestAPI.sharedInstance().send(request, delegate: self)
    }
    
    // MARK: - SFRestDelegate methods

    /**
    Success response handler
    
    - parameter request:      the related request
    - parameter dataResponse: the response
    */
    func request(request: SFRestRequest!, didLoadResponse dataResponse: AnyObject!) {
        var json: JSON?
        if let data = dataResponse as? NSData {
            json = JSON(data: data, options: NSJSONReadingOptions.AllowFragments, error: nil)
        }
        else if let dic = dataResponse as? NSDictionary {
            json = JSON(dic)
        }
        dispatch_async( dispatch_get_main_queue(), {
            
            // Get callbacks
            if let callbacks = self.requests[request] {
                self.requests.removeValueForKey(request)
                if let json = json {
                    if json["done"].boolValue || json["success"].boolValue {
                        callbacks.0(json)
                    }
                    else {
                        if let errors = json["errors"].array {
                            let errorMessages = errors.map({$0.description}).joinWithSeparator(". ")
                            callbacks.1(errorMessages)
                        }
                        else {
                            callbacks.1("\(ERROR_UNKNOWN): \(dataResponse?.description)")
                        }
                    }
                }
                else {
                    callbacks.1("\(ERROR_INCORRECT_RESPONSE): \(dataResponse?.description)")
                }
            }
        })
        
    }
    
    /**
    Failure handle
    
    - parameter request: the related request
    - parameter error:   the related error
    */
    func request(request: SFRestRequest!, didFailLoadWithError error: NSError!) {
        handleError(request, errorMessage: error.localizedDescription)
    }
    
    /**
    Request cancellation handler
    
    - parameter request: the related request
    */
    func requestDidCancelLoad(request: SFRestRequest!) {
        handleError(request, errorMessage: "Error loading data: Request was canceled")
    }

    /**
    Request timeout handler
    
    - parameter request: the related request
    */
    func requestDidTimeout(request: SFRestRequest!) {
        handleError(request, errorMessage: "Error loading data: Timeout")
    }
    
    /**
    Return given error message using failureCallback related to the request
    
    - parameter request:      the request
    - parameter errorMessage: the error message
    */
    func handleError(request: SFRestRequest!, errorMessage: String) {
        dispatch_async( dispatch_get_main_queue(), {
            
            // Get callbacks
            if let callbacks = self.requests[request] {
                self.requests.removeValueForKey(request)
                callbacks.1(errorMessage)
            }
        })
    }
  
}