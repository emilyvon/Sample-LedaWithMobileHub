//
//  UserAnalytics.swift
//  MySampleApp
//
//
// Copyright 2017 Amazon.com, Inc. or its affiliates (Amazon). All Rights Reserved.
//
// Code generated by AWS Mobile Hub. Amazon gives unlimited permission to 
// copy, distribute and modify it.
//
// Source code generated from template: aws-my-sample-app-ios-swift v0.8
//

import Foundation
import UIKit
import AWSDynamoDB

class UserAnalytics: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _currentDaysInRowUsed: NSNumber?
    var _maxDaysInRowUsed: NSNumber?
    var _tasksCompleted: NSNumber?
    var _tasksPerCategoryCompleted: [String: Any]?
    
    class func dynamoDBTableName() -> String {

        return "ledaapp-mobilehub-99797186-user_analytics"
    }
    
    class func hashKeyAttribute() -> String {

        return "_userId"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_userId" : "userId",
               "_currentDaysInRowUsed" : "current_days_in_row_used",
               "_maxDaysInRowUsed" : "max_days_in_row_used",
               "_tasksCompleted" : "tasks_completed",
               "_tasksPerCategoryCompleted" : "tasks_per_category_completed",
        ]
    }
}
