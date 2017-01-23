//
//  Helper.swift
//  LEDA
//
//  Created by Mengying Feng on 7/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import Foundation
import AWSCore
import AWSCognitoIdentityProvider
import JWTDecode

class Helper {
    
    static let shared = Helper()
    
    var videoThumbnail: UIImage?
    
    var areThreeCurrentTasksCompleted: Bool = false
    
    var isLoggedIn = false
    
    func isTokenValid() -> Bool {
        
        if let sessionToken = KeychainSwift().get(KC_SESSION_TOKEN) {
            
            do {
                let jwt = try decode(jwt: sessionToken)
                print("token exp bool ❗️ \(jwt.expired)")
                
                if jwt.expired {
                    print("if expired, signin user pool")
                    return false
                    
                } else {
                    print("if not expired, display vc")
                    return true
                }
                
            } catch {
                print("err in decode jwt ❌")
                return false
            }
        } else {
            // if not exists, signin user pool
            return false
        }
    }
    
    
    func checkCredentialDetail() -> (String, String)? {
        if let email = KeychainSwift().get(KC_USER_EMAIL), let pw = KeychainSwift().get(KC_USER_PASSWORD) {
            print("checkCredentialDetail ❗️ \(email) \(pw)")
            return (email, pw)
        }
        return nil
    }
    
    
    // save current day as time interval to user pool
    func getCurrentDateStr() -> String {
        return "\(Int(NSDate().timeIntervalSince1970))"
    }
    
    func setCurrentSavedDate(str: String?) {
        UserDefaults.standard.set(str == nil ? nil : str!, forKey: UD_CURRENT_SAVED_DATE)
    }
    
    func getCurrentSavedDate() -> String? {
        return UserDefaults.standard.string(forKey: UD_CURRENT_SAVED_DATE)
    }
    
    // compare two dates and return the difference (start of the day is 12:00AM)
    func getNumOfDaysBetweenTwoDates(date1Str one: String, date2Str two: String) -> Int? {
        guard let strOne = Double(one), let strTwo = Double(two) else {
            print("*** ❌ getNumOfDaysBetweenTwoDates ***")
            return nil
        }
        
        let date1 = Date(timeIntervalSince1970: strOne)
        let date2 = Date(timeIntervalSince1970: strTwo)
        
        print("*** ✅ date1 : date2 ***: \(date1) : \(date2)")
        print("*** ✅ calculateTwoDates ***: \(calculateTwoDates(date1: date1, date2: date2))")
        
        return calculateTwoDates(date1: date1, date2: date2)
    }
    
    func calculateTwoDates(date1: Date, date2: Date) -> Int? {
        
        let cal = Calendar.current
        let date1StartDate = cal.startOfDay(for: date1)
        let date2StartDate = cal.startOfDay(for: date2)
        
        if let numOfDaysBetween = cal.dateComponents([.day], from: date2StartDate, to: date1StartDate).day {
            print("*** ✅ getNumOfDaysBetweenTwoDates *** : \(numOfDaysBetween)")
            return abs(numOfDaysBetween)
        } else {
            print("*** ❌ getNumOfDaysBetweenTwoDates ***")
            return nil
        }
    }
    
    func isSameDay() -> Bool? {
        
        if let currentSavedDate = getCurrentSavedDate() {
            if let daysDiff = getNumOfDaysBetweenTwoDates(date1Str: currentSavedDate, date2Str: getCurrentDateStr()) {
                if daysDiff == 0 {
                    return true
                } else {
                    return false
                }
            }
        }
        return nil
    }
    
    
    // MARK: convert weekday number to string
    func weekdayConverter(weekday: Int) -> String {
        switch weekday {
        case 1: return "Sunday"
        case 2: return "Monday"
        case 3: return "Tuesday"
        case 4: return "Wednesday"
        case 5: return "Thursday"
        case 6: return "Friday"
        case 7: return "Saturday"
        default: return ""
        }
    }
    
    func getWeekdayArr() -> [Int]? {
        
        if let currentWeedayInt = getCurrentDate()?.weekdayInt {
            var arr = [Int]()
            var x = currentWeedayInt
            
            while  x <= 7 {
                arr.append(x)
                
                x += 1
                
                if x > 7 {
                    x = 1
                }
                
                if arr.count == 7 {
                    print("❗️weekdayArr: \(arr)")
                    
                    let ud = UserDefaults.standard
                    ud.set(arr, forKey: UD_USER_DATA_WEEKDAYS_ARRAY)
                    
                    
                    
                    return arr
                }
            }
            
        }
        return nil
        
    }
    
    func getTasksArr(daysInRow: Int) -> [Int]? {
        
        if let weekdayArr = Helper.shared.getWeekdayArr() {
            var taskArr = [Int]()
            var rand = daysInRow
            var xCount = 0
            
            for x in weekdayArr {
                
                if xCount == 0 {
                    rand += 0
                } else if x != 7 && x != 1 {
                    rand += 1
                } else {
                    rand += 0
                }
                taskArr.append(rand)
                xCount += 1
                
            }
            
            let ud = UserDefaults.standard
            ud.set(taskArr, forKey: UD_USER_DATA_TASKS_ARRAY)
            
            
            print("❗️tasksArr: \(taskArr)")
            
            return taskArr
        }
        return nil
    }
    
    
    // MARK: get current date details
    func getCurrentDate() -> (weekdayInt: Int, weekdayStr: String, dayStr: String)? {
        
        let component = NSCalendar.current.dateComponents([.weekday, .day], from: NSDate() as Date)
        
        if let weekday = component.weekday, let day = component.day {
            
            print("getCurrentDate ❗️ weekday: \(weekday), day: \(day)")
            
            return (weekday, weekdayConverter(weekday: weekday), String(day))
        }
        
        return nil
    }
    
    func updateCurrentDateStr() {
        
        // update current date and save to keychain
        
        let currentDateStr = Helper.shared.getCurrentDateStr()
        
        if let str = KeychainSwift().get(KC_CURRENT_DATE_STR) {
            
            if let days = Helper.shared.getNumOfDaysBetweenTwoDates(date1Str: str, date2Str: currentDateStr), days > 0 {
                
                // not same day
                print("not the same day ❗️")
                KeychainSwift().set(currentDateStr, forKey: KC_CURRENT_DATE_STR)
                
            } else {
                
                // same day
                print("same day ❗️")
            }
            
            
        }
        
    }
    
    func getcurrentWeekdayArr() {
        
        if let wdInt = Helper.shared.getCurrentDate()?.weekdayInt {
            
            var weekdayArr = [Int]()
            
            var x = wdInt
            
            while x <= 7 {
                weekdayArr.append(x)
                
                x += 1
                
                if x > 7 {
                    x = 1
                }
                
                if weekdayArr.count == 7 {
                    break
                }
            }
            
            print("weekdayArr ❗️ \(weekdayArr)")
            
        }
        
    }
    
    func getNextDate() -> String? {
        
        let component = NSCalendar.current.dateComponents([.weekday], from: NSDate() as Date)
        
        if let weekday = component.weekday {
            
            return weekdayConverter(weekday: weekday+1)
        }
        
        return nil
        
    }
    
    // MARK: get the next available 7 days
    func getAvailableDays() -> [(key: Int, value: Int)] {
        
        var arrOfTuples = [(key: Int, value: Int)]()
        
        var count = 0
        var day = 0
        var weekday = 0
        
        if let currentDate = getCurrentDate() {
            
            day = Int(currentDate.dayStr)!
            weekday = Int(currentDate.weekdayInt)
            
            var dict = [Int:Int]()
            
            while count < 7 {
                
                //                if weekday != 7 && weekday != 1 {
                dict[day] = weekday
                count += 1
                //                }
                
                day += 1
                weekday += 1
                
                if weekday > 7 {
                    weekday = 1
                }
            }
            arrOfTuples = dict.sorted(by: { $0.0 < $1.0 })
        }
        
        return arrOfTuples
    }
    
    func getTypeIconImage(color: Int, type: String) -> UIImage {
        var iconArr = ["icoQuiz_blue", "icoGoal_blue", "icoWatch_blue", "icoQuiz_blue"]
        
        if color == 0 {
            iconArr = ["icoQuiz", "icoGoal", "VideoPlay", "icoQuiz"]
        }
        
        switch type {
        case TaskType.Video.rawValue:
            return UIImage(named: iconArr[2])!
        case TaskType.Quiz.rawValue:
            return UIImage(named: iconArr[0])!
        case TaskType.Checkoff.rawValue:
            return UIImage(named: iconArr[1])!
        case TaskType.Unknown.rawValue:
            return UIImage(named: iconArr[0])!
        default:
            return UIImage(named: iconArr[0])!
        }
    }
    
    func getAvailableTask(taskNo: Int) -> UserContent? {
        if let decoded = UserDefaults.standard.object(forKey: UD_AVAILABLE_TASKS) as? Data, let tasksDict = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [Int: UserContent] {
            
            for task in tasksDict {
                
                print("Helper : getAvailableTask ❗️ \(task.key) \(task.value)")
                
                if task.key == taskNo {
                    return task.value
                }
            }
        }
        return nil
    }
    
//    func getAvailableUnfinishedTask() -> Int {
//        if let decoded = UserDefaults.standard.object(forKey: UD_USER_ANALYTICS) as? Data, let analytics = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? UserAnalytic {
//            print("analytics ❗️ \(analytics.daysInARow) \(analytics.tasksCompleted)")
//            if let unfinishedTaskNo = Int(analytics.daysInARow) {
//                print("unfinishedTaskNo ❗️ \(unfinishedTaskNo)")
//                return unfinishedTaskNo
//            }
//        }
//        return -1
//    }
    
    func getCurrentTask(contentDay num: Int, task no: Int) -> UserTask? {
        print("getCurrentTask ❗️ contentDay \(num), task \(no)")
        if let decoded = UserDefaults.standard.object(forKey: UD_AVAILABLE_TASKS) as? Data, let dict = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [Int: UserContent] {
            
            let filtered = dict.filter { $0.key == num }
            
            let content = filtered[0].value
            
            for task in content.tasks {
                if task.key.contains("task\(no)") {
                    return task.value
                }
            }
        }
        return nil
    }
    

    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    func downloadImage(url: URL) {
        getDataFromUrl(url: url) { (data, response, error)  in
            guard let data = data, error == nil else { return }
            print(response?.suggestedFilename ?? url.lastPathComponent)
            print("Thumbnail Download Finished ✅")
            self.videoThumbnail = UIImage(data: data)
        }
    }
    
    //========================================
    // MARK: - Log Out
    //========================================
    func logoutCurrentUser() {
        // clear all the saved data of currentUser
        let ud = UserDefaults.standard
        ud.removeObject(forKey: UD_CURRENT_USER_INFO)
        ud.removeObject(forKey: UD_CURRENT_SAVED_DATE)
        ud.removeObject(forKey: UD_AVAILABLE_TASKS)
        ud.removeObject(forKey: UD_USER_KEEP_LOGGED_IN)
        ud.synchronize()
        
        let keychain = KeychainSwift()
        keychain.delete(KC_USER_EMAIL)
        keychain.delete(KC_USER_PASSWORD)
        keychain.delete(KC_USER_UID)
        
        keychain.delete(KC_SESSION_TOKEN)
        
        keychain.delete(KC_USER_FIRSTNAME)
        keychain.delete(KC_USER_LASTNAME)
        keychain.delete(KC_CUSTOM_START_DATE)
        
        keychain.delete(KC_ANALYTICS_TASKS_COMPLETED)
        keychain.delete(KC_ANALYTICS_MAX_DAYS_IN_ROW)
        keychain.delete(KC_ANALYTICS_CURRENT_DAYS_IN_ROW)
        keychain.delete(KC_ANALYTICS_RESILIENCE_COMPLETED)
        keychain.delete(KC_ANALYTICS_MINDSET_COMPLETED)
        keychain.delete(KC_ANALYTICS_EMPATHY_COMPLETED)
        keychain.delete(KC_ANALYTICS_NEGOTIATION_COMPLETED)
        
        keychain.delete(KC_TOOLS_MEANING_UNLOCKED)
        keychain.delete(KC_TOOLS_BREATHING_UNLOCKED)
        keychain.delete(KC_TOOLS_EMOTION_UNLOCKED)
        
        // sign out currentUser
        AWSCognitoIdentityUserPool(forKey: KEY_USER_POOL).currentUser()?.signOutAndClearLastKnownUser()
        AWSCognitoIdentityUserPool(forKey: KEY_USER_POOL).clearAll()
        
        Helper.shared.isLoggedIn = false
    }
    
    
    func formatTime(withDuration duration: String) -> String {
        
        return "\(Int(duration)!/60):\(Int(duration)!%60)"
    }
    
    func fetchAndDisplayCurrentUnfinishedUserTask() {
        
        
        
        
        /*
        if let daysInRow = KeychainSwift().get(KC_ANALYTICS_DAYS_IN_ROW) {
            
            let finishedTaskNo = Int(daysInRow)! - 1
            
            AWSClientManager.shared.getUserTask(forTaskday: finishedTaskNo, completion: { 
                if let taskResult = UserData.shared.userTaskResult {

                    if taskResult.isCompleted && taskResult.isCheckedOff {
                        
                        // check ++1 task exists
                        
                        // 1. check ++1 task exists: exists
                        // save ++1 to UserData.shared.userTaskResult
                        
                        
                        
                        // 1.1 have tasks been started: yes
                        // show today returning/resume
                        
                        
                        
                        // 1.2 have tasks been started: no
                        // display normal empty task

                        
                        
                        
                        
                        // 2. check ++1 task exists: NOT exist
                        // initialize new empty task result with daysInRow ++1 and save to UserData.shared.userTaskResult
                        
                        
                        
                        
                    } else {
                        
                        //task daysInRow not finished, show Today Returning
                     
                        // already saved task result, display it on DailyTaskVC
                        
                        
                    }
                    
                }
            })
            
        }
        
        */
        
        
        
    }
    
    
}
