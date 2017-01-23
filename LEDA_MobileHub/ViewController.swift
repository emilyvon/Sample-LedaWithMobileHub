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
    
    @IBOutlet weak var resultLabel: UILabel!


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presentSignInViewController()
    }
    
    
    @IBAction func insert(_ sender: Any) {
        
        scanTasks(startContent: 0, endContent: 3)
    }
    
    func logout() {
        
        AWSIdentityManager.defaultIdentityManager().logout { (obj: Any?, error: Error?) in
            DispatchQueue.main.async {
                self.presentSignInViewController()
            }
        }
    }
    
    
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
    
    func queryUserToolStatus(completion: ()->()) {
        
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
        
        // TODO: save items individually to keychain
        
        // then refresh in completion block
        completion()
        
    }
    
    
    func queryUserAnalytics(completion: ()->()) {
        
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
        
        
        // TODO: save items individually to keychain
        
        // then refresh in completion block
        completion()

    }
    
    
    //==========================================================================
    // MARK: - get all 3 tasks with different a sort key in the same content_day
    //==========================================================================
    func queryTask(withContent dayNo:Int) {
        
        let mapper = AWSDynamoDBObjectMapper.default()

        let exp = AWSDynamoDBQueryExpression()
        
        exp.keyConditionExpression = "#task_day = :task_day"
        exp.expressionAttributeNames = ["#task_day": "task_day"]
        exp.expressionAttributeValues = [":task_day": dayNo]
        exp.projectionExpression = "task_day,sort,task_duration_seconds,task_title,task_type,task_data,task_category,task_subcategory"
        
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
    
    func scanTasks(startContent startNo: Int, endContent endNo: Int) {
        
        let mapper = AWSDynamoDBObjectMapper.default()
        let exp = AWSDynamoDBScanExpression()
        
        exp.filterExpression = "task_day between :start_day and :end_day"
        exp.expressionAttributeValues = [":start_day": startNo, ":end_day": endNo]
        exp.projectionExpression = "task_day,sort,task_duration_seconds,task_title,task_type,task_data,task_category,task_subcategory"
        
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
    

    
    func presentSignInViewController() {
        print("presentSignInViewController: \(AWSIdentityManager.defaultIdentityManager().isLoggedIn)")
        if !AWSIdentityManager.defaultIdentityManager().isLoggedIn {
            
            
            print("✅ present sign in vc")
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                self.present(vc, animated: false, completion: nil)
            }
            
        }
        
    }
    
}

