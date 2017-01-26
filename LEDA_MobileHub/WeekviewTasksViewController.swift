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
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateNewDataAfterSignedIn), name: NSNotification.Name("AWSIdentityManagerResumeSession"), object: nil)
        
        // check token and db before initData
        //        checkTokenAndDb()
        
        //        if AWSIdentityManager.defaultIdentityManager().isLoggedIn {
        //            updateNewDataAfterSignedIn()
        //        }
    }
    
    func updateNewDataAfterSignedIn() {
        print("updateNewDataAfterSignedIn ❗️")
        
        initData {
            
            
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            
            self.tableView.scrollToRow(at: IndexPath(row: self.activeTaskIndexInTableView, section: 0), at: UITableViewScrollPosition.middle, animated: false)
            
            self.showLoadingScreen(shouldShow: false)
            
            
            
        }
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        /*
         // show loading screen if it is coming from login screen, now viewDidLoad
         if Helper.shared.isLoggedIn {
         showLoadingScreen(shouldShow: true)
         Helper.shared.isLoggedIn = false
         }
         */
        
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
    
    
    @IBAction func testing(_ sender: Any) {
        print("testing")
        
        
    }
    
    //========================================
    // MARK: - Set up tableView
    //========================================
    
    func setupCurrentActiveTask(withIndex num: Int, completion: @escaping ()->()) {
        print("WeekviewTasksVC : setupCurrentActiveTask ❗️")
        
        guard let weekdayArr = Helper.shared.getWeekdayArr(), let taskNoArr = Helper.shared.getTasksArr() else {
            print("setupCurrentActiveTask ❌")
            return
        }
        
        
        
//        var wdArr = weekdayArr
//        var tnArr = taskNoArr
        
//        AWSMobileHubClientManager.shared.getUserPoolDetail {
//            if let custom = KeychainSwift().get(KC_CUSTOM_START_DATE) {
//                let current = Helper.shared.getCurrentDateStr()
//                if let diff = Helper.shared.getNumOfDaysBetweenTwoDates(date1Str: current, date2Str: custom) {
//                    if diff > 6 {
//                        if wdArr[0] == 7 {
//                            wdArr.removeFirst()
//                            wdArr.removeFirst()
//                            wdArr.append(7)
//                            wdArr.append(1)
//                            
//                            tnArr.removeFirst()
//                            tnArr.removeFirst()
//                            tnArr.append(-1)
//                            tnArr.append(-1)
//                            
//                        } else if wdArr[0] == 1 {
//                            wdArr.removeFirst()
//                            wdArr.append(1)
//                            
//                            tnArr.removeFirst()
//                            tnArr.append(-1)
//                        }
//                    }
//                    
//                    print("wdArr ✅ \(wdArr)")
//                    UserDefaults.standard.set(wdArr, forKey: UD_USER_DATA_WEEKDAYS_ARRAY)
//                    UserDefaults.standard.set(tnArr, forKey: UD_USER_DATA_TASKS_ARRAY)
//                    
//                    var i = 0
//                    
//                    for item in tnArr {
//                        
//                        if item == num {
//                            if wdArr[i] != 7 && wdArr[i] != 1 {
//                                self.activeTaskIndexInTableView = i
//                            }
//                        }
//                        
//                        i += 1
//                    }
//                    
//                    
//                    self.currentSelectedCell = self.activeTaskIndexInTableView
//                    self.previousSelectedCell = self.activeTaskIndexInTableView
//                    self.isSameSelectedCell = false
//                    print("activeTaskIndexInTableView: \(self.activeTaskIndexInTableView)")
//                    
//                    completion()
//                    
//                }
//            }
//        }
        
        
        
                var i = 0
        
                for item in taskNoArr {
        
                    if item == num {
                        if weekdayArr[i] != 7 && weekdayArr[i] != 1 {
                            self.activeTaskIndexInTableView = i
                        }
                    }
        
                    i += 1
                }
        
        
                self.currentSelectedCell = self.activeTaskIndexInTableView
                self.previousSelectedCell = self.activeTaskIndexInTableView
                self.isSameSelectedCell = false
                print("activeTaskIndexInTableView: \(self.activeTaskIndexInTableView)")
        
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
        
        AWSMobileHubClientManager.shared.queryUserAnalytics {
            
            let maxDaysInRowInt = Int(KeychainSwift().get(KC_ANALYTICS_MAX_DAYS_IN_ROW)!)!
            
            AWSMobileHubClientManager.shared.scanTasks(startContent: maxDaysInRowInt, endContent: maxDaysInRowInt+4) {
                
                self.setupCurrentActiveTask(withIndex: maxDaysInRowInt) {
                    DispatchQueue.main.async {
                        self.setupTableView()
                        print("❗️❗️ ❗️ activeTaskIndexInTableView: \(self.activeTaskIndexInTableView)")
                        
                        completion()
                    }
                }
            }
        }
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
            
//            print("cellForRowAt ✅ taskNoArr: \(taskNoArr), weekdayArr: \(weekdayArr)")
            
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
