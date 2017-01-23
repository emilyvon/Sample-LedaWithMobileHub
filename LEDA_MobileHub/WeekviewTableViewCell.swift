//
//  WeekviewTableViewCell.swift
//  LEDA
//
//  Created by Mengying Feng on 7/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit


class WeekviewTableViewCell: UITableViewCell {
    
    //========================================
    // MARK: - Outlets
    //========================================
    
    @IBOutlet weak var closedView: UIView!
    @IBOutlet weak var expandedView: UIView!
    @IBOutlet weak var expandedViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    
    @IBOutlet weak var expandedDayLabel: UILabel!
    @IBOutlet weak var expandedWeekdayLabel: UILabel!
    
    @IBOutlet weak var watchLabel: UILabel!
    @IBOutlet weak var quizLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    
    @IBOutlet weak var videoIconImageView: UIImageView!
    @IBOutlet weak var quizIconImageView: UIImageView!
    @IBOutlet weak var goalIconImageView: UIImageView!
    
    @IBOutlet weak var expandedDayLabelTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var weekendTaskImageView: UIImageView!
    
    //    @IBOutlet weak var closedViewLockImageView: UIImageView!
    //    @IBOutlet weak var expandedViewLockImageView: UIImageView!
    
    //========================================
    // MARK: - Properties
    //========================================
    
    var isExpand = false
    
    var selectedImageName = ""
    
    //    override func draw(_ rect: CGRect) {
    //        super.draw(rect)
    
    // this works but for all the cells
    //        UIGraphicsBeginImageContext(self.expandedView.frame.size)
    //        UIImage(named: "dayBG")?.draw(in: self.expandedView.bounds)
    //        if let img = UIGraphicsGetImageFromCurrentImageContext() {
    //            UIGraphicsEndImageContext()
    //
    //            self.expandedView.backgroundColor = UIColor(patternImage: img)
    //        }
    //    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    // tuples : key -> day (4th), value -> weekday (6:friday)
    func configureCell(taskNo: Int,/* tuples: (key: Int, value: Int), tasksTuples: (Int, UserContent),currentTask: Int,*/ currentWeekday: Int/*, taskNoArr: Int*/) {
        
        print("configureCell ❗️taskNo: \(taskNo), currentWeekday: \(currentWeekday)")
        
//        dayLabel.text = "\(taskNoArr+1)"
//        expandedDayLabel.text = "\(taskNoArr+1)"

        dayLabel.text = "\(taskNo+1)"
        expandedDayLabel.text = "\(taskNo+1)"
        
        weekdayLabel.text = Helper.shared.weekdayConverter(weekday: currentWeekday)
        expandedWeekdayLabel.text = Helper.shared.weekdayConverter(weekday: currentWeekday)
        
        
        
        if let decoded = UserDefaults.standard.object(forKey: UD_AVAILABLE_TASKS) as? Data, let tasksDict = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [Int:UserContent] {
            
            let tasksArr = tasksDict.sorted(by: { (a, b) -> Bool in
                a.key < b.key
            })
            print("configureCell ❗️ \(tasksArr)")
            
            let currentActiveTaskNo = tasksArr[0].key // (FIXME: the first task for now)
            
            for task in tasksDict {
                
                if task.key == taskNo/*taskNoArr*/ {
                    
                    let tasks = task.value.tasks
                    
                    if taskNo == currentActiveTaskNo {
                        
                        if currentWeekday != 1 && currentWeekday != 7 {
                            
                            setCellAppearance(isActive: true, isWeekday: true, tasks: tasks)
                            
                            closedView.alpha = 0
                            expandedView.alpha = 1
                            expandedViewTopConstraint.constant = -8
                            
                            
                        } else {
                            
                            setCellAppearance(isActive: true, isWeekday: false, tasks: tasks)
                            
                        }
                        
                        /*
                        // current available task
                        isExpand = true
                        closedView.alpha = 1
                        expandedView.alpha = 1 // FIXME: should be 0
                        
                        if currentWeekday != 1 && currentWeekday != 7 {
                            // weekdays
                            // current available task: weekdays
                            // background darker blue & white texts
                            // don't show weekend image
                            
                            weekendTaskImageView.alpha = 0
                            
                            for (taskKey, taskValue) in tasks {
                                if taskKey.contains("task1") {
                                    watchLabel.text = taskValue.taskTitle
                                    videoIconImageView.image = Helper.shared.getTypeIconImage(color: 0, type: taskValue.taskType)
                                } else if taskKey.contains("task2") {
                                    quizLabel.text = taskValue.taskTitle
                                    quizIconImageView.image = Helper.shared.getTypeIconImage(color: 0, type: taskValue.taskType)
                                } else if taskKey.contains("task3") {
                                    goalLabel.text = taskValue.taskTitle
                                    goalIconImageView.image = Helper.shared.getTypeIconImage(color: 0, type: taskValue.taskType)
                                }
                            }
                        } else {
                            
                            // current available task: weekends
                            // show weekend image
                            // hide weekdays
                            
                            dayLabel.alpha = 0
                            expandedDayLabel.alpha = 0
                            
                            weekendTaskImageView.image = UIImage(named: "Weekend Image")
                            weekendTaskImageView.alpha = 1
                            
                            watchLabel.alpha = 0
                            quizLabel.alpha = 0
                            goalLabel.alpha = 0
                            
                            videoIconImageView.alpha = 0
                            quizIconImageView.alpha = 0
                            goalIconImageView.alpha = 0
                            
                            closedView.backgroundColor = UIColor.white
                            expandedView.backgroundColor = UIColor.white
                            
                            
                        }
                        */
                    } else {
                        
                        if currentWeekday != 1 && currentWeekday != 7 {
                            
                            setCellAppearance(isActive: false, isWeekday: true, tasks: tasks)
                            
                        } else {
                            
                            setCellAppearance(isActive: false, isWeekday: false, tasks: tasks)
                        }
                        
                        
                        /*
                        
                        // NOT current available tasks: lighter background & blue texts
                        
                        isExpand = false
                        closedView.alpha = 1
                        expandedView.alpha = 1
                        
                        if currentWeekday != 1 && currentWeekday != 7 {
                            // weekdays
                            
                            for (taskKey, taskValue) in tasks {
                                if taskKey.contains("task1") {
                                    watchLabel.text = taskValue.taskTitle
                                    videoIconImageView.image = Helper.shared.getTypeIconImage(color: 1, type: taskValue.taskType)
                                } else if taskKey.contains("task2") {
                                    quizLabel.text = taskValue.taskTitle
                                    quizIconImageView.image = Helper.shared.getTypeIconImage(color: 1, type: taskValue.taskType)
                                } else if taskKey.contains("task3") {
                                    goalLabel.text = taskValue.taskTitle
                                    goalIconImageView.image = Helper.shared.getTypeIconImage(color: 1, type: taskValue.taskType)
                                }
                            }
                            
                        } else {
                         // weekends
                            
                            dayLabel.alpha = 0
                            expandedDayLabel.alpha = 0
                            
                            weekendTaskImageView.image = UIImage(named: "Weekend Image")
                            weekendTaskImageView.alpha = 1
                            
                            watchLabel.alpha = 0
                            quizLabel.alpha = 0
                            goalLabel.alpha = 0
                            
                            videoIconImageView.alpha = 0
                            quizIconImageView.alpha = 0
                            goalIconImageView.alpha = 0
                            
                            closedView.backgroundColor = UIColor.white
                            expandedView.backgroundColor = UIColor.white

                            
                        }
                        
                        
                        
                    }
                    */
                }
                
                /*
                if currentWeekday == 1 || currentWeekday == 7 {
                    // weekends

                    // if taskNo is currently active day
                    if taskNo == currentActiveTaskNo {
                        isExpand = true
                        closedView.alpha = 0
                        expandedView.alpha = 1
                    } else {
                        isExpand = false
                        closedView.alpha = 1
                        expandedView.alpha = 0
                    }
                    
                    dayLabel.alpha = 0
                    expandedDayLabel.alpha = 0
                    
                    weekendTaskImageView.image = UIImage(named: "Weekend Image")
                    weekendTaskImageView.alpha = 1
                    
                    watchLabel.alpha = 0
                    quizLabel.alpha = 0
                    goalLabel.alpha = 0
                    
                    videoIconImageView.alpha = 0
                    quizIconImageView.alpha = 0
                    goalIconImageView.alpha = 0
                    
                    closedView.backgroundColor = UIColor.white
                    expandedView.backgroundColor = UIColor.white
                    
                    
                } else {
                    // weekdays
                    
                    // if taskNo is currently active day
                    if taskNo == currentActiveTaskNo {
                    
                        isExpand = true
                        closedView.alpha = 0
                        expandedView.alpha = 1
                        expandedViewTopConstraint.constant = -8
                        
                        watchLabel.textColor = UIColor.white
                        quizLabel.textColor = UIColor.white
                        goalLabel.textColor = UIColor.white
                        
                        closedView.backgroundColor = UIColor(red: 101/255, green: 201/255, blue: 235/255, alpha: 1.0)
                        expandedView.backgroundColor = UIColor(red: 101/255, green: 201/255, blue: 235/255, alpha: 1.0)
                        
                    } else {
                    
                        isExpand = false
                        
                        closedView.alpha = 1
                        expandedView.alpha = 0
                        
                        watchLabel.textColor = COLOR_LIGHT_BLUE
                        quizLabel.textColor = COLOR_LIGHT_BLUE
                        goalLabel.textColor = COLOR_LIGHT_BLUE
                        
                        closedView.backgroundColor = UIColor(red: 219/255, green: 234/255, blue: 234/255, alpha: 1.0)
                        expandedView.backgroundColor = UIColor(red: 219/255, green: 234/255, blue: 234/255, alpha: 1.0)
                        
                    }
                
                    dayLabel.alpha = 1
                    expandedDayLabel.alpha = 1
                    
                    weekendTaskImageView.alpha = 0
                    
                    watchLabel.alpha = 1
                    quizLabel.alpha = 1
                    goalLabel.alpha = 1
                    
                    videoIconImageView.alpha = 1
                    quizIconImageView.alpha = 1
                    goalIconImageView.alpha = 1
                }
                */
            }
        }
    }
    
    }

    func setCellAppearance(isActive: Bool, isWeekday: Bool, tasks: [String: UserTask]) {
        
        isExpand = isActive
        
        let visible = isWeekday ? CGFloat(1) : CGFloat(0)
        let invisible = isWeekday ? CGFloat(0) : CGFloat(1)
        
        weekendTaskImageView.alpha = invisible
        videoIconImageView.alpha = visible
        quizIconImageView.alpha = visible
        goalIconImageView.alpha = visible
        watchLabel.alpha = visible
        quizLabel.alpha = visible
        goalLabel.alpha = visible
        
        if isActive {
            
            if isWeekday {
                
                closedView.backgroundColor = UIColor(red: 101/255, green: 201/255, blue: 235/255, alpha: 1.0)
                expandedView.backgroundColor = UIColor(red: 101/255, green: 201/255, blue: 235/255, alpha: 1.0)
                
                watchLabel.textColor = UIColor.white
                quizLabel.textColor = UIColor.white
                goalLabel.textColor = UIColor.white
                
                for (taskKey, taskValue) in tasks {
                    if taskKey.contains("task1") {
                        watchLabel.text = taskValue.taskTitle
                        videoIconImageView.image = Helper.shared.getTypeIconImage(color: 0, type: taskValue.taskType)
                    } else if taskKey.contains("task2") {
                        quizLabel.text = taskValue.taskTitle
                        quizIconImageView.image = Helper.shared.getTypeIconImage(color: 0, type: taskValue.taskType)
                    } else if taskKey.contains("task3") {
                        goalLabel.text = taskValue.taskTitle
                        goalIconImageView.image = Helper.shared.getTypeIconImage(color: 0, type: taskValue.taskType)
                    }
                }
                
            } else {
                // weekend
                closedView.backgroundColor = UIColor.white
                expandedView.backgroundColor = UIColor.white
                
            }
            
        } else {
            // inactive
            if isWeekday {
                
                closedView.backgroundColor = UIColor(red: 219/255, green: 234/255, blue: 234/255, alpha: 1.0)
                expandedView.backgroundColor = UIColor(red: 219/255, green: 234/255, blue: 234/255, alpha: 1.0)
                
                watchLabel.textColor = COLOR_LIGHT_BLUE
                quizLabel.textColor = COLOR_LIGHT_BLUE
                goalLabel.textColor = COLOR_LIGHT_BLUE
                
                for (taskKey, taskValue) in tasks {
                    if taskKey.contains("task1") {
                        watchLabel.text = taskValue.taskTitle
                        videoIconImageView.image = Helper.shared.getTypeIconImage(color: 1, type: taskValue.taskType)
                    } else if taskKey.contains("task2") {
                        quizLabel.text = taskValue.taskTitle
                        quizIconImageView.image = Helper.shared.getTypeIconImage(color: 1, type: taskValue.taskType)
                    } else if taskKey.contains("task3") {
                        goalLabel.text = taskValue.taskTitle
                        goalIconImageView.image = Helper.shared.getTypeIconImage(color: 1, type: taskValue.taskType)
                    }
                }
                
            } else {
                
                closedView.backgroundColor = UIColor.white
                expandedView.backgroundColor = UIColor.white
                
            }
            
        }
    }
    
    
    
    
    
}
