//
//  AWSClientManager.swift
//  LEDA
//
//  Created by Mengying Feng on 18/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider
import AWSDynamoDB

class CustomIdentityProviderManager: NSObject, AWSIdentityProviderManager {
    
    var token: String?
    
    init(token: String) {
        self.token = token
    }
    
    func logins() -> AWSTask<NSDictionary> {
        
        return AWSTask<NSDictionary>(result: [IDENTYTY_PROVIDER_DOMAIN:token!])
    }
    
}

class AWSClientManager {
    
    static let shared = AWSClientManager()
    
    var pool: AWSCognitoIdentityUserPool!
    var user: AWSCognitoIdentityUser?
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    
    
    func registerUserPool(completion: (_ pool: AWSCognitoIdentityUserPool)->()) {
        
        print("*** setting up AWS ***")
        
        //setup logging
        //        AWSLogger.default().logLevel = .verbose
        AWSLogger.default().logLevel = .info
        
        // setup service config
        // MARK: --------- 1. setup service config
        NSLog("--------- 1. setup service config")
        
        
        // work
        let serviceConfig = AWSServiceConfiguration(region: AWSRegionType.usEast1, credentialsProvider: nil)
        
        // work
        AWSServiceManager.default().defaultServiceConfiguration = serviceConfig
        
        
        if let currentPool = AWSCognitoIdentityUserPool(forKey: KEY_USER_POOL) as AWSCognitoIdentityUserPool? {
            
            print("currentPool 1 ✅ \(currentPool.currentUser()?.username)")
            
            currentPool.clearAll()
            
            print("currentPool 2 ✅ \(currentPool.currentUser()?.username)")
            
        } else {
            print("pool is clean ✅")
        }
        
        
        // create a pool
        // MARK: --------- 2. create a pool
        NSLog("--------- 2. create a pool")
        let poolConfig = AWSCognitoIdentityUserPoolConfiguration(clientId: COGNITO_CLIENT_ID, clientSecret: COGNITO_CLIENT_SECRET, poolId: COGNITO_USER_POOL_ID)
        
        
        
        
        AWSCognitoIdentityUserPool.register(with: serviceConfig, userPoolConfiguration: poolConfig, forKey: KEY_USER_POOL)
        
        pool = AWSCognitoIdentityUserPool(forKey: KEY_USER_POOL)
        
        
        
        print("registerUserPool ✅ \(pool.currentUser()?.username)")
        
        
        completion(pool)
    }
    
    
    
    // sign in user explicitly
    func signInUser(name: String, password: String, completion: @escaping (Bool)->()) {
        
        let pool = AWSCognitoIdentityUserPool(forKey: KEY_USER_POOL)
        
        //     if user == nil {
        user = pool.currentUser()
        //     }
        
        user?.getSession(name, password: password, validationData: nil).continue({ (session: AWSTask<AWSCognitoIdentityUserSession>) -> Any? in
            
            if let err = session.error {
                
                print("*** signInUser : err *** : \(err.localizedDescription)")
                completion(false)
                
            } else {
                
                
                if let jwtSessionToken = session.result?.idToken?.tokenString {
                    
                    print("signin explicitly*** session.idToken *** : \(jwtSessionToken)")
                    
                    
                    
                    let customIdProviderManager = CustomIdentityProviderManager(token: jwtSessionToken)
                    
                    let credentialProvider = AWSCognitoCredentialsProvider(regionType: .usEast1, identityPoolId: COGNITO_IDENTITY_POOL_ID, identityProviderManager: customIdProviderManager)
                    
                    credentialProvider.clearKeychain()
                    
                    let serviceConfig = AWSServiceConfiguration(region: AWSRegionType.usEast1, credentialsProvider: credentialProvider)
                    AWSServiceManager.default().defaultServiceConfiguration = serviceConfig
                    
                    
                    credentialProvider.getIdentityId().continue({ task -> Any? in
                        
                        if let err = task.error {
                            
                            print("signInUser*** ❌ *** : \(err)")
                            
                        } else {
                            
                            if let uid = task.result {
                                
                                // save user detail in background thread
                                
                                DispatchQueue.global(qos: DispatchQoS.QoSClass.background).async {
                                    self.getUserDetail(completion: { (_, _, _) in
                                        
                                    })
                                    
                                }
                                
                                print("signin explicitly*** ✅ *** identityID : \(uid)")
                                
                                let keychain = KeychainSwift()
                                
                                keychain.set(jwtSessionToken, forKey: KC_SESSION_TOKEN)
                                
                                keychain.set(name, forKey: KC_USER_EMAIL)
                                keychain.set(password, forKey: KC_USER_PASSWORD)
                                
                                keychain.set(uid as String, forKey: KC_USER_UID)
                                
                                // register db
                                AWSDynamoDB.register(with: serviceConfig!, forKey: "ledaDB")
                                
                                completion(true)
                            }
                        }
                        return nil
                    })
                    
                }
            }
            
            return nil
        })
        
    }
    

    func getUserDetail(completion: @escaping (_ givenName: String, _ familyName: String, _ email: String)->()) {
        
        if let first = KeychainSwift().get(KC_USER_FIRSTNAME), let last = KeychainSwift().get(KC_USER_LASTNAME), let email = KeychainSwift().get(KC_USER_EMAIL) {
            print("AWSClientManager : getUserDetail : from UserDefaults ❗️")
            
            completion(first, last, email)
            
            
        } else {
            print("AWSClientManager : getUserDetail : from Cognito ❗️")
            
            var givenName = "", familyName = "", email = ""
            var startDate: String? = nil
            
            let pool = AWSCognitoIdentityUserPool(forKey: KEY_USER_POOL)
            
            user = pool.currentUser()
            
            
            user?.getDetails().continue({ (taskResponse: AWSTask<AWSCognitoIdentityUserGetDetailsResponse>) -> Any? in
                
                
                if let err = taskResponse.error {
                    print("AWSClientManager : getUserDetail ❌ \(err.localizedDescription)")
                } else {
                    
                    
                    if let attributes = taskResponse.result?.userAttributes {
                        
                        for attribute in attributes {
                            
                            if let attributeName = attribute.name {
                                
                                if attributeName == USER_ATTRIBUTES_GIVEN_NAME {
                                    
                                    if let given = attribute.value {
                                        print("given ✅ \(given)")
                                        KeychainSwift().set(given, forKey: KC_USER_FIRSTNAME)
                                        givenName = given
                                    }
                                }
                                
                                if attributeName == USER_ATTRIBUTES_FAMILY_NAME {
                                    
                                    if let family = attribute.value {
                                        print("family ✅ \(family)")
                                        KeychainSwift().set(family, forKey: KC_USER_LASTNAME)
                                        familyName = family
                                    }
                                }
                                
                                //                                if attributeName == USER_ATTRIBUTES_EMAIL {
                                //
                                //                                    if let emailStr = attribute.value {
                                //                                        print("emailStr ✅ \(emailStr)")
                                //
                                //                                        email = emailStr
                                //                                    }
                                //                                }
                                
                                if attributeName == USER_ATTRIBUTES_START_DATE {
                                    if let date = attribute.value {
                                        print("date ✅ \(date)")
                                        KeychainSwift().set(date, forKey: KC_CUSTOM_START_DATE)
                                        startDate = date
                                    }
                                }
                            }
                        }
                        // save UserInfo and custom:start_date to UserDefaults
                        //                        let userInfo = UserInfo(givenName: givenName, familyName: familyName, email: email)
                        //                        let encode = NSKeyedArchiver.archivedData(withRootObject: userInfo)
                        //                        let defaults = UserDefaults.standard
                        //                        defaults.set(encode, forKey: UD_CURRENT_USER_INFO)
                        //
                        //                        defaults.set(startDate, forKey: UD_CUSTOM_START_DATE)
                        //
                        //                        defaults.synchronize()
                        
                        completion(givenName, familyName, email)
                        
                    }
                    
                }
                
                
                
                return nil
            })
        }
    }
    
    
    
    func forgotPassword(completion: @escaping ()->()) {
        
        let pool = AWSCognitoIdentityUserPool(forKey: KEY_USER_POOL)
        
        user = pool.currentUser()
        
        user?.forgotPassword().continue({ (response: AWSTask<AWSCognitoIdentityUserForgotPasswordResponse>) -> Any? in
            
            if let err = response.error {
                
                print("forgot password ❌ : \(err.localizedDescription)")
                
            } else {
                
                print("forgot password ✅")
                completion()
                
            }
            
            
            return nil
        })
        
        
    }
    
    /*
    func resetPassword(code: String, newPassword: String) {
        
        let pool = AWSCognitoIdentityUserPool(forKey: KEY_USER_POOL)
        
        user = pool.currentUser()
        
        user?.confirmForgotPassword(code, password: newPassword).continue({ (response: AWSTask<AWSCognitoIdentityUserConfirmForgotPasswordResponse>) -> Any? in
            
            if let err = response.error {
                print("resetPassword ❌ \(err.localizedDescription)")
            } else {
                print("resetPassword ✅")
            }
            
            
            return nil
        })
    }
    */
    
    func registerDynamoDB(withToken sessionToken: String, completion: @escaping ()->()) {
        print("AWSClientManager : registerDynamoDB:withToken ✅")
        
        let customIdProviderManager = CustomIdentityProviderManager(token: sessionToken)
        
        let credentialProvider = AWSCognitoCredentialsProvider(regionType: .usEast1, identityPoolId: COGNITO_IDENTITY_POOL_ID, identityProviderManager: customIdProviderManager)
        
        credentialProvider.clearKeychain()
        
        
        let serviceConfig = AWSServiceConfiguration(region: AWSRegionType.usEast1, credentialsProvider: credentialProvider)
        AWSServiceManager.default().defaultServiceConfiguration = serviceConfig
        
        AWSDynamoDB.register(with: serviceConfig!, forKey: "ledaDB")
        
        completion()
        
    }
    
    func registerDynamoDB(completion: @escaping ()->()) {
        
        let pool = AWSCognitoIdentityUserPool(forKey: KEY_USER_POOL)
        
        let user = pool.currentUser()
        
        print("AWSClientManager : registerDynamoDB ✅")
        
        
        let keychain = KeychainSwift()
        
        guard let kc_user_email = keychain.get(KC_USER_EMAIL), let kc_user_password = keychain.get(KC_USER_PASSWORD) else { return }
        
        print("registerDynamoDB : keychain email&password ✅ \(kc_user_email) \(kc_user_password)")
        
        user?.getSession(kc_user_email, password: kc_user_password, validationData: nil).continue({ (session: AWSTask<AWSCognitoIdentityUserSession>) -> Any? in
            
            if let err = session.error {
                
                print("*** registerDynamoDB : err *** ❌ \(err.localizedDescription)")
                
            } else {
                
                //                print("session.result?.accessToken ✅ \(session.result?.accessToken?.tokenString)")
                //                print("session.result?.idToken ✅ \(session.result?.idToken?.tokenString)")
                //                print("session.result?.refreshToken ✅ \(session.result?.refreshToken?.tokenString)")
                //                print("session.result?.expirationTime ✅ \(session.result?.expirationTime)")
                
                
                
                
                if let jwtSessionToken = session.result?.idToken?.tokenString {
                    
                    print("*** registerDynamoDB : session.idToken *** : \(jwtSessionToken)")
                    
                    let customIdProviderManager = CustomIdentityProviderManager(token: jwtSessionToken)
                    
                    let credentialProvider = AWSCognitoCredentialsProvider(regionType: .usEast1, identityPoolId: COGNITO_IDENTITY_POOL_ID, identityProviderManager: customIdProviderManager)
                    
                    credentialProvider.clearKeychain()
                    
                    
                    let serviceConfig = AWSServiceConfiguration(region: AWSRegionType.usEast1, credentialsProvider: credentialProvider)
                    AWSServiceManager.default().defaultServiceConfiguration = serviceConfig
                    
                    //                    AWSDynamoDB.register(with: serviceConfig!, forKey: "ledaDB")
                    
                    // MARK: for reference
                    
                    // get user identityId
                    // works
                    credentialProvider.getIdentityId().continue({ task -> Any? in
                        
                        if let err = task.error {
                            
                            print("registerDynamoDB*** ❌ *** : \(err)")
                            
                        } else {
                            
                            if let uid = task.result {
                                
                                print("AWSClientManager *** ✅ *** identityID : \(uid)")
                                
                                AWSDynamoDB.register(with: serviceConfig!, forKey: "ledaDB")
                                
                                completion()
                            }
                        }
                        return nil
                    })
                }
            }
            return nil
        })
    }
    
    /*
    func queryDataFromDB(completion: @escaping ()->()) {
        
        if let token = KeychainSwift().get(KC_SESSION_TOKEN) {
            
            let customIdProviderManager = CustomIdentityProviderManager(token: token)
            
            let credentialProvider = AWSCognitoCredentialsProvider(regionType: .usEast1, identityPoolId: COGNITO_IDENTITY_POOL_ID, identityProviderManager: customIdProviderManager)
            
            credentialProvider.clearKeychain()
            
            
            let serviceConfig = AWSServiceConfiguration(region: AWSRegionType.usEast1, credentialsProvider: credentialProvider)
            AWSServiceManager.default().defaultServiceConfiguration = serviceConfig
            
            credentialProvider.getIdentityId().continue({ (task: AWSTask<NSString>) -> Any? in
                
                if let err = task.error {
                    
                    print("queryDataFromDB*** ❌ *** : \(err)")
                    
                } else {
                    
                    AWSDynamoDB.register(with: serviceConfig!, forKey: "ledaDB")
                    
                    completion()
                    
                }
                return nil
            })
        }
    }
    */
    
    /*
    func saveStartDate() {
        
        pool = AWSCognitoIdentityUserPool(forKey: KEY_USER_POOL)
        
        if user == nil {
            user = pool.currentUser()
        }
        
        let time = Helper.shared.getCurrentDateStr()
        
        let attrStartDate = AWSCognitoIdentityUserAttributeType()
        attrStartDate?.name = "custom:start_date"
        attrStartDate?.value = time
        
        user?.update([attrStartDate!]).continue({ (response: AWSTask<AWSCognitoIdentityUserUpdateAttributesResponse>) -> Any? in
            
            if let err = response.error {
                
                print("*** ❌ can't saved custom:start_date *** : \(err.localizedDescription)")
                
            } else {
                print("*** ✅ saved custom:start_date ***")
                KeychainSwift().set(time, forKey: KC_CUSTOM_START_DATE)
            }
            
            return nil
        })
    }
    */
    
    func saveUserInfo(givenName: String, familyName: String, email: String, completion:@escaping ()->()) {
        
        pool = AWSCognitoIdentityUserPool(forKey: KEY_USER_POOL)
        
        if user == nil {
            user = pool.currentUser()
        }
        
        let attrGivenName = AWSCognitoIdentityUserAttributeType()
        attrGivenName?.name = USER_ATTRIBUTES_GIVEN_NAME
        attrGivenName?.value = givenName
        
        let attrfamilyName = AWSCognitoIdentityUserAttributeType()
        attrfamilyName?.name = USER_ATTRIBUTES_FAMILY_NAME
        attrfamilyName?.value = familyName
        
        let attrEmail = AWSCognitoIdentityUserAttributeType()
        attrEmail?.name = USER_ATTRIBUTES_EMAIL
        attrEmail?.value = email
        
        
        user?.update([attrGivenName!, attrfamilyName!, attrEmail!]).continue({ (response: AWSTask<AWSCognitoIdentityUserUpdateAttributesResponse>) -> Any? in
            
            if let err = response.error {
                print("*** ❌ can't userInfo *** : \(err.localizedDescription)")
            } else {
                print("*** ✅ saved userInfo ***")
                
                let kc = KeychainSwift()
                kc.set(givenName, forKey: KC_USER_FIRSTNAME)
                kc.set(familyName, forKey: KC_USER_LASTNAME)
                kc.set(email, forKey: KC_USER_EMAIL)
                
                completion()
            }
            
            return nil
        })
    }
    
    //======================================================
    // MARK: - get a range of tasks and save to UserDefaults
    //======================================================
    func getItemFromDB(startTaskNo: Int, endTaskNo: Int, completion: @escaping ([(key: Int, value: UserContent)])->Void) {
        
        print("AWSClientManager : getItemFromDB ✅ ")
        
        print("startTaskNo ✅ \(startTaskNo), endTaskNo: \(endTaskNo)")
        
        let dynamoDB = AWSDynamoDB(forKey: "ledaDB")
        
        var dict = [Int: UserContent]()
        var content_category = ""
        var content_day = ""
        
        var requestCount = 0
        
        for x in startTaskNo ... endTaskNo {
            
            let attValue = AWSDynamoDBAttributeValue()
            attValue?.n = "\(x)"
            
            let request = AWSDynamoDBGetItemInput()
            request?.tableName = TABLE_NAME_TASK_CONTENT
            request?.key = ["content_day": attValue!]
            request?.projectionExpression = "content_day,content_category,tasks"
            
            dynamoDB.getItem(request!) { (output, error) in
                if let err = error {
                    print("*** getItem ❌ *** :\(err.localizedDescription)")
                } else {
                    
                    var taskDict = [String: UserTask]()
                    
                    if let itemDict = output?.item {
                        
                        if let contentCategory = itemDict["content_category"]?.s {
                            content_category = contentCategory
                        }
                        
                        if let contentDate = itemDict["content_day"]?.n {
                            content_day = contentDate
                        }
                        
                        if let tasksDict = itemDict["tasks"]?.m {
                            
                            for (key, value) in tasksDict {
                                
                                var itemsList = [String]()
                                var task_title = "", task_category = "", task_type = "", task_duration = ""
                                var videoUrl = ""
                                var answers = [[String: String]]()
                                var graphImage = ""
                                var max = ""
                                var mean = ""
                                var min = ""
                                var questions = [String]()
                                var resultIntro = ""
                                var resultSection = [[String: String]]()
                                var standard_deviation = ""
                                var task_description = ""
                                var info_title = ""
                                var info_image = ""
                                var goal_video = ""
                                var goal_related_video = [String]()
                                
                                
                                for (key2, value2) in value.m! {
                                    
                                    switch key2 {
                                    case "items":
                                        if let list = value2.l {
                                            for item in list {
                                                if let i = item.s {
                                                    itemsList.append(i)
                                                }
                                            }
                                        }
                                    case "task_title":
                                        if let title = value2.s {
                                            task_title = title
                                        }
                                    case "task_category":
                                        if let cat = value2.s {
                                            task_category = cat
                                        }
                                    case "task_type":
                                        if let type = value2.s {
                                            task_type = type
                                        }
                                    case "task_duration":
                                        if let duration = value2.n {
                                            task_duration = duration
                                        }
                                    case "video_url":
                                        if let id = value2.s {
                                            videoUrl = id
                                        }
                                    case "answers":
                                        if let ans = value2.l {
                                            for item in ans {
                                                if let i = item.m {
                                                    if let label = i["label"]?.s, let value = i["value"]?.n {
                                                        answers.append([label: value])
                                                    }
                                                }
                                            }
                                        }
                                    case "graph_image":
                                        if let img = value2.s {
                                            graphImage = img
                                        }
                                    case "max":
                                        if let maxVal = value2.n {
                                            max = maxVal
                                        }
                                    case "mean":
                                        if let meanVal = value2.n {
                                            mean = meanVal
                                        }
                                    case "min":
                                        if let minVal = value2.n {
                                            min = minVal
                                        }
                                    case "questions":
                                        if let quest = value2.l {
                                            for q in quest {
                                                if let qe = q.s {
                                                    questions.append(qe)
                                                }
                                            }
                                        }
                                    case "result_text":
                                        if let resultText = value2.m {
                                            if let intro = resultText["intro"]?.s {
                                                resultIntro = intro
                                            }
                                            
                                            if let sectionList = resultText["section_result"]?.l {
                                                for section in sectionList {
                                                    if let s = section.m {
                                                        if let range = s["range_end"]?.n, let text = s["text"]?.s {
                                                            resultSection.append([range: text])
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    case "standard_deviation":
                                        if let deviation = value2.n {
                                            standard_deviation = deviation
                                        }
                                    case "description":
                                        if let desc = value2.s {
                                            task_description = desc
                                        }
                                    case "infographic_title":
                                        if let infoTitle = value2.s {
                                            info_title = infoTitle
                                        }
                                    case "infographic_image":
                                        if let img = value2.s {
                                            info_image = img
                                        }
                                    case "video":
                                        if let vid = value2.s {
                                            goal_video = vid
                                        }
                                    case "related_videos":
                                        if let vid = value2.l {
                                            for v in vid {
                                                if let vd = v.s {
                                                    goal_related_video.append(vd)
                                                }
                                            }
                                        }
                                    default: break
                                    }
                                }
                                
                                taskDict[key] = UserTask(taskCategory: task_category, taskTitle: task_title, taskType: task_type, taskDuration: task_duration, items: itemsList, videoUrl: videoUrl, answers: answers, graphImage: graphImage, max: max, mean: mean, min: min, questions: questions, resultIntro: resultIntro, resultSection: resultSection, standardDeviation: standard_deviation, taskDescription: task_description, infoTitle: info_title, infoImage: info_image, video: goal_video, relatedVideos: goal_related_video)
                                
                                //                                print("taskDict[key] ✅ \(key): \(taskDict[key])#")
                            }
                        }
                    }
                    //                    print("x ✅ \(x)")
                    dict[x] = UserContent(contentCategory: content_category, contentDay: content_day, tasks: taskDict)
                    
                    requestCount += 1
                    
                    if requestCount == (endTaskNo - startTaskNo + 1) {
                        
                        let tasksTuples = dict.sorted(by: { (a, b) -> Bool in
                            a.key < b.key
                        })
                        
                        
                        
                        // save available tasks to UserDefaults
                        UserDefaults.standard.set(nil, forKey: UD_AVAILABLE_TASKS)
                        let data = NSKeyedArchiver.archivedData(withRootObject: dict)
                        UserDefaults.standard.set(data, forKey: UD_AVAILABLE_TASKS)
                        UserDefaults.standard.synchronize()
                        
                        completion(tasksTuples)
                    }
                }
            }
        }
    }
    
    
    
//    func queryUserAnalytics(completion:@escaping (UserAnalytic)->()) {
//        
//        guard let uid = KeychainSwift().get(KC_USER_UID) else {
//            print("*** ❌ queryUserAnalytics : uid is nil ***")
//            return
//        }
//        
//        let dynamoDB = AWSDynamoDB(forKey: "ledaDB")
//        
//        let request = AWSDynamoDBQueryInput()
//        let cond = AWSDynamoDBCondition()
//        
//        let attrVal = AWSDynamoDBAttributeValue()
//        attrVal?.s = uid
//        cond?.attributeValueList = [attrVal!]
//        cond?.comparisonOperator = .EQ
//        request?.tableName = TABLE_NAME_USER_ANALYTICS
//        request?.keyConditions = ["userId": cond!]
//        
//        request?.projectionExpression = "userId,tasks_completed_count,days_in_row_used,tasks_completed"
//        
//        dynamoDB.query(request!) { (output: AWSDynamoDBQueryOutput?, error: Error?) in
//            if let err = error {
//                print("*** queryUserAnalytics ❌ *** : \(err.localizedDescription)")
//            } else {
//                print("*** queryUserAnalytics ✅ ***")
//                
//                if let outputArr = output?.items {
//                    
//                    var days = "0", tasks = "0", resilience = "0", negotiation = "0", growth = "0"
//                    
//                    for item in outputArr {
//                        
//                        if let daysInRow = item["days_in_row_used"]?.n {
//                            print("*** queryUserAnalytics : daysInRow ✅ ***: \(daysInRow)")
//                            KeychainSwift().set(daysInRow, forKey: KC_ANALYTICS_DAYS_IN_ROW)
//                            days = daysInRow
//                        }
//                        
//                        if let tasksCompleted = item["tasks_completed"]?.n {
//                            print("*** queryUserAnalytics : tasksCompleted ✅ ***: \(tasksCompleted)")
//                            KeychainSwift().set(tasksCompleted, forKey: KC_ANALYTICS_TASKS_COMPLETED)
//                            tasks = tasksCompleted
//                        }
//                        
//                        if let tasksCompletedCount = item["tasks_completed_count"]?.m {
//                            if let resilienceCount = tasksCompletedCount["resilience"]?.n {
//                                print("*** queryUserAnalytics : resilienceCount ✅ ***: \(resilienceCount)")
//                                KeychainSwift().set(resilienceCount, forKey: KC_ANALYTICS_RESILIENCE_COMPLETED)
//                                resilience = resilienceCount
//                            }
//                            
//                            if let negotiationsCount = tasksCompletedCount["negotiations"]?.n {
//                                print("*** queryUserAnalytics : negotiationsCount ✅ ***: \(negotiationsCount)")
//                                KeychainSwift().set(negotiationsCount, forKey: KC_ANALYTICS_NEGOTIATION_COMPLETED)
//                                negotiation = negotiationsCount
//                            }
//                            
//                            if let growthMindsetCount = tasksCompletedCount["growth_mindset"]?.n {
//                                print("*** queryUserAnalytics : growthMindsetCount ✅ ***: \(growthMindsetCount)")
//                                KeychainSwift().set(growthMindsetCount, forKey: KC_ANALYTICS_MINDSET_COMPLETED)
//                                growth = growthMindsetCount
//                            }
//                            
//                            if let empathyCount = tasksCompletedCount["empathy"]?.n {
//                                print("*** queryUserAnalytics : empathyCount ✅ ***: \(empathyCount)")
//                                KeychainSwift().set(empathyCount, forKey: KC_ANALYTICS_EMPATHY_COMPLETED)
//                            }
//                        }
//                    }
//                    
//                    if !(days.isEmpty && tasks.isEmpty && resilience.isEmpty && negotiation.isEmpty && growth.isEmpty) {
//                        
//                        let analytics = UserAnalytic(daysInARow: days, tasksCompleted: tasks, resilienceTasksCompleted: resilience, negotiationTasksCompleted: negotiation, growthMindsetTasksCompleted: growth)
//                        
//                        // save UserAnalytics to UserDefaults
//                        let encodeData = NSKeyedArchiver.archivedData(withRootObject: analytics)
//                        let defaults = UserDefaults.standard
//                        defaults.set(encodeData, forKey: UD_USER_ANALYTICS)
//                        defaults.synchronize()
//                        
//                        completion(analytics)
//                    } else {
//                        print("*** ❌ failed to get data from queryUserAnalytics ***")
//                    }
//                }
//            }
//        }
//    }
    
    
    func queryFromUserTools(completion: @escaping (UserTools)->()) {
        
        guard let uid = KeychainSwift().get(KC_USER_UID) else {
            print("*** ❌ uid is nil ***")
            return
        }
        
        let dynamoDB = AWSDynamoDB(forKey: "ledaDB")
        
        let request = AWSDynamoDBQueryInput()
        let cond = AWSDynamoDBCondition()
        let attrVal = AWSDynamoDBAttributeValue()
        attrVal?.s = uid
        cond?.attributeValueList = [attrVal!]
        cond?.comparisonOperator = .EQ
        request?.tableName = TABLE_NAME_USER_TOOLS
        request?.keyConditions = ["userId": cond!]
        
        request?.projectionExpression = "userId,breathing_unlocked,making_meaning_unlocked,complex_emotions_unlocked"
        
        dynamoDB.query(request!) { (output: AWSDynamoDBQueryOutput?, error: Error?) in
            if let err = error {
                print("*** ❌ queryFromUserTools ***: \(err.localizedDescription)")
            } else {
                print("*** ✅ queryFromUserTools *** :\(output)")
                
                if let outputArr = output?.items {
                    
                    for item in outputArr {
                        
                        if let makingMeans = item["making_meaning_unlocked"]?.boolean, let breathing = item["breathing_unlocked"]?.boolean, let complexEmotions = item["complex_emotions_unlocked"]?.boolean {
                            
                            let tools = UserTools(isMakingMeaningUnlocked: makingMeans.boolValue, isComplexEmotionsUnlocked: complexEmotions.boolValue, isBreathingUnlocked: breathing.boolValue)
                            
                            // save UserTools to UserDefaults
                            let encodeData = NSKeyedArchiver.archivedData(withRootObject: tools)
                            let ud = UserDefaults.standard
                            ud.set(encodeData, forKey: UD_USER_TOOLS)
                            ud.synchronize()
                            
                            KeychainSwift().set(makingMeans.boolValue, forKey: KC_TOOLS_MEANING_UNLOCKED)
                            KeychainSwift().set(breathing.boolValue, forKey: KC_TOOLS_BREATHING_UNLOCKED)
                            KeychainSwift().set(complexEmotions.boolValue, forKey: KC_TOOLS_EMOTION_UNLOCKED)
                            
                            
                            completion(tools)
                        }
                    }
                }
            }
        }
    }
    
    /*
    // testing
    
    func putUserTask(forContentDay dayNo: Int, forTask taskNo: [Int], completion:@escaping ()->()) {
        
        guard let uid = KeychainSwift().get(KC_USER_UID) else {
            print("*** ❌ uid is nil ***")
            return
        }
        
        let dynamoDB = AWSDynamoDB(forKey: "ledaDB")
        let request = AWSDynamoDBPutItemInput()
        request?.tableName = TABLE_NAME_USER_TASKS
        
        // "userId"
        let vUserId = AWSDynamoDBAttributeValue()
        vUserId?.s = uid
        
        // task_day
        let vTaskDay = AWSDynamoDBAttributeValue()
        vTaskDay?.n = "\(dayNo)"
        
        // "is_checked_off"
        let vIsCheckedOff = AWSDynamoDBAttributeValue()
        vIsCheckedOff?.boolean = NSNumber(booleanLiteral: true)
        
        // "is_completed"
        let vIsCompleted = AWSDynamoDBAttributeValue()
        vIsCompleted?.boolean = NSNumber(booleanLiteral: true)
        
        // "tasks"
        let vTasks = AWSDynamoDBAttributeValue()
        
        let vIsComplete1Dict = AWSDynamoDBAttributeValue()
        let vIsComplete2Dict = AWSDynamoDBAttributeValue()
        let vIsComplete3Dict = AWSDynamoDBAttributeValue()
        
        let vIsComplete1 = AWSDynamoDBAttributeValue()
        let vIsComplete2 = AWSDynamoDBAttributeValue()
        let vIsComplete3 = AWSDynamoDBAttributeValue()
        
        vIsComplete1?.boolean = NSNumber(booleanLiteral: true)
        vIsComplete2?.boolean = NSNumber(booleanLiteral: true)
        vIsComplete3?.boolean = NSNumber(booleanLiteral: true)
        
        vIsComplete1Dict?.m = ["is_complete": vIsComplete1!]
        vIsComplete2Dict?.m = ["is_complete": vIsComplete2!]
        vIsComplete3Dict?.m = ["is_complete": vIsComplete3!]
        
        vTasks?.m = ["day\(dayNo)_task1": vIsComplete1Dict!, "day\(dayNo)_task2": vIsComplete2Dict!, "day\(dayNo)_task3": vIsComplete3Dict!]
        
        
        
        request?.item = ["userId" : vUserId!, "task_day":vTaskDay!, "is_completed" : vIsCompleted!, "is_checked_off" : vIsCheckedOff!, "tasks" : vTasks!]
        
        dynamoDB.putItem(request!) { (output: AWSDynamoDBPutItemOutput?, error: Error?) in
            if let err = error {
                print("*** putUserTaskForDay\(dayNo) ❌ *** : \(err.localizedDescription)")
                
            } else {
                print("*** putUserTaskForDay\(dayNo) ✅ ***")
                completion()
            }
        }
    }
    */
    
    // testing
    
    func putUserTaskResult(userTaskResult: UserTaskResult) {
        
        guard let uid = KeychainSwift().get(KC_USER_UID) else {
            print("*** ❌ uid is nil ***")
            return
        }
        
        
        let dynamoDB = AWSDynamoDB(forKey: "ledaDB")
        let request = AWSDynamoDBPutItemInput()
        request?.tableName = TABLE_NAME_USER_TASKS
        
        // userId
        let vUserId = AWSDynamoDBAttributeValue()
        vUserId?.s = uid
        
        // task_Day
        let vContentDay = AWSDynamoDBAttributeValue()
        vContentDay?.n = "\(userTaskResult.taskDay)"
        
        // "is_checked_off"
        let vIsCheckedOff = AWSDynamoDBAttributeValue()
        vIsCheckedOff?.boolean = NSNumber(booleanLiteral: userTaskResult.isCheckedOff)
        
        // "is_completed"
        let vIsCompleted = AWSDynamoDBAttributeValue()
        vIsCompleted?.boolean = NSNumber(booleanLiteral: userTaskResult.isCompleted)
        
        
        // tasks
        let vTasks = AWSDynamoDBAttributeValue()
        var tempDict = [String: AWSDynamoDBAttributeValue]()
        
        for userTask in userTaskResult.tasks {
            
            let vTaskDict = AWSDynamoDBAttributeValue()
            let dayTaskResult = userTask.value
            let taskType = dayTaskResult.type
            
            let vTaskType = AWSDynamoDBAttributeValue()
            vTaskType?.s = taskType
            
            let vIsCompleteResult = AWSDynamoDBAttributeValue()
            vIsCompleteResult?.boolean = NSNumber(booleanLiteral: dayTaskResult.isComplete)
            
            if taskType == TaskType.Video.rawValue {
                vTaskDict?.m = ["type":vTaskType!, "is_complete":vIsCompleteResult!]
                
                if !dayTaskResult.adjective.isEmpty && !dayTaskResult.rating.isEmpty {
                    let vAdj = AWSDynamoDBAttributeValue()
                    vAdj?.s = dayTaskResult.adjective
                    
                    let vRating = AWSDynamoDBAttributeValue()
                    vRating?.n = dayTaskResult.rating
                    
                    vTaskDict?.m = ["type":vTaskType!, "is_complete":vIsCompleteResult!, "adjective": vAdj!, "rating": vRating!]
                }
                
            } else if taskType == TaskType.Quiz.rawValue {
                
                let vResult = AWSDynamoDBAttributeValue()
                vResult?.n = dayTaskResult.result
                
                let vDateComplete = AWSDynamoDBAttributeValue()
                vDateComplete?.n = dayTaskResult.dateComplete
                
                vTaskDict?.m = ["type":vTaskType!, "is_complete":vIsCompleteResult!, "result": vResult!, "date_complete": vDateComplete!]
                
                if dayTaskResult.answers.count > 0 {
                    let vAnswerList = AWSDynamoDBAttributeValue()
                    var answerListArr = [AWSDynamoDBAttributeValue]()
                    for answer in dayTaskResult.answers {
                        let vAnswer = AWSDynamoDBAttributeValue()
                        vAnswer?.n = answer
                        answerListArr.append(vAnswer!)
                    }
                    vAnswerList?.l = answerListArr
                    vTaskDict?.m = ["type":vTaskType!, "is_complete":vIsCompleteResult!, "result": vResult!, "date_complete": vDateComplete!, "answers": vAnswerList!]
                }
                
            } else if taskType == TaskType.Checkoff.rawValue {
                vTaskDict?.m = ["type":vTaskType!, "is_complete":vIsCompleteResult!]
                
                if dayTaskResult.items.count > 0 {
                    let vItemList = AWSDynamoDBAttributeValue()
                    var itemListArr = [AWSDynamoDBAttributeValue]()
                    for item in dayTaskResult.items {
                        let vItem = AWSDynamoDBAttributeValue()
                        vItem?.boolean = NSNumber(booleanLiteral: item)
                        itemListArr.append(vItem!)
                    }
                    vItemList?.l = itemListArr
                    vTaskDict?.m = ["type":vTaskType!, "is_complete":vIsCompleteResult!, "items": vItemList!]
                }
                
            } else {
                vTaskDict?.m = ["type":vTaskType!, "is_complete":vIsCompleteResult!]
            }
            
            tempDict[userTask.key] = vTaskDict
        }
        
        vTasks?.m = tempDict
        
        request?.item = ["userId" : vUserId!, "task_day": vContentDay!, "is_completed": vIsCompleted!, "is_checked_off" : vIsCheckedOff!, "tasks": vTasks!]
        
        
        
        dynamoDB.putItem(request!) { (output: AWSDynamoDBPutItemOutput?, error: Error?) in
            if let err = error {
                print("*** putDBItem ❌ *** : \(err.localizedDescription)")
                
            } else {
                print("*** putDBItem ✅ ***")
                
                // get new data after 5 seconds when new item is pushed in background
//                let deadlineTime = DispatchTime.now() + .seconds(5)
//                DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
//                    print("test")
//                    
//                    AWSClientManager.shared.registerDynamoDB {
//                        AWSClientManager.shared.queryUserAnalytics(completion: { (analytics: UserAnalytic) in
//                            
//                        })
//                    }
//                }
                
            }
        }
    }
    
    func getUserTask(forTaskday dayNo: Int, completion: @escaping ()->()) {
        
        guard let uid = KeychainSwift().get(KC_USER_UID) else {
            print("*** ❌ getUserTask : uid is nil ***")
            return
        }
        
        let dynamoDB = AWSDynamoDB(forKey: "ledaDB")
        let request = AWSDynamoDBGetItemInput()
        request?.tableName = TABLE_NAME_USER_TASKS
        
        let attrVal = AWSDynamoDBAttributeValue()
        attrVal?.s = uid
        
        let attValue = AWSDynamoDBAttributeValue()
        attValue?.n = "\(dayNo)"
        
        request?.key = ["userId": attrVal!, "task_day": attValue!]
        request?.projectionExpression = "userId,task_day,tasks,is_completed,is_checked_off"
        
        dynamoDB.getItem(request!) { (output, error) in
            
            // when the request fails, it returns nothing
            
            if output?.item == nil {
                print(" ❌ getUserTaks NOT exists ")
                // TODO: initialize a new empty task result?
                print(" ❗️ TODO: initialize a new empty task result? ")
                UserData.shared.userTaskResult = UserTaskResult(isCheckedOff: false, isCompleted: false, taskDay: dayNo, tasks: [:])
                
            } else {
                
                if let err = error {
                    print("*** getUserTask ❌ *** :\(err.localizedDescription)")
                } else {
                    print("*** getUserTaks ✅ *** ")
                    
                    if let itemDict = output?.item {
                        
                        var isCompleted = false, isCheckedOff = false
                        var tasksDictonary = [String : DayTaskResult]()
                        
                        if let obj = itemDict["is_completed"]?.boolean {
                            isCompleted = obj.boolValue
                        }
                        
                        if let obj = itemDict["is_checked_off"]?.boolean {
                            isCheckedOff = obj.boolValue
                        }
                        
                        if let tasks = itemDict["tasks"]?.m {
                            
                            for task in tasks {
                                
                                var taskType = "", ratingResult = "", rating = "", quizResult = ""
                                var isComplete = false
                                var answerResultList = [String]()
                                var dateComplete = ""
                                var itemsBool = [Bool]()
                                
                                if let taskDict = task.value.m {
                                    
                                    for t in taskDict {
                                        
                                        switch t.key {
                                        case "type":
                                            
                                            if let item = t.value.s {
                                                taskType = item
                                            }
                                        case "adjective":
                                            if let item = t.value.s {
                                                ratingResult = item
                                            }
                                        case "is_complete":
                                            if let item = t.value.boolean {
                                                isComplete = item.boolValue
                                            }
                                        case "rating":
                                            if let item = t.value.n {
                                                rating = item
                                            }
                                        case "answers":
                                            if let item = t.value.l {
                                                for object in item {
                                                    if let obj = object.n {
                                                        answerResultList.append(obj)
                                                    }
                                                }
                                            }
                                        case "result":
                                            if let item = t.value.n {
                                                quizResult = item
                                            }
                                        case "date_complete":
                                            if let item = t.value.n {
                                                dateComplete = item
                                            }
                                        case "items":
                                            if let item = t.value.l {
                                                for object in item {
                                                    if let obj = object.boolean {
                                                        itemsBool.append(obj.boolValue)
                                                    }
                                                }
                                            }
                                        default: break
                                        }
                                    }
                                }
                                
                                tasksDictonary[task.key] = DayTaskResult(type: taskType, isComplete: isComplete, adjective: ratingResult, rating: rating, answers: answerResultList, result: quizResult, dateComplete: dateComplete, items: itemsBool)
                            }
                        }
                        
                        
                        // save to singleton
                        
                        UserData.shared.userTaskResult = UserTaskResult(isCheckedOff: isCheckedOff, isCompleted: isCompleted, taskDay: dayNo, tasks: tasksDictonary)
                        
                        print("Downloaded User Task: \(UserData.shared.userTaskResult)")
                        
                        completion()
                        
                    }
                }
            }
        }
    }
    
    func queryTestResults(completion: @escaping ()->()) {
        
        guard let uid = KeychainSwift().get(KC_USER_UID) else { return }
        
        let dynamoDB = AWSDynamoDB(forKey: "ledaDB")
        
        let request = AWSDynamoDBQueryInput()
        let cond = AWSDynamoDBCondition()
        
        let attrVal = AWSDynamoDBAttributeValue()
        attrVal?.s = uid
        cond?.attributeValueList = [attrVal!]
        cond?.comparisonOperator = .EQ
        request?.tableName = TABLE_NAME_USER_TASKS
        
        
        request?.keyConditions = ["userId": cond!]
        
        request?.projectionExpression = "userId,task_day,tasks,is_completed,is_checked_off"
        
        dynamoDB.query(request!) { (output: AWSDynamoDBQueryOutput?, error: Error?) in
            if let err = error {
                print("*** queryUserTask ❌ *** : \(err.localizedDescription)")
            } else {
                
                UserData.shared.userTestResults = [TestResults]()
                
                
                if let outputItems = output?.items {
                    
                    for item in outputItems {
                        
                        for (kItem,vItem) in item {
                            
                            
                            if kItem == "tasks" {
                                
                                if let tasks = vItem.m {
                                    
                                    for (kTasks, vTasks) in tasks {
                                        
                                        if let taskMap = vTasks.m {
                                            
                                            for (kTaskMap,vTaskMap) in taskMap {
                                                
                                                if kTaskMap == "date_complete" {
                                                    
                                                    var dateStr = ""
                                                    var scoreStr = ""
                                                    
                                                    if let dateComplete = vTaskMap.n {
                                                        dateStr = dateComplete
                                                        
                                                    }
                                                    
                                                    
                                                    
                                                    print("tasks ✅ \(tasks[kTasks])")
                                                    
                                                    
                                                    if let result = tasks[kTasks]?.m {
                                                        
                                                        for (kResult,vResult) in result {
                                                            
                                                            
                                                            if kResult == "result" {
                                                                
                                                                if let score = vResult.n {
                                                                    scoreStr = score
                                                                }
                                                            }
                                                            
                                                        }
                                                        
                                                        
                                                    }
                                                    
                                                    UserData.shared.userTestResults.append(TestResults(taskNo: kTasks, dateComplete: dateStr, score: scoreStr))
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                    }
                    
                    print("UserData.shared.userTestResults ❗️ \(UserData.shared.userTestResults)")
                    
                    completion()
                }
                
            }
            
        }
    }
    
    /*
    func updateUserTask(forContentDay contentDay: Int) {
        

        guard let uid = KeychainSwift().get(KC_USER_UID) else {
            print("*** ❌ uid is nil ***")
            return
        }
        
        
        let dynamoDB = AWSDynamoDB(forKey: "ledaDB")
        let request = AWSDynamoDBUpdateItemInput()
        request?.tableName = TABLE_NAME_USER_TASKS
        
        
        
        let idValue = AWSDynamoDBAttributeValue()
        idValue?.s = uid
        
        let taskDay = AWSDynamoDBAttributeValue()
        taskDay?.n = "\(contentDay)"
        
        request?.key = ["userId": idValue!, "task_day": taskDay!]
        
        let value2 = AWSDynamoDBAttributeValue()
        value2?.boolean = NSNumber(booleanLiteral: true)
        
        let value3 = AWSDynamoDBAttributeValue()
        value3?.m = ["is_complete": value2!]
        
        let value1 = AWSDynamoDBAttributeValue()
        value1?.m = ["day\(contentDay)_task1": value3!]
        
        request?.updateExpression = "ADD tasks :tasks"
        request?.expressionAttributeValues = [":tasks": value1!]
        
        
        dynamoDB.updateItem(request!) { (output: AWSDynamoDBUpdateItemOutput?, error: Error?) in
            
            if let err = error {
                print("*** updateItem ❌ *** : \(err.localizedDescription)")
            } else {
                print("*** updateItem ✅ ***")
            }
            
        }
    }
    */
    
    /*
     func queryFromTaskContent(completion: @escaping ()->()) {
     
     let dynamoDB = AWSDynamoDB(forKey: "ledaDB")
     
     let request = AWSDynamoDBQueryInput()
     let cond = AWSDynamoDBCondition()
     
     let attrVal = AWSDynamoDBAttributeValue()
     attrVal?.n = "23"
     cond?.attributeValueList = [attrVal!]
     cond?.comparisonOperator = .EQ
     request?.tableName = "leda-mobilehub-1430045983-task_content"
     request?.keyConditions = ["content_day": cond!]
     
     request?.projectionExpression = "content_day,content_category,tasks"
     
     dynamoDB.query(request!) { (output: AWSDynamoDBQueryOutput?, error: Error?) in
     if let err = error {
     print("*** ❌ queryFromUserTools ***: \(err.localizedDescription)")
     } else {
     print("*** ✅ queryFromUserTools *** :\(output)")
     
     if let outputArr = output?.items {
     
     for item in outputArr {
     
     if let makingMeans = item["making_meaning_unlocked"]?.boolean, let breathing = item["breathing_unlocked"]?.boolean, let complexEmotions = item["complex_emotions_unlocked"]?.boolean {
     
     print("*** makingMeans *** : \(makingMeans.boolValue)")
     
     print("*** breathing *** : \(breathing)")
     print("*** complexEmotions *** : \(complexEmotions)")
     }
     }
     }
     completion()
     }
     }
     }
     */
    
    /*
    func deleteItemFromDB(ofContentDay number: Int, completion:@escaping ()->()) {
        
        //        guard let uid = UserDefaults.standard.object(forKey: UD_USER_UID) as? String else {
        //            print("*** ❌ uid is nil ***")
        //            return
        //        }
        
        guard let uid = KeychainSwift().get(KC_USER_UID) else {
            print("*** ❌ uid is nil ***")
            return
        }
        
        
        let dynamoDB = AWSDynamoDB(forKey: "ledaDB")
        let request = AWSDynamoDBPutItemInput()
        request?.tableName = TABLE_NAME_USER_TASKS
        
        let vUserId = AWSDynamoDBAttributeValue()
        vUserId?.s = uid
        
        // taskDay
        let vTaskDay = AWSDynamoDBAttributeValue()
        vTaskDay?.n = "\(number)"
        
        let vIsCheckedOff = AWSDynamoDBAttributeValue()
        vIsCheckedOff?.boolean = NSNumber(booleanLiteral: false)
        
        let vIsCompleted = AWSDynamoDBAttributeValue()
        vIsCompleted?.boolean = NSNumber(booleanLiteral: false)
        
        let vTasks = AWSDynamoDBAttributeValue()
        
        vTasks?.m = [:]
        
        request?.item = ["userId" : vUserId!, "task_day":vTaskDay!, "is_completed" : vIsCompleted!, "is_checked_off" : vIsCheckedOff!, "tasks" : vTasks!]
        
        dynamoDB.putItem(request!) { (output: AWSDynamoDBPutItemOutput?, error: Error?) in
            if let err = error {
                print("*** deleteItemFromDB ❌ *** : \(err.localizedDescription)")
                
            } else {
                print("*** deleteItemFromDB ✅ ***")
                completion()
            }
        }
    }
    */
    
    func isDbRegisterd() -> Bool {
        if let _ = AWSDynamoDB(forKey: "ledaDB").configuration.userAgent {
            print("ledaDB registered")
            return true
        } else {
            print("ledaDB NOT registered")
            return false
        }
    }
    
}
