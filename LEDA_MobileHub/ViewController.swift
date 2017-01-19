//
//  ViewController.swift
//  LEDA_MobileHub
//
//  Created by Mengying Feng on 13/1/17.
//  Copyright © 2017 iEmRollin. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class ViewController: UIViewController {
    

//    var didSignInObserver: AnyObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //        print("Sign In Loading")
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presentSignInViewController()
    }
    
    
    @IBAction func insert(_ sender: Any) {
        
        
        queryTasks()
    }
    
    
    
    
    func queryUserToolStatus() {
        
        let mapper = AWSDynamoDBObjectMapper.default()
        
        let identityId = AWSIdentityManager.defaultIdentityManager().identityId!
        
        let exp = AWSDynamoDBQueryExpression()
        
        exp.keyConditionExpression = "#userId = :userId"
        exp.expressionAttributeNames = ["#userId": "userId"]
        exp.expressionAttributeValues = [":userId": identityId]
        exp.projectionExpression = "userId,breathing_unlocked,complex_emotions_unlocked,making_meaning_unlocked"
        
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
    }
    
    
    func queryUserAnalytics() {
        
        let objMapper = AWSDynamoDBObjectMapper.default()
        
        
        let identityId = AWSIdentityManager.defaultIdentityManager().identityId!
        let exp = AWSDynamoDBQueryExpression()
        
        exp.keyConditionExpression = "#userId = :userId"
        exp.expressionAttributeNames = ["#userId": "userId"]
        exp.expressionAttributeValues = [":userId": identityId]
        
        
        
        exp.projectionExpression = "userId,current_days_in_row_used,max_days_in_row_used,tasks_completed,tasks_per_category_completed"
        
        
        objMapper.query(UserAnalytics.self, expression: exp) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
            
            DispatchQueue.main.async {
                
                if let err = error {
                    print("queryUserAnalytics ❌ \(err.localizedDescription)")
                }
                
                if let items = output?.items {
                    print("queryUserAnalytics ✅ \(items)")
                }
            }
        }
        
    }
    
    func queryTasks() {
        
        let mapper = AWSDynamoDBObjectMapper.default()

        let exp = AWSDynamoDBQueryExpression()
        
        exp.keyConditionExpression = "#content_day = :content_day AND #"
        exp.expressionAttributeNames = ["#content_day": "content_day"]
        exp.expressionAttributeValues = [":content_day": 18]
        exp.projectionExpression = "content_day,sort,duration_seconds,task_title,task_type"
        
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
    
    
    func queryUserTaskStatus(withTask dayNo: Int) {
        
        let objMapper = AWSDynamoDBObjectMapper.default()
        
        
        let identityId = AWSIdentityManager.defaultIdentityManager().identityId!
        let exp = AWSDynamoDBQueryExpression()
        exp.keyConditionExpression = "#userId = :userId AND #sort = :sort"
        exp.expressionAttributeNames = ["#userId": "userId", "#sort" : "task_day"]
        exp.expressionAttributeValues = [":userId": identityId, ":sort": dayNo]
        exp.projectionExpression = "userId,task_day,is_checked_off,is_completed,tasks"
        
       
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
    
    func loadData() {
        
        let mapper = AWSDynamoDBObjectMapper.default()
        
        let identityId = AWSIdentityManager.defaultIdentityManager().identityId!
        
        mapper.load(UserTaskStatus.self, hashKey: identityId, rangeKey: 0) { (model: AWSDynamoDBObjectModel?, error: Error?) in
            
            
            
        }
        
    }
    
    
    func presentSignInViewController() {
        print("presentSignInViewController: \(AWSIdentityManager.defaultIdentityManager().isLoggedIn)")
        if !AWSIdentityManager.defaultIdentityManager().isLoggedIn {
            
            
            print("❗️present sign in vc")
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                self.present(vc, animated: false, completion: nil)
            }
            
        }
        
    }
    
}

