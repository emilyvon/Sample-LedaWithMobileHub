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
        item._isCheckedOff = 0
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
    func queryUserToolStatus(completion: ()->()) {
        
        let mapper = AWSDynamoDBObjectMapper.default()
        
        let identityId = AWSIdentityManager.defaultIdentityManager().identityId!
        
        let exp = AWSDynamoDBQueryExpression()
        
        exp.keyConditionExpression = "#userId = :userId"
        exp.expressionAttributeNames = ["#userId": "userId"]
        exp.expressionAttributeValues = [":userId": identityId]
        exp.projectionExpression = ProExp_UserToolStatus
        
        mapper.query(UserToolStatus.self, expression: exp) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
            
            DispatchQueue.main.async {
                
                if let err = error {
                    print("queryUserToolStatus ❌ \(err.localizedDescription)")
                }
                
                if let items = output {
                    print("queryUserToolStatus ✅ \(items)")
                }
            }
        }
        
        // TODO: save items individually to keychain
        
        // then refresh in completion block
        completion()
        
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
        exp.projectionExpression = ProExp_UserAnalytics
        
        
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
    func queryTask(withContent dayNo:Int) {
        
        let mapper = AWSDynamoDBObjectMapper.default()
        let exp = AWSDynamoDBQueryExpression()
        
        exp.keyConditionExpression = "#task_day = :task_day"
        exp.expressionAttributeNames = ["#task_day": "task_day"]
        exp.expressionAttributeValues = [":task_day": dayNo]
        exp.projectionExpression = ProExp_Tasks
        
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
    func scanTasks(startContent startNo: Int, endContent endNo: Int) {
        
        let mapper = AWSDynamoDBObjectMapper.default()
        let exp = AWSDynamoDBScanExpression()
        
        exp.filterExpression = "task_day between :start_day and :end_day"
        exp.expressionAttributeValues = [":start_day": startNo, ":end_day": endNo]
        exp.projectionExpression = ProExp_Tasks
        
        mapper.scan(Tasks.self, expression: exp) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
            DispatchQueue.main.async {
                
                if let err = error {
                    print("scanUserTasks ❌ \(err.localizedDescription)")
                }
                
                if let items = output?.items {
                    print("scanUserTasks ✅ \(items)")
                }
            }
        }
        
        
    }
    
    //========================================
    // MARK: - Query UserTaskStatus
    //========================================
    func queryUserTaskStatus(withTask dayNo: Int) {
        
        let objMapper = AWSDynamoDBObjectMapper.default()
        
        let identityId = AWSIdentityManager.defaultIdentityManager().identityId!
        let exp = AWSDynamoDBQueryExpression()
        exp.keyConditionExpression = "#userId = :userId AND #sort = :sort"
        exp.expressionAttributeNames = ["#userId": "userId", "#sort" : "task_day"]
        exp.expressionAttributeValues = [":userId": identityId, ":sort": dayNo]
        exp.projectionExpression = ProExp_UserTaskStatus
        
        
        objMapper.query(UserTaskStatus.self, expression: exp) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
            
            DispatchQueue.main.async {
                
                if let err = error {
                    print("queryUserTaskStatus ❌ \(err.localizedDescription)")
                }
                
                if let items = output?.items {
                    print("queryUserTaskStatus ✅ \(items)")
                }
            }
        }
        
    }
    
    
    
}
