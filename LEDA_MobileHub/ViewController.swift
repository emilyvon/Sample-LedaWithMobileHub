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
        
        queryUserTaskStatus()
        
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
                print("❗️error: \(error?.localizedDescription)")
                print("❗️output: \(output?.items)")
            }
            
        }
        
    }
    
    
    func queryUserTaskStatus() {
        
        let objMapper = AWSDynamoDBObjectMapper.default()
        
        
        let identityId = AWSIdentityManager.defaultIdentityManager().identityId!
        let exp = AWSDynamoDBQueryExpression()
        exp.keyConditionExpression = "#userId = :userId AND #sort = :sort"
        
        exp.expressionAttributeNames = ["#userId": "userId", "#sort" : "task_day"]
        
        exp.expressionAttributeValues = [":userId": identityId, ":sort": 0]
        
        
        
        exp.projectionExpression = "userId,task_day,is_checked_off,is_completed,tasks"
        
       
        objMapper.query(UserTaskStatus.self, expression: exp) { (output: AWSDynamoDBPaginatedOutput?, error: Error?) in
            
            DispatchQueue.main.async {
                print("❗️error: \(error?.localizedDescription)")
                print("❗️error: \(output?.items)")
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

