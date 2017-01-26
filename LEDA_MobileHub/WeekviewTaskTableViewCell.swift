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
    @IBOutlet weak var weekendImageView: UIImageView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var subcategoryLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var lockedCoverView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func configureCell(weekdayNo: Int, currentActiveTaskNo: Int, taskNo: Int, tableIndex: Int) {
        
        print("weekdayNo: \(weekdayNo), currentActiveTaskNo: \(currentActiveTaskNo), taskNo: \(taskNo), tableIndex: \(tableIndex)")
        
        weekdayStrLabel.text = Helper.shared.weekdayConverter(weekday: weekdayNo)
        taskNoLabel.text = "\(taskNo+1)"
        
        setupCommonUI(isWeekend: weekdayNo == 7 || weekdayNo == 1 ? true : false)
        
        // set up icon
        if let diff = UserDefaults.standard.object(forKey: "NumOfTasksUnlocked") as? Int {
            
            if diff == taskNo {
                iconImageView.image = UIImage(named: "Play")
                lockedCoverView.isHidden = true
            } else if diff < taskNo {
                iconImageView.image = UIImage(named: "Locked")
                lockedCoverView.isHidden = false
            } else {
                iconImageView.image = UIImage(named: "Play")
                lockedCoverView.isHidden = true
            }
        }
        
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
        
        categoryLabel.textColor = color
        subcategoryLabel.textColor = color
        durationLabel.textColor = color
        
        
        
        getTask(taskNo: taskNo)
        
    }
    
    func setupCommonUI(isWeekend: Bool) {
        contentView.backgroundColor = UIColor(red: 251/255, green: 251/255, blue: 251/255, alpha: 1.0)
        
        taskNoLabel.isHidden = isWeekend
        
        categoryLabel.isHidden = isWeekend
        subcategoryLabel.isHidden = isWeekend
        durationLabel.isHidden = isWeekend
        iconImageView.isHidden = isWeekend
        
        weekendImageView.isHidden = !isWeekend
        
        
    }
    
    func getTask(taskNo: Int) {
        
        if let obj = KeychainSwift().getData("TaskArr"), let arr = NSKeyedUnarchiver.unarchiveObject(with: obj) as? [Task] {
            for item in arr {
                if item.taskDay == "\(taskNo)" && item.sort == "\(1)" {
                    categoryLabel.text = item.taskCategory.capitalized
                    subcategoryLabel.text = item.taskSubcategory.capitalized
                    
                    if let seconds = Int(item.taskDurationSeconds) {
                        durationLabel.text = "\(Int(seconds/60)):\(seconds%60) mins"
                    }
                }
            }
        }
    }
}
