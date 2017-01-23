//
//  DailyGoalCheckListViewController.swift
//  LEDA
//
//  Created by Hao on 24/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit
import AWSDynamoDB

protocol DailyGoalCheckListViewControllerDelegate {
    func dismissDailyGoalCheckList(vc: DailyGoalCheckListViewController)
}

class DailyGoalCheckListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var dayCountLabel: UILabel!
    
    @IBOutlet var dayOfWeekLabel: UILabel!
    
    @IBOutlet var checkListTableView: UITableView!
    
    
    var selectedCheckoffList = [String]()
    
    var selectedCheckoffListResult = [Bool]()
    
    var currentContentDayNo: Int!
    var currentDayTaskNo: Int!
    
    var dailyGoalCheckListViewControllerDelegate: DailyGoalCheckListViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkListTableView.delegate = self
        checkListTableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("UserData.shared.currentContentDay: \(UserData.shared.currentContentDay), UserData.shared.currentTaskNo: \(UserData.shared.currentTaskNo)")
        
        NotificationCenter.default.addObserver(self, selector: #selector(observeButtonTag(notification:)), name: NSNotification.Name("postButtonTag"), object: nil)
        
        if let content = Helper.shared.getCurrentTask(contentDay: UserData.shared.currentContentDay, task: UserData.shared.currentTaskNo) {
            
            selectedCheckoffList += content.items
            
            for _ in 0..<selectedCheckoffList.count {
                selectedCheckoffListResult.append(false)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("postButtonTag"), object: nil)
    }
    
    func observeButtonTag(notification: Notification) {
        print("!!!")
        if let userInfo = notification.userInfo, let buttonTag = userInfo["tag"] as? Int {
            if let cell = checkListTableView.cellForRow(at: IndexPath(row: buttonTag, section: 0)) as? DailyGoalCheckListTableViewCell {
                selectedCheckoffListResult[buttonTag] = cell.isTicked
                print(selectedCheckoffListResult)
            }
        }
    }
    
    @IBAction func closeBtnPressed(_ sender: UIButton) {
        print("DailyGoalCheckListViewController : closeBtnPressed ❗️")
        
        
        let filteredArr = selectedCheckoffListResult.filter { !$0 }
        
        if filteredArr.count > 0 {
            // at least one item is false, dismiss and don't save, don't increase task number
            
            let alert = UIAlertController(title: "", message: "Remember to check off all items to finish the daily task", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: {
                
                // save all items as false and is_complete = false
                guard let userContent = Helper.shared.getAvailableTask(taskNo: UserData.shared.currentContentDay) else { return }
                
                let tasks = userContent.tasks
                for task in tasks {
                    
                    print("UserData.shared.currentTaskNo 4❗️ \(UserData.shared.currentTaskNo)")
                    
                    if task.key.contains("task\(UserData.shared.currentTaskNo)") {
                        
                        if UserData.shared.userTaskResult == nil {
                            UserData.shared.userTaskResult = UserTaskResult(contentDayNo: Int(userContent.contentDay)!)
                        }
                        
                        var dayTask = DayTaskResult()
                        dayTask.type = task.value.taskType
                        dayTask.isComplete = false
                        dayTask.items = self.selectedCheckoffListResult
                        
                        UserData.shared.userDayTaskResultDict[task.key] = dayTask
                        
                        UserData.shared.userTaskResult?.tasks = UserData.shared.userDayTaskResultDict
                        UserData.shared.userTaskResult?.isCompleted = false
                        
                        if let result = UserData.shared.userTaskResult {
                            print("UserData.shared.userTaskResult 4 ✅")
                            AWSClientManager.shared.putUserTaskResult(userTaskResult: result)
                        } else {
                            print("UserData.shared.userTaskResult 4 ❌ \(UserData.shared.userTaskResult)")
                        }
                    }
                }
                
                UserData.shared.isTask3Finished = false
                UserData.shared.currentTaskNo += 1
                
                
                
                
                self.dailyGoalCheckListViewControllerDelegate?.dismissDailyGoalCheckList(vc: self)
                self.dismiss(animated: true, completion: nil)
            })
            
        } else {
            // if all items are true, save task3
            guard let userContent = Helper.shared.getAvailableTask(taskNo: UserData.shared.currentContentDay) else { return }
            
            let tasks = userContent.tasks
            for task in tasks {
                
                print("UserData.shared.currentTaskNo 4❗️ \(UserData.shared.currentTaskNo)")
                
                if task.key.contains("task\(UserData.shared.currentTaskNo)") {
                    
                    if UserData.shared.userTaskResult == nil {
                        UserData.shared.userTaskResult = UserTaskResult(contentDayNo: Int(userContent.contentDay)!)
                    }
                    
                    var dayTask = DayTaskResult()
                    dayTask.type = task.value.taskType
                    dayTask.isComplete = true
                    dayTask.items = selectedCheckoffListResult
                    
                    UserData.shared.userDayTaskResultDict[task.key] = dayTask
                    
                    UserData.shared.userTaskResult?.tasks = UserData.shared.userDayTaskResultDict
                    UserData.shared.userTaskResult?.isCompleted = UserData.shared.currentTaskNo < 3 ? false : true
                    UserData.shared.userTaskResult?.isCheckedOff = true
                    
                    if let result = UserData.shared.userTaskResult {
                        print("UserData.shared.userTaskResult 4 ✅")
                        AWSClientManager.shared.putUserTaskResult(userTaskResult: result)
                    } else {
                        print("UserData.shared.userTaskResult 4 ❌ \(UserData.shared.userTaskResult)")
                    }
                }
            }
            
            UserData.shared.isTask3Finished = true
            UserData.shared.currentTaskNo += 1
            
            self.dailyGoalCheckListViewControllerDelegate?.dismissDailyGoalCheckList(vc: self)
            
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCheckoffList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "dailyGoalCheckListTableCell", for: indexPath) as? DailyGoalCheckListTableViewCell {
            
            cell.configureCell(itemText: selectedCheckoffList[indexPath.row], row: indexPath.row)
            
            return cell
        }
        return UITableViewCell()
    }
    
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}
