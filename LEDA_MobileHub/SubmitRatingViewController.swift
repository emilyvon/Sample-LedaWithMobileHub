//
//  SubmitRatingViewController.swift
//  LEDA
//
//  Created by Hao on 24/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit

protocol SubmitRatingViewControllerDelegate {
    func dismiss(vc: SubmitRatingViewController)
}


class SubmitRatingViewController: UIViewController {
    
    let positiveFeedbacks = ["Simulating", "Informative", "Practical"]
    let negativeFeedbacks = ["Boring", "Laggy", "Irrelevant"]
    
    let positiveTitle = "What did you like?"
    let negativeTitle = "What didn't work?"
    var rating: Int = 0
    var button1Selected = false
    var button2Selected = false
    var button3Selected = false
    var selectedButtonTitle = ""
    var submitRatingDelegate: SubmitRatingViewControllerDelegate?
    
    @IBOutlet var ratingControl: RatingControl!


    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    @IBOutlet var titleLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
//        rating = 4
        ratingControl.rating = rating
        ratingControl.isUserInteractionEnabled = true
        
        if rating < 4 {
            titleLabel.text = negativeTitle
            button1.setTitle(negativeFeedbacks[0], for: .normal)
            button2.setTitle(negativeFeedbacks[1], for: .normal)
            button3.setTitle(negativeFeedbacks[2], for: .normal)
        }else {
            titleLabel.text = positiveTitle
            button1.setTitle(positiveFeedbacks[0], for: .normal)
            button2.setTitle(positiveFeedbacks[1], for: .normal)
            button3.setTitle(positiveFeedbacks[2], for: .normal)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateRatingValue), name: NSNotification.Name("RatingControlPressed"), object: nil)
        
        button1.layer.borderWidth = 0.5
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderWidth = 0.5
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderWidth = 0.5
        button3.layer.borderColor = UIColor.lightGray.cgColor
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("RatingControlPressed"), object: nil)
    }
    
    func updateRatingValue() {
        let r = ratingControl.rating
        print(r)

        
        if r < 4 {
            titleLabel.text = negativeTitle
            button1.setTitle(negativeFeedbacks[0], for: .normal)
            button2.setTitle(negativeFeedbacks[1], for: .normal)
            button3.setTitle(negativeFeedbacks[2], for: .normal)
        }else {
            titleLabel.text = positiveTitle
            button1.setTitle(positiveFeedbacks[0], for: .normal)
            button2.setTitle(positiveFeedbacks[1], for: .normal)
            button3.setTitle(positiveFeedbacks[2], for: .normal)
        }
        
    }
    

    @IBAction func submitClicked(_ sender: UIButton) {
        print("feedback submited")
        //        self.present(self.parentVC, animated: true, completion: nil)
        
        // save video's rating
        guard let userContent = Helper.shared.getAvailableTask(taskNo: UserData.shared.currentContentDay) else { return }
        
        let tasks = userContent.tasks
        for task in tasks {
            
            if task.key.contains("task\(UserData.shared.currentTaskNo - 1)") {
                UserData.shared.userDayTaskResultDict[task.key]?.rating = "\(ratingControl.rating)"
                UserData.shared.userDayTaskResultDict[task.key]?.adjective = selectedButtonTitle
                
                UserData.shared.userTaskResult?.tasks = [task.key: UserData.shared.userDayTaskResultDict[task.key]!]
                
                print("UserData.shared.userTaskResult 2 ❗️ \(UserData.shared.userTaskResult)")
                
                // save data to DB
                if let result = UserData.shared.userTaskResult {
                    print("UserData.shared.userTaskResult 2 ✅")
                    AWSClientManager.shared.putUserTaskResult(userTaskResult: result)
                } else {
                    print("UserData.shared.userTaskResult 2 ❌ \(UserData.shared.userTaskResult)")
                }
            }
            
        }
        
        submitRatingDelegate?.dismiss(vc: self)
    }

    
    @IBAction func skipClicked(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func button1Clicked(_ sender: UIButton) {
        button1Selected = !button1Selected
        if button1Selected {
            selectedButtonTitle = (button1.titleLabel?.text)!
            button2Selected = false
            button3Selected = false
        }
        updateButtons()
        
    }
    
    @IBAction func button2Clicked(_ sender: UIButton) {
        button2Selected = !button2Selected
        if button2Selected {
            selectedButtonTitle = (button2.titleLabel?.text)!
            button1Selected = false
            button3Selected = false
        }
        updateButtons()
    }
    
    @IBAction func button3Clicked(_ sender: UIButton) {
        button3Selected = !button3Selected
        if button3Selected {
            selectedButtonTitle = (button3.titleLabel?.text)!
            button1Selected = false
            button2Selected = false
        }
        updateButtons()
    }
    
    func updateButtons() {
        
        setButtonAppearance(isButtonSelected: button1Selected, button: button1)
        setButtonAppearance(isButtonSelected: button2Selected, button: button2)
        setButtonAppearance(isButtonSelected: button3Selected, button: button3)
        
        /*
        if button1Selected {
            button1.layer.borderWidth = 0
            button1.backgroundColor = UIColor(red: 64/255, green: 191/255, blue: 233/255, alpha: 1.0)
            button1.setTitleColor(UIColor.white, for: .normal)
        }else{
            button1.layer.borderWidth = 0.5
            button1.layer.borderColor = UIColor.gray.cgColor
            button1.backgroundColor = UIColor.white
            button1.setTitleColor(UIColor(red: 64/255, green: 191/255, blue: 233/255, alpha: 1.0), for: .normal)
        }
        if button2Selected {
            button2.layer.borderWidth = 0
            button2.backgroundColor = UIColor(red: 64/255, green: 191/255, blue: 233/255, alpha: 1.0)
            button2.setTitleColor(UIColor.white, for: .normal)
        }else{
            button2.layer.borderWidth = 0.5
            button2.layer.borderColor = UIColor.gray.cgColor
            button2.backgroundColor = UIColor.white
            button2.setTitleColor(UIColor(red: 64/255, green: 191/255, blue: 233/255, alpha: 1.0), for: .normal)
        }
        if button3Selected {
            button3.layer.borderWidth = 0
            button3.backgroundColor = UIColor(red: 64/255, green: 191/255, blue: 233/255, alpha: 1.0)
            button3.setTitleColor(UIColor.white, for: .normal)
        }else{
            button3.layer.borderWidth = 0.5
            button3.layer.borderColor = UIColor.gray.cgColor
            button3.backgroundColor = UIColor.white
            button3.setTitleColor(UIColor(red: 64/255, green: 191/255, blue: 233/255, alpha: 1.0), for: .normal)
        }
        */
    }
    
    func setButtonAppearance(isButtonSelected: Bool, button: UIButton) {
        if isButtonSelected {
            button.layer.borderWidth = 0
            button.backgroundColor = UIColor(red: 64/255, green: 191/255, blue: 233/255, alpha: 1.0)
            button.setTitleColor(UIColor.white, for: .normal)
        } else {
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.gray.cgColor
            button.backgroundColor = UIColor.white
            button.setTitleColor(UIColor(red: 64/255, green: 191/255, blue: 233/255, alpha: 1.0), for: .normal)
        }
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}
