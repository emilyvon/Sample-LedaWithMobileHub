//
//  WeekviewViewController.swift
//  LEDA
//
//  Created by Mengying Feng on 7/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

/*
import UIKit
import AWSDynamoDB


protocol WeekviewViewControllerDelegate {
    //    func selectedDate(selectedDateTuple: (key: Int, value: Int), taskTuple: (Int, UserContent))
    
    func displaySelectedTask(num: Int, weekday: Int, vc: WeekviewViewController)
}

class WeekviewViewController: UIViewController {
    
    //========================================
    // MARK: - Properties
    //========================================
    
    let ESTIMATED_ROW_HEIGHT: CGFloat = 125
    
    var availableWeeks = 75
    var currentSelectedRow = -1
    var previousSelectedRow = -1
    var isSameSelectedCell = false
    
    var selectedDateTuple = (key: 0, value: 0)
    var selectedtaskTuple: (key: Int, value: UserContent)?
    
    var dateArrTuples = [(key: Int, value: Int)]() // key is day, value is weekday in number
    
    var weekviewViewControllerDelegate: WeekviewViewControllerDelegate?
    
    var taskNumCount: Int = 0
    var weekendCount: Int = 0
    
    let transition = PopAnimator()
    var selectedIndexPath: IndexPath?
    
    var cellRectBeforeExpanding: CGRect!
    
    
    //========================================
    // MARK: - Outlets
    //========================================
    
    @IBOutlet weak var tableView: UITableView!
    
    //========================================
    // MARK: - View lifecycles
    //========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup tableview
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = ESTIMATED_ROW_HEIGHT
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    @IBAction func dismissPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //========================================
    // MARK: - Private methods
    //========================================
    
    func expandCurrentCell(selectedIndex: Int) {
        if let cell = tableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? WeekviewTableViewCell {
            cell.isExpand = true
            cell.closedView.alpha = 0
            cell.expandedView.alpha = 1
            cell.expandedViewTopConstraint.constant = -8
            
                cell.expandedView.layoutIfNeeded()
            

        }
    }
    
    func closeCurrentCell(selectedIndex: Int) {
        if let cell = tableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? WeekviewTableViewCell {
            if selectedIndex != 0 { // FIXME: selectedIndex != daysInRow...
                cell.isExpand = false
                cell.closedView.alpha = 1
                cell.expandedView.alpha = 0
                cell.expandedViewTopConstraint.constant = ESTIMATED_ROW_HEIGHT
                
                    cell.expandedView.layoutIfNeeded()
                

            }
        }
    }
    
    func closeOtherCells(selectedIndex: Int) {
        for i in 0 ..< availableWeeks {
            if let cell = tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? WeekviewTableViewCell {
                if i != selectedIndex {
                    if selectedIndex != 0 { // FIXME: selectedIndex != daysInRow...
                        cell.isExpand = false
                        cell.closedView.alpha = 1
                        cell.expandedView.alpha = 0
                        cell.expandedViewTopConstraint.constant = ESTIMATED_ROW_HEIGHT
                            cell.expandedView.layoutIfNeeded()
                        
                        
                    }
                }
            }
        }
    }
    
    func isCurrentCellExpand(selectedIndex: Int) -> Bool {
        if let cell = tableView.cellForRow(at: IndexPath(row: selectedIndex, section: 0)) as? WeekviewTableViewCell {
            return cell.isExpand
        }
        return false
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}

//========================================
// MARK: - Table view data source
//========================================
extension WeekviewViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let arr = UserDefaults.standard.object(forKey: UD_USER_DATA_TASKS_ARRAY) as? [Int] {
            let currentDate = Helper.shared.getCurrentDateStr()
            if let startDate = KeychainSwift().get(KC_CUSTOM_START_DATE) {
                if let days = Helper.shared.getNumOfDaysBetweenTwoDates(date1Str: startDate, date2Str: currentDate) {
                    if days >= 5 {
                        return arr.count
                    } else {
                        return days
                    }
                }
            }
            
            
            
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("cellForRowAt ❗️ \(indexPath.row)")
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "WeekviewTableViewCell") as? WeekviewTableViewCell {
            
            if let weekdays = UserDefaults.standard.object(forKey: UD_USER_DATA_WEEKDAYS_ARRAY) as? [Int], let taskNoArr = UserDefaults.standard.object(forKey: UD_USER_DATA_TASKS_ARRAY) as? [Int] {
                
                cell.configureCell(taskNo: taskNoArr[indexPath.row], currentWeekday: weekdays[indexPath.row])
                
                return cell
            }
        }
        return UITableViewCell()
    }
}

//========================================
// MARK: - Table view delegate
//========================================
extension WeekviewViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndexPath = indexPath
        
        
        if UserData.shared.isTask1Finished && UserData.shared.isTask2Finished && UserData.shared.isTask3Finished {
            UserData.shared.userTaskResult = nil
            UserData.shared.userDayTaskResultDict = [String: DayTaskResult]()
            UserData.shared.isTask1Finished = false
            UserData.shared.isTask2Finished = false
            UserData.shared.isTask3Finished = false
        }
        
        
        Helper.shared.areThreeCurrentTasksCompleted = false
        
        previousSelectedRow = currentSelectedRow
        currentSelectedRow = indexPath.row
        
        
        guard let tasksArr = UserDefaults.standard.object(forKey: UD_USER_DATA_TASKS_ARRAY) as? [Int], let weekdays = UserDefaults.standard.object(forKey: UD_USER_DATA_WEEKDAYS_ARRAY) as? [Int] else { return }
        
        
        if indexPath.row == 0 {
            
//            weekviewViewControllerDelegate?.displaySelectedTask(num: tasksArr[indexPath.row], weekday: weekdays[indexPath.row], vc: self)
            

            let vc = storyboard!.instantiateViewController(withIdentifier: "DailyTasksViewController") as! DailyTasksViewController
            vc.transitioningDelegate = self
            present(vc, animated: true, completion: nil)
            
            
        } else {
            
            print("taskNo ❗️ \(tasksArr[indexPath.row])")
            
            if previousSelectedRow == -1 || indexPath.row != previousSelectedRow {
                // user selects a cell the first time, cell from closed to expaned
                expandCurrentCell(selectedIndex: indexPath.row)
                
                closeOtherCells(selectedIndex: indexPath.row)
                
            } else {
                // if cell is already expanded
                if isCurrentCellExpand(selectedIndex: indexPath.row) {
                    
                    UserData.shared.currentContentDay = tasksArr[indexPath.row]
                    
                    // if it's NOT Sat or Sun
                    //                    if weekdays[indexPath.row] != 1 && weekdays[indexPath.row] != 7 {
                    
                    // go to day view
                    
                    //                        if tasksArr[indexPath.row] == 0 {

                    
                    // temp out 1
//                    weekviewViewControllerDelegate?.displaySelectedTask(num: tasksArr[indexPath.row], weekday: weekdays[indexPath.row], vc: self)
                    
                    // temp out 2
                    let vc = storyboard!.instantiateViewController(withIdentifier: "DailyTasksViewController") as! DailyTasksViewController
                    vc.transitioningDelegate = self
                    present(vc, animated: true, completion: nil)

                    
                    
                    
                    //                        }
                    
                    //                    } else {
                    // it's Sat or Sun
                    //                        let selectedCell = tableView.cellForRow(at: indexPath) as! WeekviewTableViewCell
                    //                        selectedCellGifImageName = selectedCell.selectedImageName
                    //                        print("selectedCellGifImageName ✅ \(selectedCellGifImageName)")
                    
                    
                    /*
                     // temp out
                     if tasksArr[indexPath.row] == 0 {
                     // display weekend UI
                     self.performSegue(withIdentifier: "weekendviewToDayViewWeekend", sender: nil)
                     //                    closeCurrentCell(selectedIndex: indexPath.row)
                     }
                     */
                    
                    
                    
                    
                    //                        weekviewViewControllerDelegate?.displaySelectedTask(num: tasksArr[indexPath.row], weekday: weekdays[indexPath.row], vc: self)
                    
                    
                    
                    //                    }
                } else {
                    expandCurrentCell(selectedIndex: indexPath.row)
                }
            }
            
//            UIView.setAnimationsEnabled(false)
            tableView.beginUpdates()
            
            
            
            tableView.endUpdates()
//            UIView.setAnimationsEnabled(true)
            
            tableView.scrollToRow(at: IndexPath(row: indexPath.row, section: 0), at: UITableViewScrollPosition.middle, animated: true)
            
            
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 && currentSelectedRow == -1 { // FIXME: assuming the current active task = 0
            return UITableViewAutomaticDimension
        } else {
            if indexPath.row == currentSelectedRow {
                if currentSelectedRow != previousSelectedRow {
                    return UITableViewAutomaticDimension
                } else {
                    if let cell = tableView.cellForRow(at: IndexPath(row: currentSelectedRow, section: 0)) as? WeekviewTableViewCell {
                        
                        return !cell.isExpand ? ESTIMATED_ROW_HEIGHT : UITableViewAutomaticDimension
                        
                    } else {
                        return UITableViewAutomaticDimension
                    }
                }
            } else {
                return ESTIMATED_ROW_HEIGHT
            }
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}


extension WeekviewViewController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let cellRect = cellRectBeforeExpanding!
        let rectInSuperview = tableView.convert(cellRect, to: tableView.superview)
        transition.originFrame = rectInSuperview
        transition.presenting = true
        transition.isExpanding = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    
        transition.presenting = false
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.3) {
            
            self.isSameSelectedCell = false
            
            self.previousSelectedRow = -1
            
            let selectedCell = self.tableView.cellForRow(at: IndexPath(row: self.currentSelectedRow, section: 0))!
            
            UIView.animate(withDuration: 1.0) {
                
                selectedCell.contentView.layoutIfNeeded()
                
                
                
            }
            
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            
            
            self.tableView.scrollToRow(at: IndexPath(row: self.currentSelectedRow, section: 0), at: UITableViewScrollPosition.middle, animated: true)
        }
        
        
        
        
        return transition
    }
    
    
}
*/
