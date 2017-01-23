//
//  DailyGoalCheckListTableViewCell.swift
//  LEDA
//
//  Created by Hao on 24/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit

class DailyGoalCheckListTableViewCell: UITableViewCell {
    @IBOutlet var dailyGoalItemLabel: UILabel!
    @IBOutlet var dailyGoalToggleBtn: UIButton!
    var isTicked: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        dailyGoalToggleBtn.layer.cornerRadius = dailyGoalToggleBtn.frame.width/2
        dailyGoalToggleBtn.layer.backgroundColor = UIColor.white.cgColor
    }

    @IBAction func toggleClicked(_ sender: UIButton) {
        print("toggle button clicked")
        isTicked = !isTicked
        updateToggleImage()
        NotificationCenter.default.post(name: NSNotification.Name("postButtonTag"), object: nil, userInfo: ["tag": dailyGoalToggleBtn.tag])
    }
    
    func configureCell(itemText: String, row: Int) {
        dailyGoalItemLabel.text = itemText
        dailyGoalToggleBtn.tag = row
    }
    
    func updateToggleImage() {
        if isTicked {
            dailyGoalToggleBtn.setImage(UIImage(named: "tick_selected"), for: .normal)
        }else{
            dailyGoalToggleBtn.setImage(UIImage(named: "tick_unselected"), for: .normal)
        }
    }
}
