//
//  Constants.swift
//  LEDA
//
//  Created by Mengying Feng on 10/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit

enum TaskCategory: String {
    case Resilience = "resilience"
    case GrowthMindset = "growth_mindset"
    case Negotiations = "negotiations"
    case Empathy = "empathy"
}

enum TaskType: String {
    case Video = "video"
    case Goal = "goal"
    case Quiz = "quiz"
    case Checkoff = "checkoff"
    case Unknown = "unknown"
}

enum ResultCategory: String {
    case StronglyNegative = "Strongly Negative"
    case Negative = "Negative"
    case Positive = "Positive"
    case StronglyPositive = "Stringly Positive"
}


let KEY_USER_POOL = "UserPool"

let IDENTYTY_PROVIDER_DOMAIN = "cognito-idp.us-east-1.amazonaws.com/\(COGNITO_USER_POOL_ID)"
let COGNITO_IDENTITY_POOL_ID = "us-east-1:414689c8-b614-46e8-b0c9-6516e459b5fa"
let COGNITO_USER_POOL_ID = "us-east-1_44OHDgyv1"
let COGNITO_CLIENT_ID = "9iqta48nj10fpvra447lbpsod"
let COGNITO_CLIENT_SECRET = "1plm10proabj3vctuqoqi4ca1fc3av5gv7fjcfdc3gfgr0sn74qv"

let COLOR_LIGHT_BLUE = UIColor(red: 44/255, green: 171/255, blue: 213/255, alpha: 1.0) // ✅
let COLOR_DARK_BLUE = UIColor(red: 3/255, green: 112/255, blue: 148/255, alpha: 1.0)
let COLOR_TASK_NUMBER_LIGHT = UIColor(red: 194/255, green: 231/255, blue: 237/255, alpha: 1.0)

let COLOR_BACKGROUND_LIGHT = UIColor(red: 219/255, green: 234/255, blue: 234/255, alpha: 1.0) // ✅
let COLOR_TEXT_DARK_GRAY = UIColor(red: 53/255, green: 50/255, blue: 51/255, alpha: 1.0) // ✅
let COLOR_CLOSED_CELL_BG = UIColor(red: 217/255, green: 229/255, blue: 234/255, alpha: 1.0)

// Responsive web
let COLOR_WEB_LIGHT_BLUE = UIColor(red: 100/255, green: 203/255, blue: 236/255, alpha: 1.0)

let TABLE_NAME_USER_TASKS = "leda-mobilehub-1430045983-user_tasks"
let TABLE_NAME_TASK_CONTENT = "leda-mobilehub-1430045983-task_content"
let TABLE_NAME_USER_ANALYTICS = "leda-mobilehub-1430045983-user_analytics"
let TABLE_NAME_USER_TOOLS = "leda-mobilehub-1430045983-user_tools"

let FONT_SIZE_ALERT_SMALL = CGFloat(16.0)
let FONT_SIZE_ALERT_BIG = CGFloat(22.0)

let CUSTOM_FONT_BOLD = "Gilroy-Bold"
let CUSTOM_FONT_MEDIUM = "Gilroy-Medium"
let CUSTOM_FONT_REGULAR = "Gilroy-Regular"

let USER_ATTRIBUTES_EMAIL = "email"
let USER_ATTRIBUTES_GIVEN_NAME = "given_name"
let USER_ATTRIBUTES_FAMILY_NAME = "family_name"
let USER_ATTRIBUTES_START_DATE = "custom:start_date"

let UD_CURRENT_USER_INFO = "currentUserInfo"

let UD_CURRENT_SAVED_DATE = "currentSavedDate"
let UD_AVAILABLE_TASKS = "availableTasks"

let UD_USER_ANALYTICS = "UserAnalytics"
let UD_USER_TOOLS = "UserTools"
let KC_USER_ANALYTICS = "keychain_userAnalytics"
let KC_USER_TOOLS = "keychain_userTools"


let UD_USER_DATA_WEEKDAYS_ARRAY = "userDataWeekdaysArray"
let UD_USER_DATA_TASKS_ARRAY = "userDataTasksArray"



//let UD_USER_UID = "currentUserUid"
let UD_USER_KEEP_LOGGED_IN = "currentUserKeepLoggedIn"

let KC_USER_PASSWORD = "keychain_user_password"
let KC_USER_UID = "keychain_user_uid"
let KC_USER_EMAIL = "email"
let KC_CUSTOM_START_DATE = "custom:start_time"
let KC_USER_GIVEN_NAME = "given_name"
let KC_USER_FAMILY_NAME = "family_name"

let KC_SESSION_TOKEN = "keychain_session_token"

let KC_ANALYTICS_TASKS_COMPLETED = "keychain_analytics_tasksCompleted"
let KC_ANALYTICS_MAX_DAYS_IN_ROW = "keychain_analytics_maxDaysInRow"
let KC_ANALYTICS_CURRENT_DAYS_IN_ROW = "keychain_analytics_currentDaysInRow"
let KC_ANALYTICS_RESILIENCE_COMPLETED = "keychain_analytics_resilienceCompleted"
let KC_ANALYTICS_MINDSET_COMPLETED = "keychain_analytics_mindsetCompleted"
let KC_ANALYTICS_EMPATHY_COMPLETED = "keychain_analytics_empathyCompleted"
let KC_ANALYTICS_NEGOTIATION_COMPLETED = "keychain_analytics_negotiationCompleted"

let KC_TOOLS_MEANING_UNLOCKED = "keychain_tools_meaning_unlocked"
let KC_TOOLS_BREATHING_UNLOCKED = "keychain_tools_breathing_unlocked"
let KC_TOOLS_EMOTION_UNLOCKED = "keychain_tools_emotion_unlocked"

let KC_CURRENT_DATE_STR = "keychain_currentDateStr"
let KC_PREVIOUS_DATE_STR = "keychain_previousDateStr"

let FIRST_RUN_KEY = "FirstRun"
let FIRST_RUN_VALUE = "1strun"

let ProExp_UserToolStatus = "userId,breathing_unlocked,complex_emotions_unlocked,making_meaning_unlocked"
let ProExp_UserAnalytics = "userId,current_days_in_row_used,max_days_in_row_used,tasks_completed,tasks_per_category_completed"
let ProExp_Tasks = "task_day,sort,task_duration_seconds,task_title,task_type,task_data,task_category,task_subcategory"
let ProExp_UserTaskStatus = "userId,task_day,is_completed,tasks"



extension String {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailText = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailText.evaluate(with: self)
    }
}
