//
//  TestResultsTableViewCell.swift
//  LEDA
//
//  Created by Mengying Feng on 16/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit

class TestResultsTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    func configureCell(testResult: TestResults) {
        
        if let decoded = UserDefaults.standard.object(forKey: UD_AVAILABLE_TASKS) as? Data, let userContents = NSKeyedUnarchiver.unarchiveObject(with: decoded) as? [Int: UserContent] {
            
            for (k,v) in userContents {
                
                if testResult.taskNo.components(separatedBy: "_")[0] == "day\(k)" {
                    
                    if let title = v.tasks[testResult.taskNo]?.taskTitle {
                        titleLabel.text = title
                    }
                }
            }
        }
        
        if let timeDouble = Double(testResult.dateComplete) {

            let formatter = DateFormatter()
            
            formatter.dateFormat = "dd MMM yyyy"
            
            dateLabel.text = "\(formatter.string(from: Date(timeIntervalSince1970: timeDouble)))"
            
        }
        
    }
    
}
