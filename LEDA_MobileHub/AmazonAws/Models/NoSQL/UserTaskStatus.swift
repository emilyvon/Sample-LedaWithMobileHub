//
//  UserTaskStatus.swift
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

class UserTaskStatus: AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    var _userId: String?
    var _taskDay: NSNumber?
    var _isCompleted: NSNumber?
    var _tasks: [String: Any]?
    
    class func dynamoDBTableName() -> String {

        return "ledaapp-mobilehub-99797186-user_task_status"
    }
    
    class func hashKeyAttribute() -> String {

        return "_userId"
    }
    
    class func rangeKeyAttribute() -> String {

        return "_taskDay"
    }
    
    override class func jsonKeyPathsByPropertyKey() -> [AnyHashable: Any] {
        return [
               "_userId" : "userId",
               "_taskDay" : "task_day",
               "_isCompleted" : "is_completed",
               "_tasks" : "tasks",
        ]
    }
}
