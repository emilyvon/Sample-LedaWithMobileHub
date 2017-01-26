//
//  AWSMobileHubClientManager.swift
//  LEDA_MobileHub
//
//  Created by Mengying Feng on 23/1/17.
//  Copyright © 2017 iEmRollin. All rights reserved.
//

import Foundation
import AWSMobileHubHelper
import AWSDynamoDB
import AWSCognitoIdentityProvider

class AWSMobileHubClientManager {
    
    static let shared = AWSMobileHubClientManager()
    
    //========================================
    // MARK: - Log out
    //========================================
    func logout(completion:@escaping ()->()) {
        
        AWSIdentityManager.defaultIdentityManager().logout { (obj: Any?, error: Error?) in
            DispatchQueue.main.async {
                //                self.presentSignInViewController()
                completion()
            }
        }
    }
    
    //========================================
    // MARK: - Save UserTaskStatus
    //========================================
    func saveUserTaskStatus(withContent dayNo: NSNumber) {
        
        let mapper = AWSDynamoDBObjectMapper.default()
        let item = UserTaskStatus()!
        
        item._userId = AWSIdentityManager.defaultIdentityManager().identityId!
        item._isCompleted = 0
        item._taskDay = dayNo
        item._tasks = ["text":"text", "bool": true, "number": 11, "dict": ["string": "hello"], "list": [3,4,5,6,8]]
        
        
        mapper.save(item) { (error: Error?) in
            DispatchQueue.main.async {
                
                if let err = error {
                    print("saveUerTaskStatus ❌ \(err.localizedDescription)")
                    return
                }
                print("saveUerTaskStatus ✅ ")
                
            }
        }
    }
    
    //========================================
    // MARK: - Query UserToolStatus
    //========================================
    func queryUserToolStatus(completion: @escaping ()->()) {
        
        let mapper = AWSDynamoDBObjectMapper.default()
        
        let identityId = AWSIdentityManager.defaultIdentityManager().identityId!
        
        let exp = AWSDynamoDBQueryExpression()
        
        exp.keyConditionExpression = "#userId = :userId"
        exp.expressionAttributeNames = ["#userId": "userId"]
        exp.expressionAttributeValues = [":userId": identityId]
        exp.projectionExpression = /*ProExp_UserToolStatus*/getProjectExpression(forTable: UserToolStatus.self)
        
        mapper.query(UserToolStatus.self, expression: exp) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
            
            DispatchQueue.main.async {
                
                if let err = error {
                    print("queryUserToolStatus ❌ \(err.localizedDescription)")
                }
                
                if let items = output?.items as? [UserToolStatus] {
                    print("queryUserToolStatus ✅ \(items)")
                    
                    var breath = false, complex = false, meaning = false
                    
                    for item in items {
                        
                        if let breathUnlocked = item._breathingUnlocked {
                            print("breathUnlocked ❗️ \(breathUnlocked)")
                            breath = breathUnlocked.boolValue
                        }
                        
                        if let complexUnlocked = item._complexEmotionsUnlocked {
                            print("complexUnlocked ❗️ \(complexUnlocked)")
                            complex = complexUnlocked.boolValue
                        }
                        
                        if let meaningUnlocked = item._makingMeaningUnlocked {
                            print("meaningUnlocked ❗️ \(meaningUnlocked)")
                            meaning = meaningUnlocked.boolValue
                        }
                    }
                    
                    let kc = KeychainSwift()
                    kc.set(breath, forKey: KC_TOOLS_BREATHING_UNLOCKED)
                    kc.set(complex, forKey: KC_TOOLS_EMOTION_UNLOCKED)
                    kc.set(meaning, forKey: KC_TOOLS_MEANING_UNLOCKED)
                    
                    completion()
                }
            }
        }
    }
    
    
    //========================================
    // MARK: - Query UserAnalytics
    //========================================
    func queryUserAnalytics(completion: @escaping ()->()) {
        
        let objMapper = AWSDynamoDBObjectMapper.default()
        
        
        let identityId = AWSIdentityManager.defaultIdentityManager().identityId!
        let exp = AWSDynamoDBQueryExpression()
        
        exp.keyConditionExpression = "#userId = :userId"
        exp.expressionAttributeNames = ["#userId": "userId"]
        exp.expressionAttributeValues = [":userId": identityId]
        exp.projectionExpression = /*ProExp_UserAnalytics*/getProjectExpression(forTable: UserAnalytics.self)
        
        
        objMapper.query(UserAnalytics.self, expression: exp) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
            
            DispatchQueue.main.async {
                
                if let err = error {
                    print("queryUserAnalytics ❌ \(err.localizedDescription)")
                }
                
                if let items = output?.items as? [UserAnalytics] {
                    print("queryUserAnalytics ✅ \(items)")
                    print("TODO : growth mindset, empathy, negotiation ❗️")
                    
                    var currentDaysInRow = "0", maxDaysInRow = "0", tasksComplete = "0", resilience = "0", growth = "0", empathy = "0", negotiation = "0"
                    
                    for item in items {
                        if let currentDaysInRowUsed = item._currentDaysInRowUsed {
                            print("currentDaysInRowUsed ❗️ \(currentDaysInRowUsed)")
                            currentDaysInRow = currentDaysInRowUsed.stringValue
                        }
                        
                        if let maxDaysInRowUsed = item._maxDaysInRowUsed {
                            print("maxDaysInRowUsed ❗️ \(maxDaysInRowUsed)")
                            maxDaysInRow = maxDaysInRowUsed.stringValue
                        }
                        
                        if let tasksCompleted = item._tasksCompleted {
                            print("tasksCompleted ❗️ \(tasksCompleted)")
                            tasksComplete = tasksCompleted.stringValue
                        }
                        
                        if let tasksPerCategoryCompleted = item._tasksPerCategoryCompleted {
                            print("tasksPerCategoryCompleted ❗️ \(tasksPerCategoryCompleted)")
                            for (k,v) in tasksPerCategoryCompleted {
                                if k.contains("Resilience") {
                                    if let num = v as? NSNumber {
                                        resilience = num.stringValue
                                    }
                                }
                                // TODO : growth mindset, empathy, negotiation ❗️
                                
                            }
                        }
                        
                    }
                    //save to keychain
                    let kc = KeychainSwift()
                    kc.set(currentDaysInRow, forKey: KC_ANALYTICS_CURRENT_DAYS_IN_ROW)
                    kc.set(maxDaysInRow, forKey: KC_ANALYTICS_MAX_DAYS_IN_ROW)
                    kc.set(tasksComplete, forKey: KC_ANALYTICS_TASKS_COMPLETED)
                    kc.set(resilience, forKey: KC_ANALYTICS_RESILIENCE_COMPLETED)
                    kc.set(growth, forKey: KC_ANALYTICS_MINDSET_COMPLETED)
                    kc.set(empathy, forKey: KC_ANALYTICS_EMPATHY_COMPLETED)
                    kc.set(negotiation, forKey: KC_ANALYTICS_NEGOTIATION_COMPLETED)
                    
                    completion()
                }
            }
        }
    }
    
    
    //==============================
    // MARK: - Query one Task
    //==============================
    func queryTask(withContent dayNo:Int, withSort sortNo: Int) {
    
            let mapper = AWSDynamoDBObjectMapper.default()
            let exp = AWSDynamoDBQueryExpression()
    
            exp.keyConditionExpression = "#task_day = :task_day and #sort = :sort"
        exp.expressionAttributeNames = ["#task_day": "task_day", "#sort": "sort"]
        exp.expressionAttributeValues = [":task_day": dayNo, ":sort": sortNo]
            exp.projectionExpression = /*ProExp_Tasks*/getProjectExpression(forTable: Tasks.self)
    
            mapper.query(Tasks.self, expression: exp) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
                DispatchQueue.main.async {
    
                    if let err = error {
                        print("queryTasks ❌ \(err.localizedDescription)")
                    }
    
                    if let items = output?.items {
                        print("queryTasks ✅ \(items)")
                    }
                }
    
            }
        }
    
    
    //========================================
    // MARK: - Scan Tasks
    //========================================
    func scanTasks(startContent startNo: Int, endContent endNo: Int, completion: @escaping ()->()) {
        
        let mapper = AWSDynamoDBObjectMapper.default()
        let exp = AWSDynamoDBScanExpression()
        
        exp.filterExpression = "task_day between :start_day and :end_day"
        exp.expressionAttributeValues = [":start_day": startNo, ":end_day": endNo]
        exp.projectionExpression = /*ProExp_Tasks*/getProjectExpression(forTable: Tasks.self)
        
        mapper.scan(Tasks.self, expression: exp) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async {
                
                if let err = error {
                    print("scanUserTasks ❌ \(err.localizedDescription)")
                }
                
                if let tasks = output?.items as? [Tasks] {
                    print("scanUserTasks ✅ ")
                    
                    var taskArr = [Task]()
                    
                    var taskDay = "", sort = "", taskCategory = "", taskDurationSeconds = "", taskSubcategory = "", taskTitle = "", taskType = "", videoUrl = "", answers = [[String:String]](), graphImage = "", max = "", mean = "", min = "", questions = [String](), resultTextIntro = "", resultTextSectionResult = [[String:String]](), standardDeviation = "", items = [String]()
                    
                    for task in tasks {
                        
                        if let tDay = task._taskDay {
                            taskDay = tDay.stringValue
                        }
                        
                        if let tSort = task._sort {
                            sort = tSort.stringValue
                        }
                        
                        if let tCat = task._taskCategory {
                            taskCategory = tCat
                        }
                        
                        if let tDuration = task._taskDurationSeconds {
                            taskDurationSeconds = tDuration.stringValue
                        }
                        
                        if let tSub = task._taskSubcategory {
                            taskSubcategory = tSub
                        }
                        
                        if let tTitle = task._taskTitle {
                            taskTitle = tTitle
                        }
                        
                        if let tType = task._taskType {
                            taskType = tType
                        }
                        
                        if let data = task._taskData {
                            for (k,v) in data {
                                if k == "video_url" {
                                    if let url = v as? String {
                                        videoUrl = url
                                    }
                                }
                                
                                if k == "answers" {
                                    if let list = v as? [[String:NSNumber]] {
                                        for map in list {
                                            var dict = [String:String]()
                                            for (k,v) in map {
                                                dict[k] = v.stringValue
                                            }
                                            answers.append(dict)
                                        }
                                    }
                                }
                                
                                if k == "graph_image" {
                                    if let image = v as? String {
                                        graphImage = image
                                    }
                                }
                                
                                if k == "max" {
                                    if let ma = v as? NSNumber {
                                        max = ma.stringValue
                                    }
                                }
                                
                                if k == "mean" {
                                    if let me = v as? NSNumber {
                                        mean = me.stringValue
                                    }
                                }
                                
                                if k == "min" {
                                    if let mi = v as? NSNumber {
                                        min = mi.stringValue
                                    }
                                }
                                
                                if k == "questions" {
                                    if let list = v as? [String] {
                                        questions += list
                                    }
                                }
                                
                                if k == "result_text" {
                                    if let map = v as? [String:Any] {
                                        for item in map {
                                            if item.key == "intro" {
                                                if let introStr = item.value as? String {
                                                    resultTextIntro = introStr
                                                }
                                                
                                                if item.key == "section_result" {
                                                    if let list = item.value as? [[String:Any]] {
                                                        var dict = [String: String]()
                                                        for map in list {
                                                            for (k,v) in map {
                                                                if k == "range_end" {
                                                                    if let num = v as? NSNumber {
                                                                        dict[k] = num.stringValue
                                                                    }
                                                                }
                                                                
                                                                if k == "text" {
                                                                    if let str = v as? String {
                                                                        dict [k] = str
                                                                    }
                                                                }
                                                                
                                                                
                                                            }
                                                        }
                                                        
                                                        resultTextSectionResult.append(dict)
                                                        
                                                    }
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                                
                                if k == "standard_deviation" {
                                    if let sd = v as? NSNumber {
                                        standardDeviation = sd.stringValue
                                    }
                                }
                                
                                if k == "items" {
                                    if let it = v as? [String] {
                                        items += it
                                    }
                                }
                            }
                        }
                        
                        let task = Task(taskDay: taskDay, sort: sort, taskCategory: taskCategory, taskDurationSeconds: taskDurationSeconds, taskSubcategory: taskSubcategory, taskTitle: taskTitle, taskType: taskType, videoUrl: videoUrl, answers: answers, graphImage: graphImage, max: max, mean: mean, min: min, questions: questions, resultTextIntro: resultTextIntro, resultTextSectionResult: resultTextSectionResult, standardDeviation: standardDeviation, items: items)
                        
                        taskArr.append(task)

                        
                    }
                    
                    // save [Task] to keychain
                    KeychainSwift().delete("TaskArr")
                    let data = NSKeyedArchiver.archivedData(withRootObject: taskArr)
                    KeychainSwift().set(data, forKey: "TaskArr")

                    completion()
                    
                    // example of unarchive an object in keychain
//                    if let obj = KeychainSwift().getData("TaskArr"), let arr = NSKeyedUnarchiver.unarchiveObject(with: obj) as? [Task] {
//                        print("arr ❗️ \(arr)")
//                    }
                }
            }
        }
        
        
    }
    
    //========================================
    // MARK: - Query UserTaskStatus
    //========================================
    func queryUserTaskStatus(withTask dayNo: Int, completion: @escaping ()->()) {
        
        let objMapper = AWSDynamoDBObjectMapper.default()
        
        let identityId = AWSIdentityManager.defaultIdentityManager().identityId!
        let exp = AWSDynamoDBQueryExpression()
        exp.keyConditionExpression = "#userId = :userId AND #sort = :sort"
        exp.expressionAttributeNames = ["#userId": "userId", "#sort" : "task_day"]
        exp.expressionAttributeValues = [":userId": identityId, ":sort": dayNo]
        exp.projectionExpression = /*ProExp_UserTaskStatus*/getProjectExpression(forTable: UserTaskStatus.self)
        
        
        objMapper.query(UserTaskStatus.self, expression: exp) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
            
            DispatchQueue.main.async {
                
                if let err = error {
                    print("queryUserTaskStatus ❌ \(err.localizedDescription)")
                }
                
                if let items = output?.items {
                    print("queryUserTaskStatus ✅ \(items)")
                    
                    
                    completion()
                }
            }
        }
        
    }
    
    
    //========================================
    // MARK: - Save user detail
    //========================================
    
    func getUserPoolDetail(completion:@escaping ()->()) {
        
        let pool = AWSCognitoIdentityUserPool.init(forKey: AWSCognitoUserPoolsSignInProviderKey)
        
        let user = pool.currentUser()
        user?.getDetails().continue({ (response: AWSTask<AWSCognitoIdentityUserGetDetailsResponse>) -> Any? in
            if let attributes = response.result?.userAttributes {
                
                let kc = KeychainSwift()
                
                for attr in attributes {
                    print("attr ❗️ \(attr.name) \(attr.value)")
                    
                    if let nameStr = attr.name, let valueStr = attr.value {
                        
                        if nameStr == KC_USER_EMAIL {
                            kc.set(valueStr, forKey: KC_USER_EMAIL)
                        }
                        if nameStr == KC_USER_GIVEN_NAME {
                            kc.set(valueStr, forKey: KC_USER_GIVEN_NAME)
                        }
                        if nameStr == KC_USER_FAMILY_NAME {
                            kc.set(valueStr, forKey: KC_USER_FAMILY_NAME)
                        }
                        if nameStr == KC_CUSTOM_START_DATE {
                            kc.set(valueStr, forKey: KC_CUSTOM_START_DATE)
                        }
                    }
                }
                
                completion()
                
            }
            return nil
        })
    }
    
    
    func getArrDisplayed() {
        
        queryUserAnalytics {
            
            let maxDaysInRowInt = Int(KeychainSwift().get(KC_ANALYTICS_MAX_DAYS_IN_ROW)!)!
            
            
            
            
            
        }
        
        
    }
    
    
    //========================================
    // MARK: - get project expression
    //========================================
    func getProjectExpression(forTable tableName: Swift.AnyClass) -> String {
        var exp = ""
        var i = 0
        let rand = tableName.jsonKeyPathsByPropertyKey()!
        
        for r in rand {
            
            if let str = r.value as? String {
                exp += str
                if i != rand.count - 1 {
                    exp += ","
                }
            }
            i += 1
        }
        return exp
    }
    
}
