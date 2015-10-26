//
//  MoodRingApi.swift
//  MoodRing
//
//  Created by TCASSEMBLER on 18.10.15.
//  Copyright © 2015 Topcoder. All rights reserved.
//

import Foundation

/// The sample value for "AVG ON ALL PROJECTS". It's not presented on the server.
let SAMPLE_ALL_PROJECTS_RATING: Float = 4.25

/**
* API class used in the app to access data
*
* @author TCASSEMBLER
* @version 1.0
*/
class MoodRingApi: RestDataSource {
    
    /// the name of the standard field that contains a related date of the object
    let DATE_FIELD = "CreatedDate"
    
    /// the singleton
    class var sharedInstance: MoodRingApi {
        /*
        Currently DemoMoodRingApi is used (see comments in DemoMoodRingApi).
        Should be changed to MoodRingApi() in future.
        */
        struct Singleton { static let instance = DemoMoodRingApi() }
        return Singleton.instance
    }
    
    // MARK: Projects
    
    /**
    Get projects
    
    - parameter projectIDs: The list of project IDs to request. If nil, then request all projects.
    - parameter status:     If not nil, then request projects with given state. If nil, then request all projects.
    - parameter callback:   the callback to return data
    - parameter failure:    the callback to invoke when an error occurred
    */
    func getProjects(projectIDs: [String]? = nil, status: ProjectStatus? = nil,
        callback: ([Project])->(), failure: FailureCallback) {
        
            var q = "SELECT Title__c, TintColor__c, Status__c, Rating__c, IconURL__c, AvgRating__c FROM Project__c"
            var queryHasCondition = false
            if let ids = projectIDs {
                q +=  " WHERE (" + ids.map({"Id = '\($0)'"}).joinWithSeparator(" or ") + ")"
                queryHasCondition = true
            }
            if let status = status {
                q += (queryHasCondition ? " and" : " WHERE") + " Status__c = '\(status.rawValue)'"
                queryHasCondition = true
            }
            
            self.sendQuery(q, callback: { (json) -> () in
                callback(Project.listFromJson(json["records"]))
            }, failure: failure)
    }
    
    // MARK: ProjectUsers
    
    /**
    Get ProjectUsers for given project with current fun factor specified.
    Method returns a list of ProjectUser objects to be shown on Project details screen.
    
    - parameter project:             the project
    - parameter addRatingDateByUser: If not nil, then need to add the last rating date by given user.
                                     If nil, then do not load rating data.
    - parameter callback:            the callback to return data
    - parameter failure:             the callback to invoke when an error occurred
    */
    func getProjectUsersWithCurrentFunFactors(project: Project, addRatingDateByUser: User? = nil,
        callback: ([ProjectUser])->(), failure: FailureCallback) {
        getProjectUsers(project, callback: { (projectUsers) -> () in

            // Get user fun factors
            self.getFunFactors(projectUsers.map {$0.user.id}, callback: { (var funFactors) -> () in
                // reorder fun factors - new at the end
                funFactors.sortInPlace({$0.funFactor.date.compare($1.funFactor.date) == .OrderedAscending})
                var currentFunFactors = funFactors.hasmapWithKey{$0.userId}
                
                // Fill fun factor property
                for projectUser in projectUsers {
                    projectUser.user.funFactor = currentFunFactors[projectUser.user.id]?.funFactor
                }
                
                // Load rating data
                if let rateByUser = addRatingDateByUser {
                    let q = "SELECT ProjectUser__c, \(self.DATE_FIELD) FROM Rating_History__c"
                        + " WHERE (" + projectUsers.map({"ProjectUser__c = '\($0.id)'"}).joinWithSeparator(" or ") + ")"
                        + " and RatedBy__c = '\(rateByUser.id)'"
                    
                    // Get rating history
                    self.sendQuery(q, callback: { (json) -> () in
                        let projectUsersById = projectUsers.hasmapWithKey{$0.id}
                        for item in json["records"].arrayValue {
                            if let projectUser = projectUsersById[item["ProjectUser__c"].stringValue] {
                                projectUser.isRatedByCurrentUser = true // set as already rated
                            }
                        }
                        callback(projectUsers)
                        }, failure: failure)
                }
                else {
                    callback(projectUsers)
                }
                }, failure: failure)
            }, failure: failure)
    }
    
    /**
    Get ProjectUsers for given user.
    Method returns a list of ProjectUser objects to be shown on My Rating screen.
    
    - parameter user:     the user
    - parameter status:   If not nil, then request projects with given state. If nil, then request all projects.
    - parameter callback: the callback to return data
    - parameter failure:  the callback to invoke when an error occurred
    */
    func getProjectUsers(user: User, status: ProjectStatus? = nil,
        callback: ([ProjectUser])->(), failure: FailureCallback) {
        let q = "SELECT User__c, ProjectUserRating__c, Project__c, AvgProjectUserRating__c FROM ProjectUser__c" +
        " WHERE User__c = '\(user.id)'"
        
        // Get ProjectUsers
        self.sendQuery(q, callback: { (json) -> () in
            let projectIDs = json["records"].arrayValue.map{$0["Project__c"].stringValue}.unique

            // If there are projects in which the given user takes part
            if projectIDs.count > 0 {
                // Get Projects
                self.getProjects(projectIDs, status: status, callback: { (projects) -> () in
                    let projectsById = projects.hasmapWithKey({$0.id})
                    var projectUsers = [ProjectUser]()
                    for item in json["records"].arrayValue {
                        let projectId = item["Project__c"].stringValue
                        if let project: Project = projectsById[projectId] {
                            
                            let projectUser = ProjectUser(id: item.getIdFromCommonAttributes(),
                                user: user, project: project)
                            projectUser.projectUserRating = item["ProjectUserRating__c"].floatValue
                            projectUser.avgProjectUserRating = item["AvgProjectUserRating__c"].floatValue
                            projectUsers.append(projectUser)
                        }
                    }
                    callback(projectUsers)
                    }, failure: failure)
            }
            else {
                callback([])
            }
            }, failure: failure)
    }
    
    // MARK: Fun factors
    
    /**
    Get fun factor history for given project
    
    - parameter project:  the project
    - parameter date:     the date to limit the requested data
    - parameter callback: the callback to return data
    - parameter failure:  the callback to invoke when an error occurred
    */
    func getFunFactorHistory(project: Project, date: NSDate = NSDate(),
        callback: ([NSDate: [(User, FunFactorItem)]])->(), failure: FailureCallback) {
        
            // Get users
            getProjectUsers(project, callback: { (projectUsers) -> () in
                
                // Get all fun factors for given users
                let numberOfWeeks = 6 // the number of weeks to request
                self.getFunFactors(projectUsers.map{$0.user.id}.unique, onlyCurrent: false, date: date,
                    daysLimit: numberOfWeeks * 7, callback: { (funFactors) -> () in
                        let usersById = projectUsers.map{$0.user}.hasmapWithKey{$0.id}
                        
                        // Group date by date
                        var list: [NSDate: [(User, FunFactorItem)]] = [:]
                        for item in funFactors {
                            if let user = usersById[item.userId] {
                                let itemDate = item.funFactor.date.beginningOfDay()
                                var listForDate = list[itemDate]
                                if listForDate == nil {
                                    listForDate = [(User, FunFactorItem)]()
                                }
                                
                                listForDate!.append(user, item.funFactor)
                                list[itemDate] = listForDate
                            }
                        }
                        callback(list)
                }, failure: failure)
            }, failure: failure)
    }
    
    /**
    Get fun factor history for given user
    
    - parameter user:     the user
    - parameter callback: the callback to return data
    - parameter failure:  the callback to invoke when an error occurred
    */
    func getFunFactorHistory(user: User, callback: ([FunFactorItem])->(), failure: FailureCallback) {
        
        // Get all fun factors for given user
        self.getFunFactors([user.id], onlyCurrent: false, callback: { (funFactors) -> () in
            
            // Order by date descending
            let list: [FunFactorItem] = funFactors.map({$0.funFactor})
            callback(list)
            
            }, failure: failure)
    }
    
    /**
    Save current fun factor
    
    - parameter funFactorIndex: the fun factor index
    - parameter comment:        the comment
    - parameter callback:       the callback to invoke when the data is saved successfully
    - parameter failure:        the callback to invoke when an error occurred
    */
    func saveFunFactor(funFactorIndex: Int, comment: String,
        callback: ()->(), failure: FailureCallback) {
            let params: [NSObject : AnyObject] = [
                "User__c": AuthenticationUtil.sharedInstance.currentUser.id,
                "FunFactorIndex__c": FunFactorItem.stringFromFactorIndex(funFactorIndex),
                "Current__c": true,
                "Comment__c": comment
            ]
            
            let request = SFRestAPI.sharedInstance().requestForCreateWithObjectType("Fun_Factor__c", fields: params)
            request.parseResponse = false
            
            // save request callbacks
            requests[request] = ({ (JSON)->() in
                callback()
                }, failure)
            
            // send request
            SFRestAPI.sharedInstance().send(request, delegate: self)
    }
    
    // MARK: Ratings
    
    /**
    Get ratings history for given ProjectUsers
    
    - parameter projectUsers: the project user
    - parameter date:         the date to limit the requested data (endDate)
    - parameter daysLimit:    maximum number of days to take into account
    - parameter callback:     the callback to return data
    - parameter failure:      the callback to invoke when an error occurred
    */
    func getRatingHistory(projectUsers: [ProjectUser], date: NSDate? = nil, daysLimit: Int = 1,
        callback: ([NSDate: [Rating]])->(), failure: FailureCallback) {
            if projectUsers.isEmpty || daysLimit <= 0 {
                callback([:])
                return
            }
            
            let projectUsersById = projectUsers.hasmapWithKey({$0.id})
            var q = "SELECT Comment__c, ProjectUser__c, RatedBy__c, Rating__c, \(DATE_FIELD) FROM Rating_History__c" +
                " WHERE (" + projectUsers.map({"ProjectUser__c = '\($0.id)'"}).joinWithSeparator(" or ") + ")"
            
            /// Limit query by given date
            if let date = date {
                let startDate = date.addDays(1 - daysLimit).beginningOfDay()
                let endDate = date.endOfDay()
                q += " and \(DATE_FIELD) >= " + DateFormatters.fullDate.stringFromDate(startDate)
                q += " and \(DATE_FIELD) <= " + DateFormatters.fullDate.stringFromDate(endDate)
            }
            
            // Get rating history
            self.sendQuery(q, callback: { (json) -> () in
                let userIDs = json["records"].arrayValue.map{$0["RatedBy__c"].stringValue}.unique
                
                // Get "RatedBy" Users
                self.getUsersById(userIDs, callback: { (usersById) -> () in
                    var list: [NSDate: [Rating]] = [:]
                    
                    for item in json["records"].arrayValue {
                        if let ratedBy = usersById[item["RatedBy__c"].stringValue] {
                            if let projectUser = projectUsersById[item["ProjectUser__c"].stringValue] {
                                if ratedBy.id == projectUser.user.id { // Skip ratings that are added by the same user
                                    continue
                                }
                                let itemDate = NSDate.parseFullDate(item[self.DATE_FIELD].stringValue) ?? NSDate()
                                let key = itemDate.beginningOfDay()
                                var listForDate = list[key]
                                if listForDate == nil {
                                    listForDate = [Rating]()
                                }
                                
                                let rating = Rating(id: item.getIdFromCommonAttributes(),
                                    projectUser: projectUser,
                                    rating: item["Rating__c"].floatValue,
                                    ratedBy: ratedBy,
                                    comment: item["Comment__c"].stringValue)
                                rating.date = itemDate
                                listForDate!.append(rating)
                                list[key] = listForDate
                            }
                        }
                    }
                    for (day, dayList) in list {
                        list[day] = dayList.sort({$0.date.compare($1.date) == .OrderedAscending})
                    }
                    callback(list)
                    
                    }, failure: failure)
                }, failure: failure)
    }
    
    /**
    Get ratings history for given Project
    
    - parameter project:  the project
    - parameter date:     the date to limit the requested data
    - parameter callback: the callback to return data
    - parameter failure:  the callback to invoke when an error occurred
    */
    func getRatingHistory(project: Project, date: NSDate? = nil,
        callback: ([NSDate: [Rating]])->(), failure: FailureCallback) {
        
            // Get ProjectUsers
            self.getProjectUsers(project, callback: { (projectUsers) -> () in
                
                // Get rating history
                self.getRatingHistory(projectUsers, date: date, callback: callback, failure: failure)
                }, failure: failure)
    }
    
    /**
    Get average rating history for given ProjectUser.
    
    - parameter projectUser: the user
    - parameter daysLimit:   maximum number of days to take into account
    - parameter callback:    the callback to return data
    - parameter failure:     the callback to invoke when an error occurred
    */
    func getAvgRatingHistory(projectUser: ProjectUser, daysLimit: Int = 7,
        callback: ([Rating])->(), failure: FailureCallback) {
            
            getRatingHistory([projectUser], date: NSDate(), daysLimit: daysLimit, callback: { (data) -> () in
                
                // Get rating history
                callback(self.calculateRatingsForGraph(data))
                }, failure: failure)
    }
    
    /**
    Get average rating history for given User.
    
    - parameter user:      the user
    - parameter daysLimit: maximum number of days to take into account
    - parameter callback:  the callback to return data
    - parameter failure:   the callback to invoke when an error occurred
    */
    func getAvgRatingHistory(user: User, daysLimit: Int = 7,
        callback: ([Rating])->(), failure: FailureCallback) {
            
            // Get all the ProjectUsers related to the given user
            getProjectUsers(user, callback: { (projectUsers) -> () in
                
                // Get rating history for these ProjectUsers
                self.getRatingHistory(projectUsers, date: NSDate(), daysLimit: daysLimit, callback: { (data) -> () in
                    
                    callback(self.calculateRatingsForGraph(data))
                    }, failure: failure)
                }, failure: failure)
    }
    
    /**
    Get average rating history for given Project.
    
    - parameter project:   the project
    - parameter daysLimit: maximum number of days to take into account
    - parameter callback:  the callback to return data
    - parameter failure:   the callback to invoke when an error occurred
    */
    func getAvgRatingHistory(project: Project, daysLimit: Int = 7,
        callback: ([Rating])->(), failure: FailureCallback) {
            
            // Get all the ProjectUsers related to the given project
            getProjectUsers(project, callback: { (projectUsers: [ProjectUser]) -> () in
                
                // Get rating history for these ProjectUsers
                self.getRatingHistory(projectUsers, date: NSDate(), daysLimit: daysLimit, callback: { (data) -> () in
                    
                    callback(self.calculateRatingsForGraph(data))
                    }, failure: failure)
                }, failure: failure)
    }
    
    /**
    Save new rating value for given ProjectUser
    
    - parameter rating:      The rating value. Int because UI only allows to select integer values
    - parameter comment:     the comment
    - parameter projectUser: the ProjectUser
    - parameter callback:    the callback to invoke when the data is saved successfully
    - parameter failure:     the callback to invoke when an error occurred
    */
    func saveRating(rating: Int, comment: String, projectUser: ProjectUser,
        callback: ()->(), failure: FailureCallback) {
            let params: [NSObject : AnyObject] = [
                "Rating__c": rating,
                "Comment__c": comment,
                "RatedBy__c": AuthenticationUtil.sharedInstance.currentUser.id,
                "ProjectUser__c": projectUser.id
            ]
            
            let request = SFRestAPI.sharedInstance().requestForCreateWithObjectType("Rating_History__c", fields: params)
            request.parseResponse = false
            
            // save request callbacks
            requests[request] = ({ (JSON)->() in
                callback()
            }, failure)
            
            // send request
            SFRestAPI.sharedInstance().send(request, delegate: self)
    }
    
    // MARK: Profile data
    
    /**
    Get statistic data for given user
    
    - parameter user:      the user
    - parameter callback:  the callback to return data
    - parameter failure:   the callback to invoke when an error occurred
    */
    func getUserStatistic(user: User, callback: (numberOfProjects: Int, avgRating: Float)->(),
        failure: FailureCallback) {
        
            // Get number of projects
            self.getProjectUsers(user,
                callback: { (projectUsers) -> () in
                    
                    // Get average rating for all projects
                    let avgRating = SAMPLE_ALL_PROJECTS_RATING // Currently not provided by the server
                    callback(numberOfProjects: projectUsers.count, avgRating: avgRating)
                }, failure: failure)
    }
    
    // MARK: Helpful methods
    
    /**
    Get users with given IDs
    
    - parameter userIDs:  the list of user IDs
    - parameter callback: the callback to return data
    - parameter failure:  the callback to invoke when an error occurred
    */
    internal func getUsersById(userIDs: [String], callback: ([String: User])->(), failure: FailureCallback) {
        if userIDs.isEmpty {
            callback([:])
            return
        }
        let q = "SELECT Id, Name FROM User WHERE " + userIDs.map({"Id = '\($0)'"}).joinWithSeparator(" or ")
        
        self.sendQuery(q, callback: { (json) -> () in
            callback(User.listFromJson(json["records"]).hasmapWithKey{$0.id})
            }, failure: failure)
    }
    
    /**
    Get users for given project.
    The returned user objects has no current fun factor specified.
    
    - parameter project:  the project which users to request
    - parameter callback: the callback to return data
    - parameter failure:  the callback to invoke when an error occurred
    */
    private func getProjectUsers(project: Project, callback: ([ProjectUser])->(), failure: FailureCallback) {
        
        let q = "SELECT User__c, ProjectUserRating__c, Project__c, AvgProjectUserRating__c FROM ProjectUser__c" +
        " WHERE Project__c = '\(project.id)'"
        
        // Get ProjectUsers
        self.sendQuery(q, callback: { (json) -> () in
            let userIDs = json["records"].arrayValue.map{$0["User__c"].stringValue}.unique
            
            // Get Users
            self.getUsersById(userIDs, callback: { (usersById) -> () in
                var projectUsers = [ProjectUser]()
                for item in json["records"].arrayValue {
                    let userId = item["User__c"].stringValue
                    if let user: User = usersById[userId] {
                        
                        let projectUser = ProjectUser(id: item.getIdFromCommonAttributes(),
                            user: user, project: project)
                        projectUser.projectUserRating = item["ProjectUserRating__c"].floatValue
                        projectUser.avgProjectUserRating = item["AvgProjectUserRating__c"].floatValue
                        projectUsers.append(projectUser)
                    }
                }
                callback(projectUsers)
                }, failure: failure)
            }, failure: failure)
    }
    
    /**
    Get fun factors for given users
    
    - parameter userIDs:     the list of user IDs
    - parameter onlyCurrent: flag: true - request only current fun factors
    - parameter date:        the date to limit the requested data (endDate)
    - parameter daysLimit:    maximum number of days to take into account
    - parameter callback:    the callback to return data
    - parameter failure:     the callback to invoke when an error occurred
    */
    private func getFunFactors(userIDs: [String], onlyCurrent: Bool = true, date: NSDate = NSDate(), daysLimit: Int = 7,
        callback: ([(userId: String, funFactor: FunFactorItem)])->(), failure: FailureCallback) {
            if userIDs.isEmpty {
                callback([])
                return
            }
            var q = "SELECT Comment__c, Current__c, FunFactorIndex__c, User__c, \(DATE_FIELD) FROM Fun_Factor__c" +
                " WHERE (" + userIDs.map({"User__c = '\($0)'"}).joinWithSeparator(" or ") + ")"
            if onlyCurrent {
               q += " and Current__c = true"
            }
            
            /// Limit query by given date
            let startDate = date.addDays(1 - daysLimit).beginningOfDay()
            let endDate = date.endOfDay()
            q += " and \(DATE_FIELD) >= " + DateFormatters.fullDate.stringFromDate(startDate)
            q += " and \(DATE_FIELD) <= " + DateFormatters.fullDate.stringFromDate(endDate)
            
            self.sendQuery(q, callback: { (json) -> () in
                var list = [(userId: String, funFactor: FunFactorItem)]()
                for item in json["records"].arrayValue {
                    let userId = item["User__c"].stringValue
                    let funFactor = FunFactorItem(
                        funFactor: FunFactorItem.factorIndexFromString(item["FunFactorIndex__c"].stringValue),
                        comment: item["Comment__c"].stringValue,
                        date: NSDate.parseFullDate(item[self.DATE_FIELD].stringValue) ?? NSDate())
                    list.append((userId: userId, funFactor: funFactor))
                }
                // sort fun factors so that new will be on the top of the list
                list.sortInPlace({$0.funFactor.date.compare($1.funFactor.date) == .OrderedDescending})
                callback(list)
                }, failure: failure)
            
    }
    
    /**
    Convert data for plot graph.
    WARNING! For now if just takes all rating values and returns in a list.
    This is made for demonstration because it's not possible to change dates to past and provide enough data for
    a plot graph.
    
    - parameter data: the raw rating data
    
    - returns: the aggregated rating data
    */
    func calculateRatingsForGraph(data: [NSDate: [Rating]]) -> [Rating] {
        var list = [Rating]()
        for (_, dayRatings) in data {
            for rating in dayRatings {
                list.append(rating)
            }
        }
        list.sortInPlace({$0.date.compare($1.date) == .OrderedAscending})
        return list
    }
}

/**
* Class that adds missing sample data for User objects: profile icons and avgAllProjectsRating.
* Currently server does not support some data in User object (icons, average rating for all projects, etc).
* Hence for demonstration icons are taken from local resources and average rating is set from a constant.
* To skip using this API class just change MoodRingApi.sharedInstance creation.
*
* @author TCASSEMBLER
* @version 1.0
*/
class DemoMoodRingApi: MoodRingApi {
    
    /**
    Delegates method to super class and then adds local image names for corresponding accounts.
    
    - parameter project:  the project which users to request
    - parameter callback: the callback to return data
    - parameter failure:  the callback to invoke when an error occurred
    */
    override func getUsersById(userIDs: [String], callback: ([String : User]) -> (), failure: FailureCallback) {
        let SAMPLE_ICONS_BY_ID = [
            "00524000001Hld3AAC": "ava1",
            "00524000001HlYRAA0": "ava0",
            "00524000001HldNAAS": "ava5",
            "00524000001HldIAAS": "ava3",
            "00524000001HldmAAC": "ava4",
            "00524000001Hld8AAC": "ava2",
        ]
        super.getUsersById(userIDs, callback: { (users) -> () in
            
            // Specify profile icons for demonstration
            for (k, user) in users {
                user.iconUrl = SAMPLE_ICONS_BY_ID[k]
                user.avgAllProjectsRating = SAMPLE_ALL_PROJECTS_RATING
            }
            callback(users)
            }, failure: failure)
    }
    
}

/**
* Helpful extension contains methods related to parsing data fromMoodRingApi
*
* @author TCASSEMBLER
* @version 1.0
*/
extension FunFactorItem {
    
    /**
    Get fun factor index by given string

    - parameter str: the string
    
    - returns: the fun factor index
    */
    class func factorIndexFromString(str: String) -> Int {
        switch str {
        case "laugh":
            return 4
        case "happy":
            return 3
        case "normal":
            return 2
        case "sad":
            return 1
        case "pain":
            return 0
        default:
            return 2 // normal
        }
    }
    
    /**
    Convert given fun factor index to string
    
    - parameter funFactorIndex: the fun factor index
    
    - returns: the string
    */
    class func stringFromFactorIndex(funFactorIndex: Int) -> String {
        switch funFactorIndex {
        case 4:
            return "laugh"
        case 3:
            return "happy"
        case 2:
            return "normal"
        case 1:
            return "sad"
        case 0:
            return "pain"
        default:
            return "normal"
        }
    }
}

/**
* Helpful extension contains methods related to parsing data fromMoodRingApi
*
* @author TCASSEMBLER
* @version 1.0
*/
extension User {
    
    /**
    Parse a list of users from given JSON data
    
    - parameter json: JSON data
    
    - returns: the list of users
    */
    class func listFromJson(json: JSON) -> [User] {
        var list = [User]()
        for item in json.arrayValue {
            list.append(User.fromJson(item))
        }
        return list
    }
 
    /**
    Parse a user from given JSON data
    
    - parameter json: JSON data
    
    - returns: the user
    */
    class func fromJson(json: JSON) -> User {
        let user = User(id: json.getIdFromCommonAttributes(), json["Name"].stringValue, funFactor: nil)
        return user
    }
}

/**
* Helpful extension contains methods related to parsing data fromMoodRingApi
*
* @author TCASSEMBLER
* @version 1.0
*/
extension Project {
    
    /**
    Parse a list of projects from given JSON data
    
    - parameter json: JSON data
    
    - returns: the list of projects
    */
    class func listFromJson(json: JSON) -> [Project] {
        var projects = [Project]()
        for item in json.arrayValue {
            projects.append(Project.fromJson(item))
        }
        return projects
    }
    
    /**
    Parse a project from given JSON data
    
    - parameter json: JSON data
    
    - returns: the project
    */
    class func fromJson(json: JSON) -> Project {
        let project = Project(id: json.getIdFromCommonAttributes(),
            title: json["Title__c"].stringValue,
            rating: json["Rating__c"].floatValue,
            avgRating: json["AvgRating__c"].floatValue,
            iconURL: json["IconURL__c"].string)
        if let status = ProjectStatus(rawValue: json["Status__c"].stringValue) {
            project.status = status
        }
        
        /*
        Set fun factor to reflect current rating
        according to http://apps.topcoder.com/forums/?module=Thread&threadID=867789&start=0&mc=1#2062760
        */
        project.funFactor = Int(round(project.rating)) - 1
        
        // Tint Color is used for project icon background
        if let tintColor = UIColor.fromString(json["TintColor__c"].stringValue) {
            project.tintColor = tintColor
        }
        return project
    }
}

/**
* Helpful extension contains methods related to parsing data fromMoodRingApi
*
* @author TCASSEMBLER
* @version 1.0
*/
extension JSON {
    
    /**
    Get object ID from common attributes
    
    - returns: the ID
    */
    func getIdFromCommonAttributes() -> String {
        return self["attributes"]["url"].getIdFromURL()
    }
    
    /**
    Get object ID from the resource URL (this JSON object)
    
    - returns: the ID
    */
    func getIdFromURL() -> String {
        let splited = self.stringValue.componentsSeparatedByString("/")
        if let last = splited.last {
            return last
        }
        return ""
    }
}