//
//  DailyTasksViewController.swift
//  LEDA
//
//  Created by Mengying Feng on 5/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSDynamoDB
import JWTDecode
import SwiftGifOrigin

class DailyTasksViewController: UIViewController/*, UIPopoverPresentationControllerDelegate*/ {
    
    //========================================
    // MARK: - Properties
    //========================================
    
    var pool: AWSCognitoIdentityUserPool?
    var user: AWSCognitoIdentityUser?
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    
    
    let TITLE_HEIGHT = CGFloat(20.0)
    let DESCRIPTION_HEIGHT = CGFloat(24.0)
    let ICON_SIZE = 25
    let ICON_X = 20
    let ICON_Y = 10
    
    let pinchRec = UIPinchGestureRecognizer()
    
    var selectedTaskTuple: (Int, UserContent)?
    
    var tasksDictFromDB = [Int: UserContent]()
    var tasksTuples = [(key: Int, value: UserContent)]()
    
    var dailyTaskVC:DailyTasksViewController?
    
    var task1Finished = false
    var task2Finished = false
    var task3Finished = false
    
    var selectedTaskType = ""
    
    var gifImageNameArray = ["Coffee", "Music", "Park", "Reading"]
    
    var selectedVideoHashId = ""
    
    //    var timer = Timer()
    
    var passedSelectedIndex = -1
    
    //========================================
    // MARK: - Outlets
    //========================================
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var task1TitleLabel: UILabel!
    @IBOutlet weak var dayWeekdayNoLabel: UILabel!
    
    @IBOutlet weak var task1TypeTimeLabel: UILabel!
    @IBOutlet weak var task1ProgressView: UIProgressView!
    @IBOutlet weak var task2TypeTimeLabel: UILabel!
    @IBOutlet weak var task2ProgressView: UIProgressView!
    @IBOutlet weak var task3TypeTimeLabel: UILabel!
    @IBOutlet weak var task3ProgressView: UIProgressView!
    
    @IBOutlet weak var dayCompleteContainerView: UIView!
    @IBOutlet weak var weekendContainerView: UIView!
    
    @IBOutlet weak var showMeAgainButton: UIButton!
    
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var menuButton: UIButton!
    
    
    @IBOutlet weak var playButton: UIButton!
    
//    @IBOutlet weak var loadingDotLabel: UILabel!
    //========================================
    // MARK: - View Lifecycles
    //========================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pinchRec.addTarget(self, action: #selector(pinchedUIView))
        self.view.addGestureRecognizer(pinchRec)
        
        showMeAgainButton.titleLabel?.numberOfLines = 1
        showMeAgainButton.titleLabel?.adjustsFontSizeToFitWidth = true
        showMeAgainButton.titleLabel?.lineBreakMode = NSLineBreakMode.byClipping
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentAccountVC), name: NSNotification.Name("NC_SideMenuToAccount"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentHelpVC), name: NSNotification.Name("NC_SideMenuToHelp"), object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentWeekeviewVC), name: NSNotification.Name("NC_SideMenuToWeekview"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentLoginVC), name: NSNotification.Name("NC_SideMenuToLogin"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(showRatingVC), name: NSNotification.Name("NC_ShowRatingVC"), object: nil)
        
        // animation delegate
        dailyTaskVC = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("DailyTaskVC : viewWillAppear ✅ : selectedIndex : \(passedSelectedIndex) ")
        
        print("UserData.shared.currentContentDay: \(UserData.shared.currentContentDay), UserData.shared.currentTaskNo: \(UserData.shared.currentTaskNo)")
        
        
        if Helper.shared.areThreeCurrentTasksCompleted {
            dayCompleteContainerView.isHidden = false
        } else {
            dayCompleteContainerView.isHidden = true
        }
        
        dayCompleteContainerView.isHidden = true
        
        if let weekdayArr = UserDefaults.standard.object(forKey: UD_USER_DATA_WEEKDAYS_ARRAY) as? [Int] {
            
            if weekdayArr[passedSelectedIndex] == -1/* || weekdayArr[passedSelectedIndex] == 7*/ {
                logoImageView.image = UIImage(named: "logo blue")
                menuButton.setImage(UIImage(named: "Menu"), for: UIControlState.normal)
                weekendContainerView.alpha = 1.0
                weekendContainerView.isHidden = false
            } else {
                logoImageView.image = UIImage(named: "logo_white")
                menuButton.setImage(UIImage(named: "menu bar")!, for: UIControlState.normal)
                weekendContainerView.alpha = 0
                weekendContainerView.isHidden = true
                displaySelectedTask()
            }
        }
        
    }
    
    func displaySelectedTask() {
        
        if let tasksArr = UserDefaults.standard.object(forKey: UD_USER_DATA_TASKS_ARRAY) as? [Int] {
            
            
            displayAvailableTasks(taskNo: tasksArr[passedSelectedIndex], completion: {
                
            })
        }
        
    }
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if UserData.shared.isTask1Finished {
            task1ProgressView.setProgress(1.0, animated: true)
        } else {
            task1ProgressView.setProgress(0.0, animated: true)
        }
        if UserData.shared.isTask2Finished {
            task2ProgressView.setProgress(1.0, animated: true)
        } else {
            task2ProgressView.setProgress(0.0, animated: true)
            
            if UserData.shared.isTask1Finished {
                // display task2 detail
                if let decoded = UserDefaults.standard.object(forKey: UD_AVAILABLE_TASKS) as? Data, let tasksDict = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [Int: UserContent] {
                    
                    let tasksArr = tasksDict.sorted(by: { (a, b) -> Bool in
                        a.key < b.key
                    })
                    
                    for task in tasksArr {
                        if task.0 == UserData.shared.currentContentDay /*currentContentDayNo*/ {
                            let userContent = task.1
                            
                            self.titleLabel.text = userContent.contentCategory.capitalized
                            
                            for item in userContent.tasks {
                                
                                let userTask = item.value
                                
                                if item.key.contains("task2") {
                                    
                                    if let currentDate = Helper.shared.getCurrentDate() {
                                        
                                        self.dayWeekdayNoLabel.text = "Day \(UserData.shared.currentContentDay /*currentContentDayNo*/ + 1) \(currentDate.weekdayStr)"
                                    }
                                    
                                    task1TitleLabel.text = userTask.taskTitle
                                    
                                }
                                
                            }
                            
                        }
                    }
                }
            }
        }
        
        if UserData.shared.isTask3Finished {
            task3ProgressView.setProgress(1.0, animated: true)
        } else {
            task3ProgressView.setProgress(0.0, animated: true)
            
            if UserData.shared.isTask1Finished && UserData.shared.isTask2Finished {
                
                // display task3 detail
                if let decoded = UserDefaults.standard.object(forKey: UD_AVAILABLE_TASKS) as? Data, let tasksDict = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [Int: UserContent] {
                    
                    let tasksArr = tasksDict.sorted(by: { (a, b) -> Bool in
                        a.key < b.key
                    })
                    
                    for task in tasksArr {
                        if task.0 == UserData.shared.currentContentDay /*currentContentDayNo*/ {
                            let userContent = task.1
                            
                            self.titleLabel.text = userContent.contentCategory.capitalized
                            
                            for item in userContent.tasks {
                                
                                let userTask = item.value
                                
                                if item.key.contains("task3") {
                                    
                                    if let currentDate = Helper.shared.getCurrentDate() {
                                        
                                        self.dayWeekdayNoLabel.text = "Day \(UserData.shared.currentContentDay /*currentContentDayNo*/ + 1) \(currentDate.weekdayStr)"
                                    }
                                    
                                    task1TitleLabel.text = userTask.taskTitle
                                    
                                    
                                }
                                
                            }
                            
                        }
                    }
                }
                
            }
        }
        
        //        if UserData.shared.isTask1Finished && UserData.shared.isTask2Finished && UserData.shared.isTask3Finished {
        //            UserData.shared.userTaskResult = nil
        //            UserData.shared.userDayTaskResultDict = [String: DayTaskResult]()
        //            UserData.shared.isTask1Finished = false
        //            UserData.shared.isTask2Finished = false
        //            UserData.shared.isTask3Finished = false
        //        }
        
    }
    
    
    
    func checkCredential() -> (Bool, String?, String?) {
        
        if let name = KeychainSwift().get(KC_USER_EMAIL), let pw = KeychainSwift().get(KC_USER_PASSWORD) {
            print("checkCredential ❗️ \(name) \(pw)")
            return (true, name, pw)
        } else {
            return (false, nil, nil)
        }
    }
    
    func showLoginVC() {
        
        DispatchQueue.main.async {
            
            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    
    func displayAvailableTasks(taskNo: Int, completion: @escaping ()->()) {
        
        UserData.shared.currentContentDay /*currentContentDayNo*/ = taskNo
        if let decoded = UserDefaults.standard.object(forKey: UD_AVAILABLE_TASKS) as? Data, let tasksDict = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [Int: UserContent] {
            
            print("*** ✅ displayAvailableTasks ***")
            
            let tasksArr = tasksDict.sorted(by: { (a, b) -> Bool in
                a.key < b.key
            })
            
            for task in tasksArr {
                if task.0 == taskNo {
                    let userContent = task.1
                    
                    self.titleLabel.text = userContent.contentCategory.capitalized
                    
                    for item in userContent.tasks {
                        
                        let userTask = item.value
                        
                        if item.key.contains("task1") {
                            
                            if let currentDate = Helper.shared.getCurrentDate() {
                                
                                self.dayWeekdayNoLabel.text = "Day \(taskNo+1) \(currentDate.weekdayStr)"
                            }
                            
                            self.task1TitleLabel.text = userTask.taskTitle
                            
                            self.task1TypeTimeLabel.text = "\(userTask.taskType.capitalized) \(Helper.shared.formatTime(withDuration: userTask.taskDuration))"
                        }
                        
                        if item.key.contains("task2") {
                            self.task2TypeTimeLabel.text = "\(userTask.taskType.capitalized) \(Helper.shared.formatTime(withDuration: userTask.taskDuration))"
                        }
                        
                        if item.key.contains("task3") {
                            var type = userTask.taskType
                            
                            if type.lowercased() == TaskType.Checkoff.rawValue {
                                type = "Practice"
                            }
                            
                            self.task3TypeTimeLabel.text = "\(type.capitalized) \(Helper.shared.formatTime(withDuration: userTask.taskDuration))"
                        }
                    }
                    completion()
                }
            }
        } else {
            print("*** ❌ displayAvailableTasks ***")
            
            /*
            AWSClientManager.shared.getItemFromDB(startTaskNo: taskNo, endTaskNo: taskNo + 4, completion: { (tasksDict: [(key: Int, value: UserContent)]) in
                
                
                self.displayAvailableTasks(taskNo: taskNo, completion: {
                    completion()
                })
                
                
            })
            */
            
        }
    }
    
    func showRateVideoAlert() {
        showCustomAlertView()
    }
    
    func presentAccountVC() {
        self.performSegue(withIdentifier: "dailyTasksToAccount", sender: nil)
    }
    
    func presentHelpVC() {
        self.performSegue(withIdentifier: "dailyTasksToHelp", sender: nil)
    }
    
    func presentWeekeviewVC() {
        //        self.performSegue(withIdentifier: "dailyTasksToWeekview", sender: nil)
    }
    
    func presentLoginVC() {
        // logout
        
        Helper.shared.logoutCurrentUser()
        
        dismiss(animated: false) {
            NotificationCenter.default.post(name: NSNotification.Name("NC_LogoutAndDismiss"), object: nil)
        }
    }
    
    //========================================
    // MARK: - Actions
    //========================================
    @IBAction func testingButtonPressed(_ sender: UIButton) {
        print("testingButtonPressed ❗️")
        
        
        // important 1
        //         let currentDate = Helper.shared.getCurrentDateStr()
        //         print(currentDate)
        //
        //         if let startDate = KeychainSwift().get(KC_CUSTOM_START_DATE) {
        //         if let days = Helper.shared.getNumOfDaysBetweenTwoDates(date1Str: startDate, date2Str: currentDate) {
        //         print("getNumOfDaysBetweenTwoDates ❗️ \(days)")
        //         }
        //         }
        
        
         // important 2
         if let arr = UserDefaults.standard.object(forKey: UD_USER_DATA_WEEKDAYS_ARRAY) as? [Int] {
         print("arr : weekdays ❗️ \(arr)")
         }
         
         if let arr = UserDefaults.standard.object(forKey: UD_USER_DATA_TASKS_ARRAY) as? [Int] {
         print("arr : tasks ❗️ \(arr)")
         }
         
         // important 3
         if let decoded = UserDefaults.standard.object(forKey: UD_AVAILABLE_TASKS) as? Data, let tasksDict = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [Int: UserContent] {
         
         print("tasksDict ❗️ \(tasksDict)")
         }
 
        // important 4
        // try to get current user task data
//        print("UserData.shared.userTaskResult : \(UserData.shared.userTaskResult)")
        
//        if let daysInRow = KeychainSwift().get(KC_ANALYTICS_DAYS_IN_ROW) {
//            print("daysInRow: \(daysInRow)")
//        }
        
        
        
//        Helper.shared.fetchAndDisplayCurrentUnfinishedUserTask()
        
    }
    
    @IBAction func playBtnPressed(_ sender: UIButton) {
        
        if !UserData.shared.isTask1Finished {
            // show task1
            UserData.shared.currentTaskNo = 1
            showTaskWithTaskNo()
        } else {
            if !UserData.shared.isTask2Finished {
                // shwo task2
                UserData.shared.currentTaskNo = 2
                showTaskWithTaskNo()
            } else {
                if !UserData.shared.isTask3Finished {
                    // show task3
                    UserData.shared.currentTaskNo = 3
                    showTaskWithTaskNo()
                } else {
                    // all 3 tasks done
                    //                    if UserData.shared.isTask1Finished && UserData.shared.isTask2Finished && UserData.shared.isTask3Finished {
                    
                    
                    // FIXME: change this later
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomVideoPlayerViewController") as! CustomVideoPlayerViewController
                    present(vc, animated: false, completion: nil)
                    
                    
                    //                    }
                }
            }
        }
    }
    
    
    func showTaskWithTaskNo() {
        
        if UserData.shared.isTask1Finished && UserData.shared.isTask2Finished && UserData.shared.isTask3Finished {
            
            // if all 3 tasks done and user hits play again, play video but don't show rating
            if let content = Helper.shared.getCurrentTask(contentDay: UserData.shared.currentContentDay, task: 0) { // FIXME: assume task1 is video and hardcoded task1 number
                
                selectedTaskType = content.taskType
                
                if selectedTaskType == TaskType.Video.rawValue {
                    
                    selectedVideoHashId = content.videoUrl
                    
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CustomVideoPlayerViewController") as! CustomVideoPlayerViewController
                    present(vc, animated: false, completion: nil)
                    
                }
            }
        }
        else {
            if let content = Helper.shared.getCurrentTask(contentDay: UserData.shared.currentContentDay, task: UserData.shared.currentTaskNo) {
                
                selectedTaskType = content.taskType
                
                if selectedTaskType == TaskType.Video.rawValue {
                    selectedVideoHashId = content.videoUrl
                    performSegue(withIdentifier: "dailyTaskToCountdown", sender: nil)
                } else if selectedTaskType == TaskType.Quiz.rawValue {
                    performSegue(withIdentifier: "dailyTaskToCountdown", sender: nil)
                } else if selectedTaskType == TaskType.Checkoff.rawValue {
                    performSegue(withIdentifier: "dailyTasksToDailyGoalCheckList", sender: nil)
                } else if selectedTaskType == TaskType.Unknown.rawValue {
                    let alert = UIAlertController(title: "", message: "type is unknown", preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                    alert.addAction(action)
                    present(alert, animated: true, completion: nil)
                }
            }
            
        }
        
    }
    
    // delete task 0 from db and reset ui
    //    @IBAction func debug(_ sender: UIButton) {
    //        print("*** ✅ debug ***")
    //
    //        UserData.shared.isTask1Finished = false
    //        UserData.shared.isTask2Finished = false
    //        UserData.shared.isTask3Finished = false
    //
    //        task1ProgressView.setProgress(0, animated: true)
    //        task2ProgressView.setProgress(0, animated: true)
    //        task3ProgressView.setProgress(0, animated: true)
    //
    //        AWSClientManager.shared.deleteItemFromDB(ofContentDay: 0, completion: {})
    //        login()
    //
    //    }
    
    @IBAction func showMeAgainBtnPressed(_ sender: UIButton) {
        Helper.shared.areThreeCurrentTasksCompleted = false
        dayCompleteContainerView.isHidden = true
        
    }
    
    
    //========================================
    // MARK: - Navigations
    //========================================
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "dailyTasksToQuiz" {
            let vc = segue.destination as! QuizViewController
            vc.quizViewControllerDelegate = self
        } else if segue.identifier == "dailyTasksToDailyGoalCheckList" {
            // TODO:
        } else if segue.identifier == "giveRateSegue" {
            let vc = segue.destination as! GiveRatingViewController
            vc.giveRatingDelegate = self
            vc.hashedId = "u5r8wqi6wn"
        } else if segue.identifier == "dailyTaskToCountdown" {
            let vc = segue.destination as! CountdownViewController
            vc.videoHashId = selectedVideoHashId
            vc.selectedTaskType = selectedTaskType
            vc.countdownViewControllerDelegate = self
        }
    }
    
    //========================================
    // MARK: - Private Methods
    //========================================
    func showRatingVC() {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GiveRatingViewController") as! GiveRatingViewController
        self.present(vc, animated: false, completion: nil)
    }
    
    
    func segueFromDailyTasksToWeekview() {
        print("*** segue ***")
        //        self.performSegue(withIdentifier: "dailyTasksToWeekview", sender: nil)
    }
    
    //    func refresh() {
    //
    //        print("DailyTasksVC : refresh ✅")
    //
    //        pool = AWSCognitoIdentityUserPool(forKey: KEY_USER_POOL)
    //
    //        user = pool?.currentUser()
    //
    //        user?.getDetails().continue({ (task: AWSTask<AWSCognitoIdentityUserGetDetailsResponse>) -> Any? in
    //
    //            if let err = task.error {
    //                print("DailyTasksVC : refresh❌ \(err.localizedDescription)")
    //            } else {
    //
    //                DispatchQueue.main.async {
    //                    self.refreshContent()
    //                }
    //            }
    //
    //            return nil
    //        })
    //    }
    
    // stop popover view from presenting full screen on iphone
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    
    func showQuiz() {
        
        performSegue(withIdentifier: "dailyTasksToQuiz", sender: nil)
    }
    
    //    func showVideo(hashId: String) {
    //
    //        wistiaPlayerVC.replaceCurrentVideoWithVideo(forHashedID: hashId)
    //        if !task1Finished {
    //            task1Finished = true
    //        }
    //        self.present(wistiaPlayerVC, animated: true, completion: nil)
    //    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    func pinchedUIView(sender: UIPinchGestureRecognizer) {
        if sender.scale < 0.5 {
            dismiss(animated: true, completion: nil)
        }
    }
    
}

/*
 
 extension DailyTasksViewController: WeekviewViewControllerDelegate {
 
 func displaySelectedTask(num: Int, weekday: Int, vc: WeekviewViewController) {
 
 // FIXME: temp out
 //        self.playButton.isHidden = num == 0 ? false : true
 
 print("DailyTasksViewController: WeekviewViewControllerDelegate ❗️ contentDay: \(num), weekday: \(weekday)")
 
 UserData.shared.currentContentDay = num
 
 DispatchQueue.main.async {
 
 if weekday == 1 || weekday == 7 {
 
 // display weekend
 self.weekendContainerView.isHidden = false
 self.logoImageView.image = UIImage(named: "logo blue")
 self.menuButton.setImage(UIImage(named: "Menu"), for: UIControlState.normal)
 
 } else {
 
 // display daily task
 self.weekendContainerView.isHidden = true
 self.logoImageView.image = UIImage(named: "logo_white")
 self.menuButton.setImage(UIImage(named: "menu bar"), for: UIControlState.normal)
 
 
 if let decoded = UserDefaults.standard.object(forKey: UD_AVAILABLE_TASKS) as? Data, let tasksDict = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [Int:UserContent] {
 
 for task in tasksDict {
 
 if num == task.key {
 let userContent = task.value
 let tasks = userContent.tasks
 
 self.dayWeekdayNoLabel.text = "Day \(num+1) \(Helper.shared.weekdayConverter(weekday: weekday).capitalized)"
 
 self.titleLabel.text = userContent.contentCategory.capitalized
 
 
 
 for (taskKey, taskValue) in tasks {
 
 if taskKey.contains("task1") {
 
 self.task1TitleLabel.text = taskValue.taskTitle.capitalized
 self.task1TypeTimeLabel.text = "\(taskValue.taskType.capitalized) 0:00"
 }
 
 if taskKey.contains("task2") {
 
 self.task2TypeTimeLabel.text = "\(taskValue.taskType.capitalized) 0:00"
 
 }
 
 if taskKey.contains("task3") {
 var type = taskValue.taskType
 if type.lowercased() == TaskType.Checkoff.rawValue {
 type = "Practice"
 }
 self.task3TypeTimeLabel.text = "\(type.capitalized) 0:00"
 
 }
 }
 }
 }
 
 }
 
 }
 
 // dismiss WeekendViewVC
 vc.dismiss(animated: true, completion: nil)
 
 }
 
 }
 
 }
 
 */

extension DailyTasksViewController: QuizViewControllerDelegate {
    internal func pauseQuiz(vc: QuizViewController) {
        print("DailyTasksViewController: QuizViewControllerDelegate")
    }
    
    func dismiss(vc: QuizViewController) {
        vc.dismiss(animated: true) {
            //            self.currentDayTaskNo = 3
            //            self.performSegue(withIdentifier: "dailyTasksToDailyGoalCheckList", sender: self)
            self.performSegue(withIdentifier: "dailyTaskToCountdown", sender: nil)
            
        }
    }
}

extension DailyTasksViewController: GiveRatingViewControllerDelegate{
    func dismissGiveRating(vc: GiveRatingViewController) {
        //        currentDayTaskNo = 2
        //        UserData.shared.currentTaskNo += 1
        
        // FIXME: hardcoded
        //        selectedTaskType = "quiz"
        //        currentContentDayNo = 0
        
        vc.dismiss(animated: false) {
            
            // show countdown screen
            self.performSegue(withIdentifier: "dailyTaskToCountdown", sender: nil)
        }
    }
}



extension DailyTasksViewController: SwiftAlertViewDelegate {
    
    func showCustomAlertView() {
        let alertView = SwiftAlertView(title: "Rate This Video", message: "We'd love to know what you thought of our content.", delegate: self, cancelButtonTitle: "Skip", otherButtonTitles: "Rate")
        
        alertView.backgroundColor = UIColor.white
        
        alertView.titleLabel.textColor = COLOR_LIGHT_BLUE
        alertView.titleLabel.font = UIFont(name: CUSTOM_FONT_BOLD, size: FONT_SIZE_ALERT_BIG)
        
        alertView.messageLabel.textColor = COLOR_TEXT_DARK_GRAY
        alertView.messageLabel.font = UIFont(name: CUSTOM_FONT_MEDIUM, size: FONT_SIZE_ALERT_SMALL)
        
        alertView.buttonAtIndex(0)?.setTitleColor(UIColor.gray, for: UIControlState())
        alertView.buttonAtIndex(0)?.titleLabel?.font = UIFont(name: CUSTOM_FONT_BOLD, size: FONT_SIZE_ALERT_SMALL)
        
        alertView.buttonAtIndex(1)?.setTitleColor(COLOR_LIGHT_BLUE, for: UIControlState())
        alertView.buttonAtIndex(1)?.titleLabel?.font = UIFont(name: CUSTOM_FONT_BOLD, size: FONT_SIZE_ALERT_SMALL)
        
        alertView.show()
    }
    
    func alertView(_ alertView: SwiftAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            print("*** SKIP button pressed ***")
            
            task2Finished = true
            
            if let userContent = Helper.shared.getAvailableTask(taskNo: UserData.shared.currentTaskNo) {
                
                for (taskKey, taskValue) in userContent.tasks {
                    
                    if taskKey.contains("task2") {
                        if taskValue.taskType == TaskType.Video.rawValue {
                            print("taskType : video")
                            //                            showVideo(hashId: taskValue.wistiaId)
                        } else if taskValue.taskType == TaskType.Quiz.rawValue {
                            print("taskType : quiz")
                            showQuiz()
                        } else if taskValue.taskType == TaskType.Checkoff.rawValue {
                            print("taskType : checkoff")
                            
                        } else if taskValue.taskType == TaskType.Unknown.rawValue {
                            print("taskType : unknown")
                            
                        }
                    }
                    
                }
            }
        } else {
            print("*** rate! ***")
            self.performSegue(withIdentifier: "giveRateSegue", sender: nil)
        }
    }
}

extension DailyTasksViewController: CountdownViewControllerDelegate {
    
    func dismissVC(finishedTaskNo: Int, vc: CountdownViewController) {
        print("DailyTasksViewController: CountdownViewControllerDelegate ❗️ finishedTaskNo : \(finishedTaskNo)")
        if finishedTaskNo == 1 {
            task1Finished = true
        } else if finishedTaskNo == 2 {
            task2Finished = true
        } else if finishedTaskNo == 3 {
            task3Finished = true
            Helper.shared.areThreeCurrentTasksCompleted = true
        }
        
        vc.dismiss(animated: false, completion: {
            
            let previousTaskNo = UserData.shared.currentTaskNo - 1
            
            if let content = Helper.shared.getCurrentTask(contentDay: UserData.shared.currentContentDay, task: previousTaskNo) {
                // check the previous task type, the task user just finished
                if content.taskType == TaskType.Video.rawValue {
                    
                    self.performSegue(withIdentifier: "giveRateSegue", sender: nil)
                    
                } else {
                    
                    //                    if let content = Helper.shared.getCurrentTask(contentDay: UserData.shared.currentContentDay, task: UserData.shared.currentTaskNo) {
                    //
                    //                        if content.taskType == "checkoff" {
                    self.performSegue(withIdentifier: "dailyTaskToCountdown", sender: nil)
                    //                        }
                    //                    }
                    
                }
            }
        })
    }
}

extension DailyTasksViewController: UIViewControllerTransitioningDelegate {
    
    
    
}
