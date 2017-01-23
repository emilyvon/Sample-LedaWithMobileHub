//
//  WeekviewTaskTableViewCell.swift
//  LEDA
//
//  Created by Mengying Feng on 15/1/17.
//  Copyright © 2017 Andrew Osborne. All rights reserved.
//

import UIKit

class WeekviewTaskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var taskNoLabel: UILabel!
    @IBOutlet weak var weekdayStrLabel: UILabel!
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var bottomContainerView: UIView!
    @IBOutlet weak var icon1ImageView: UIImageView!
    @IBOutlet weak var icon2ImageView: UIImageView!
    @IBOutlet weak var icon3ImageView: UIImageView!
    @IBOutlet weak var description1Label: UILabel!
    @IBOutlet weak var description2Label: UILabel!
    @IBOutlet weak var description3Label: UILabel!
    @IBOutlet weak var weekendImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func configureCell(weekdayNo: Int, currentActiveTaskNo: Int, taskNo: Int, tableIndex: Int) {
        
        print("weekdayNo: \(weekdayNo), currentActiveTaskNo: \(currentActiveTaskNo), taskNo: \(taskNo)")
        
        weekdayStrLabel.text = Helper.shared.weekdayConverter(weekday: weekdayNo)
        taskNoLabel.text = "\(taskNo+1)"
        
        setupCommonUI(isWeekend: weekdayNo == 7 || weekdayNo == 1 ? true : false)
        
        if weekdayNo == 7 || weekdayNo == 1 {
            // weekend: back ground color white
            topContainerView.backgroundColor = UIColor.white
            bottomContainerView.backgroundColor = UIColor.white
            
        } else {
            // weekday
            if /*weekdayNo*/tableIndex == currentActiveTaskNo {
                // active task: dark blue background color
                topContainerView.backgroundColor = UIColor(red: 100/255, green: 203/255, blue: 236/255, alpha: 1.0)
                bottomContainerView.backgroundColor = UIColor(red: 100/255, green: 203/255, blue: 236/255, alpha: 1.0)
                
                setupLabelsAndIcons(taskNo: taskNo, isActive: true)
                
            } else {
                // inactive task: light blue background color
                topContainerView.backgroundColor = UIColor(red: 219/255, green: 234/255, blue: 234/255, alpha: 1.0)
                bottomContainerView.backgroundColor = UIColor(red: 219/255, green: 234/255, blue: 234/255, alpha: 1.0)
                
                setupLabelsAndIcons(taskNo: taskNo, isActive: false)
                
            }
            
            
        }
        
    }
    
    func setupLabelsAndIcons(taskNo: Int, isActive: Bool) {
        
        let color = isActive ? UIColor.white : COLOR_LIGHT_BLUE
        let colorInt = isActive ? 0 : 1
        
        description1Label.textColor = color
        description2Label.textColor = color
        description3Label.textColor = color
        
        getTask(taskNo: taskNo, completion: { (tasks) in
            for (k,v) in tasks {
                
                if k.contains("task1") {
                    description1Label.text = v.taskTitle
                    icon1ImageView.image = Helper.shared.getTypeIconImage(color: colorInt, type: v.taskType)
                } else if k.contains("task2") {
                    description2Label.text = v.taskTitle
                    icon2ImageView.image = Helper.shared.getTypeIconImage(color: colorInt, type: v.taskType)
                } else if k.contains("task3") {
                    description3Label.text = v.taskTitle
                    icon3ImageView.image = Helper.shared.getTypeIconImage(color: colorInt, type: v.taskType)
                }
            }
        })
        
    }
    
    func setupCommonUI(isWeekend: Bool) {
        contentView.backgroundColor = UIColor(red: 251/255, green: 251/255, blue: 251/255, alpha: 1.0) // pretend cell separator -> very light gray background color
        
        taskNoLabel.isHidden = isWeekend
        icon1ImageView.isHidden = isWeekend
        icon2ImageView.isHidden = isWeekend
        icon3ImageView.isHidden = isWeekend
        description1Label.isHidden = isWeekend
        description2Label.isHidden = isWeekend
        description3Label.isHidden = isWeekend
        
        weekendImageView.isHidden = !isWeekend
    }
    
    
    func getTask(taskNo: Int, completion:([String : UserTask])->()) {
        
        if let decoded = UserDefaults.standard.object(forKey: UD_AVAILABLE_TASKS) as? Data, let tasksDict = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [Int: UserContent] {
            for task in tasksDict {
                if task.key == taskNo {
                    completion(task.value.tasks)
                }
            }
        }
    }
    
    
    
}
