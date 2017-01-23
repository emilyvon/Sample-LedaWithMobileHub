//
//  WeekviewTasksViewController.swift
//  LEDA
//
//  Created by Mengying Feng on 12/1/17.
//  Copyright © 2017 Andrew Osborne. All rights reserved.
//

import UIKit
//import AWSCognitoIdentityProvider
import AWSDynamoDB
import JWTDecode
import SwiftGifOrigin
import AWSMobileHubHelper

class WeekviewTasksViewController: UIViewController {
    
    //========================================
    // MARK: - Outlets
    //========================================
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingContainerView: UIView!
    @IBOutlet weak var loadingImageView: UIImageView!
    @IBOutlet weak var loadingDotLabel: UILabel!
    
    //========================================
    // MARK: - Properties
    //========================================
//    var pool: AWSCognitoIdentityUserPool?
//    var user: AWSCognitoIdentityUser?
    
    var timer = Timer()
    
    let transition = PopAnimator()
    var selectedIndexPath: IndexPath?
    
    var currentSelectedCell = -1
    var previousSelectedCell = -1
    var isSameSelectedCell = false
    
    var cellRectBeforeExpanding: CGRect!
    
    //    let weekdayArr = [4, 5, 6, 7, 1, 2, 3]
    //    let taskNoArr =  [0, 1, 2, 2, 2, 3, 4]
    //    let daysInRow = 2 // unfinished/current active task no
    
    var activeTaskIndexInTableView = 0
    
    var isScrolled = false
    
    var gifImageNameArray = ["Coffee", "Music", "Park", "Reading"]
    
    
    
    //========================================
    // MARK: - View lifecycles
    //========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showLoadingScreen(shouldShow: true)
        
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(updateLoadingDot), userInfo: nil, repeats: true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNewDataAfterSignedIn), name: NSNotification.Name("updateWeekviewTasks"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(presentLoginVC), name: NSNotification.Name("NC_LogoutAndDismiss"), object: nil)
        
        // check token and db before initData
//        checkTokenAndDb()
        
        if AWSIdentityManager.defaultIdentityManager().isLoggedIn {
            updateNewDataAfterSignedIn()
        }        
    }
    
    func updateNewDataAfterSignedIn() {
        
        initData {

            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            
            self.tableView.scrollToRow(at: IndexPath(row: self.activeTaskIndexInTableView, section: 0), at: UITableViewScrollPosition.middle, animated: false)
            
            self.showLoadingScreen(shouldShow: false)

//            self.getCurrentTask()
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // show loading screen if it is coming from login screen, now viewDidLoad
        if Helper.shared.isLoggedIn {
            showLoadingScreen(shouldShow: true)
            Helper.shared.isLoggedIn = false
        }
        
        presentSignInViewController()
    }
    
    func presentSignInViewController() {
        print("presentSignInViewController: isLoggedIn: \(AWSIdentityManager.defaultIdentityManager().isLoggedIn)")
        
        if !AWSIdentityManager.defaultIdentityManager().isLoggedIn {
            
            
            print("✅ present sign in vc")
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
                self.present(vc, animated: false, completion: nil)
            }
            
        }
        
    }
    
    func presentLoginVC() {
        print("presentLoginVC() ❗️")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
            
            self.isSameSelectedCell = false
            
            self.previousSelectedCell = -1
            self.currentSelectedCell = -1
            
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
        
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        
        self.present(vc, animated: true, completion: nil)
        
        
    }
    
    func checkTokenAndDb() {
        
        if Helper.shared.isTokenValid() {
            print("✅ token valid")
            print("✅ display tasks")
            
            if AWSClientManager.shared.isDbRegisterd() {
                print("token valid & db registered ❗️")
                
                initData {
//                    DispatchQueue.main.async {
                    self.showLoadingScreen(shouldShow: false)
//                    self.getCurrentTask()
                    
//                    }
                }
                
            } else {
                print("token valid & db NOT registered ❗️")
                if let sessionToken = KeychainSwift().get(KC_SESSION_TOKEN) {
                    
                    AWSClientManager.shared.registerDynamoDB(withToken: sessionToken) {
                        
                        self.initData {
//                            DispatchQueue.main.async {
                            self.showLoadingScreen(shouldShow: false)
//                            self.getCurrentTask()
//                            }
                        }
                        
                    }
                }
            }
            
            
        } else {
            print("❌ token NOT valid")
            print("❌ sign in and get token")
            
            if let keptLoggedIn = UserDefaults.standard.object(forKey: UD_USER_KEEP_LOGGED_IN) as? Bool {
                
                if keptLoggedIn {
                    print("auto login")
                    if let kc_user_email = KeychainSwift().get(KC_USER_EMAIL), let kc_user_password = KeychainSwift().get(KC_USER_PASSWORD) {
                        AWSClientManager.shared.signInUser(name: kc_user_email, password: kc_user_password, completion: { (result) in
                            if result {
                                
                                print("auto signed in ✅")
                                // display data
                                self.initData {
//                                    DispatchQueue.main.async {
                                    self.showLoadingScreen(shouldShow: false)
//                                    self.getCurrentTask()
//                                    }
                                }
                                
                            } else {
                                self.showLoginVC()
                            }
                        })
                    } else {
                        showLoginVC()
                    }
                    
                }
                else {
                    print("don't auto login")
                    showLoginVC()
                    
                }
                
            } else {
                print("don't auto login")
                showLoginVC()
                
            }
        }
        
        
    }
    
    @IBAction func testing(_ sender: Any) {
        print("testing")
        
        
        AWSMobileHubClientManager.shared.scanTasks(startContent: 0, endContent: 4)
        
        //        AWSClientManager.shared.queryUserAnalytics { (ana) in
        //            print(ana.daysInARow)
        //        }
        
        //        let db = AWSDynamoDB(forKey: "ledaDB")
        //
        //        print(db.configuration.userAgent)
        //        print(db.configuration.credentialsProvider.debugDescription!)
        //        db.configuration.credentialsProvider.credentials().continue({ (credentials: AWSTask<AWSCredentials>) -> Any? in
        //            if let err = credentials.error {
        //                print("err ❌ \(err)")
        //            } else {
        //                print(credentials.result.customMirror)
        //            }
        //            return nil
        //        })
        
        
        //        if AWSServiceManager.default().defaultServiceConfiguration == nil {
        //            print("manager if nil")
        //        } else {
        //            print("manager not nil")
        //        }
        /*
         let result = Helper.shared.isTokenValid()
         
         
         let db = AWSDynamoDB(forKey: "ledaDB")
         if let _ = db.configuration.userAgent {
         
         print("ledaDB registered")
         
         AWSClientManager.shared.queryUserAnalytics(completion: { (ana) in
         print(ana.daysInARow)
         })
         
         } else {
         
         print("ledaDB NOT registered")
         
         if let sessionToken = KeychainSwift().get(KC_SESSION_TOKEN) {
         
         AWSClientManager.shared.registerDynamoDB(withToken: sessionToken) {
         AWSClientManager.shared.queryUserAnalytics(completion: { (analytics) in
         print(analytics.daysInARow)
         
         })
         }
         
         
         }
         
         }
         */
        
        /*
        if let taskNoArr = UserDefaults.standard.object(forKey: UD_USER_DATA_TASKS_ARRAY) as? [Int], let weekdayArr = UserDefaults.standard.object(forKey: UD_USER_DATA_WEEKDAYS_ARRAY) as? [Int] {
            
            print("taskNoArr: \(taskNoArr), \nweekdayArr: \(weekdayArr)")
            
        }
        */
        
        
    }
    
    //========================================
    // MARK: - Set up tableView
    //========================================
    
    func setupCurrentActiveTask(withIndex num: Int, completion: ()->()) {
        print("WeekviewTasksVC : setupCurrentActiveTask ❗️")
        guard let weekdayArr = Helper.shared.getWeekdayArr(), let taskNoArr = Helper.shared.getTasksArr(daysInRow: num) else { return }
        
        var i = 0
        
        for item in taskNoArr {
            
            if item == num {
                if weekdayArr[i] != 7 && weekdayArr[i] != 1 {
                    activeTaskIndexInTableView = i
                }
            }
            
            i += 1
        }
        
        
        currentSelectedCell = activeTaskIndexInTableView
        previousSelectedCell = activeTaskIndexInTableView
        isSameSelectedCell = false
        print("activeTaskIndexInTableView: \(activeTaskIndexInTableView)")
        
        completion()
    }
    
    func setupTableView() {
        print("WeekviewTasksVC : setupTableView ❗️")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor(red: 251/255, green: 251/255, blue: 251/255, alpha: 1.0)
        tableView.layoutMargins = UIEdgeInsets.zero
        tableView.separatorStyle = .none
        
    }
    
    
    func initData(completion: @escaping ()->()) {
        print("WeekviewTasksVC : initData ❗️")
        // query daysInRow from db
//        AWSClientManager.shared.queryUserAnalytics(completion: { (ana) in
//            print(ana.daysInARow)
        AWSMobileHubClientManager.shared.queryUserAnalytics {
            
        
            let currentDaysInRowInt = Int(KeychainSwift().get(KC_ANALYTICS_CURRENT_DAYS_IN_ROW)!)!
            
            // get task from db/device
            self.downloadData(startTaskNum: currentDaysInRowInt, endTaskNum: currentDaysInRowInt+4) {
                
                self.setupCurrentActiveTask(withIndex: currentDaysInRowInt) {
                    DispatchQueue.main.async {
                        self.setupTableView()
                        print("❗️❗️ ❗️ \(self.activeTaskIndexInTableView)")
                        
//                        AWSClientManager.shared.getUserTask(forTaskday: daysInRowInt, completion: {
                            completion()
//                        })
                    
                    }
                }
            }
        }
//        })
        
        
        
    }
    
    
    
    
    func showLoadingScreen(shouldShow: Bool) {
        
        if shouldShow {
            timer.fire()
            loadingContainerView.isHidden = false
            loadingContainerView.alpha = 1
            loadingImageView.image = UIImage.gif(name: gifImageNameArray[Int(arc4random_uniform(3))])
        } else {
            
            UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveEaseOut, animations: {
                self.loadingContainerView.alpha = 0
            }, completion: { (_) in
                self.loadingContainerView.isHidden = true
                self.loadingImageView.image = nil
                self.timer.invalidate()
            })
        }
    }
    
    func updateLoadingDot() {
        
        loadingDotLabel.text?.append(".")
        
        if let labelText = loadingDotLabel.text {
            
            if labelText.characters.count > 6 {
                
                loadingDotLabel.text = "."
                
            }
            
        }
        
    }
    
    func showLoginVC() {
        
        DispatchQueue.main.async {
            
            let loginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            
            self.present(loginVC, animated: true, completion: nil)
        }
    }
    
    func downloadData(startTaskNum: Int, endTaskNum: Int, completion: @escaping () -> ()) {
        print("WeekviewTasksVC : downloadData ✅")
        
        if let decoded = UserDefaults.standard.object(forKey: UD_AVAILABLE_TASKS) as? Data, let _ = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [Int: UserContent] {
            print(" get item from device ❗️ ")
            print("11 ✅")
            completion()
            
        } else {
            
            print(" get item from DB ❗️ ")
            print("22 ✅")
            
            
            AWSClientManager.shared.getItemFromDB(startTaskNo: startTaskNum, endTaskNo: endTaskNum, completion: { (result: [(key: Int, value: UserContent)]) in
                
                completion()
                
            })
        } // END else
    }
}

extension WeekviewTasksViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let taskNoArr = UserDefaults.standard.object(forKey: UD_USER_DATA_TASKS_ARRAY) as? [Int], let weekdayArr = UserDefaults.standard.object(forKey: UD_USER_DATA_WEEKDAYS_ARRAY) as? [Int] {
            let cell = tableView.dequeueReusableCell(withIdentifier: "WeekviewCell") as! WeekviewTaskTableViewCell
            cell.selectionStyle = .none
            cell.configureCell(weekdayNo: weekdayArr[indexPath.row], currentActiveTaskNo: activeTaskIndexInTableView, taskNo: taskNoArr[indexPath.row], tableIndex: indexPath.row)
            
            return cell
            
        }
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if currentSelectedCell != -1 && currentSelectedCell == indexPath.row && currentSelectedCell != previousSelectedCell {
            return 343
        }
        else if isSameSelectedCell && currentSelectedCell == indexPath.row {
            return self.view.frame.size.height
        }
        else if currentSelectedCell == indexPath.row {
            return 343
        }
        else {
            return 130
        }
    }
    
    
    
}

extension WeekviewTasksViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("index: \(indexPath.row)")
        selectedIndexPath = indexPath
        
        let selectedCell = tableView.cellForRow(at: indexPath) as! WeekviewTaskTableViewCell
        
        currentSelectedCell = indexPath.row
        
        if previousSelectedCell == currentSelectedCell {
            isSameSelectedCell = true
        } else {
            isSameSelectedCell = false
        }
        
        print("previous: \(previousSelectedCell)")
        print("current:\(currentSelectedCell)")
        print("isSame:\(isSameSelectedCell)")
        print("✅")
        
        
        if !isSameSelectedCell {
            
            UIView.animate(withDuration: 3.0) {
                
                selectedCell.contentView.layoutIfNeeded()
            }
            
            tableView.beginUpdates()
            tableView.endUpdates()
            
            tableView.scrollToRow(at: IndexPath(row: indexPath.row, section: 0), at: UITableViewScrollPosition.middle, animated: true)
        }
            
        else {
            
            cellRectBeforeExpanding = tableView.rectForRow(at: indexPath)
            
            DispatchQueue.main.async {
                
                UIView.animate(withDuration: 3.0, animations: {
                    selectedCell.contentView.layoutIfNeeded()
                }, completion: { (_) in
                    
                    let dailyVC = self.storyboard!.instantiateViewController(withIdentifier: "DailyTasksViewController") as! DailyTasksViewController
                    dailyVC.transitioningDelegate = self
                    dailyVC.selectedIndex = self.currentSelectedCell
                    self.present(dailyVC, animated: true, completion: nil)
                    
                })
                
                tableView.beginUpdates()
                tableView.endUpdates()
                
                tableView.scrollToRow(at: IndexPath(row: indexPath.row, section: 0), at: UITableViewScrollPosition.middle, animated: true)
                
            }
        }
        
        previousSelectedCell = currentSelectedCell
    }
    
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if !isScrolled {
            tableView.scrollToRow(at: IndexPath(row: currentSelectedCell, section: 0), at: UITableViewScrollPosition.middle, animated: true)
            isScrolled = true
        }
        
    }
    
    
}

extension WeekviewTasksViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("animationController:forDismissed ❗️")
        transition.presenting = false
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.1) {
            
            self.isSameSelectedCell = false
            
            self.previousSelectedCell = self.currentSelectedCell
            
            let selectedCell = self.tableView.cellForRow(at: IndexPath(row: self.currentSelectedCell, section: 0))!
            
            UIView.animate(withDuration: 1.0) {
                selectedCell.contentView.layoutIfNeeded()
            }
            
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            
            
            self.tableView.scrollToRow(at: IndexPath(row: self.currentSelectedCell, section: 0), at: UITableViewScrollPosition.middle, animated: true)
            
        }
        
        
        return transition
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        print("animationController:forPresented ❗️")
        //        let cellRect = tableView.rectForRow(at: selectedIndexPath!)
        let cellRect = cellRectBeforeExpanding!
        let rectInSuperview = tableView.convert(cellRect, to: tableView.superview)
        transition.originFrame = rectInSuperview
        transition.presenting = true
        transition.isExpanding = true
        return transition
    }
    
}
