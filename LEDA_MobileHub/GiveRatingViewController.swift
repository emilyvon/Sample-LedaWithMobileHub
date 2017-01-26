//
//  GiveRatingViewController.swift
//  LEDA
//
//  Created by Hao on 24/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit
//import WistiaKit

protocol GiveRatingViewControllerDelegate {
    func dismissGiveRating(vc: GiveRatingViewController)
}


class GiveRatingViewController: UIViewController {
    
    @IBOutlet var ratingControl: RatingControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var resultTitleLabel: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    
    var rating: Int = 0
    var hashedId: String?
    var giveRatingDelegate: GiveRatingViewControllerDelegate?
    var isRated = false
    
    var selectedButtonTitle = ""
    var selectedRating = 0
    
    let positiveFeedbacks = ["Simulating", "Informative", "Practical"]
    let negativeFeedbacks = ["Boring", "Laggy", "Irrelevant"]
    
    
    let positiveTitle = "What did you like?"
    let negativeTitle = "What didn't work?"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(catchNotification(notification:)), name: NSNotification.Name("RatingControlPressed"), object: nil)
        
    }
    
    func catchNotification(notification:Notification) -> Void {
        print("Rating: \(ratingControl.rating)")
        
        if (ratingControl.rating < 4 && selectedRating >= 4) || (ratingControl.rating >= 4 && selectedRating < 4) {
            setupButtons()
        }
        
        selectedRating = ratingControl.rating
        
        if ratingControl.rating < 4 {
            resultTitleLabel.text = negativeTitle
            button1.setTitle(negativeFeedbacks[0], for: .normal)
            button2.setTitle(negativeFeedbacks[1], for: .normal)
            button3.setTitle(negativeFeedbacks[2], for: .normal)
        } else {
            resultTitleLabel.text = positiveTitle
            button1.setTitle(positiveFeedbacks[0], for: .normal)
            button2.setTitle(positiveFeedbacks[1], for: .normal)
            button3.setTitle(positiveFeedbacks[2], for: .normal)
        }
        
        if !isRated {
            isRated = true
            UIView.animate(withDuration: 1.0) {
                self.titleLabel.center.y -= self.view.bounds.height
                self.descriptionLabel.center.y -= self.view.bounds.height
                self.ratingControl.center.y -= self.view.bounds.height * 0.6
                self.resultTitleLabel.center.y -= self.view.bounds.height
                self.button1.center.y -= self.view.bounds.height
                self.button2.center.y -= self.view.bounds.height
                self.button3.center.y -= self.view.bounds.height
                self.submitButton.center.y -= self.view.bounds.height
            }
            
        }
        
        // <<<
        //        guard let userInfo = notification.userInfo,
        //            let rate = userInfo["rating"] as? Int else {
        //                print("No userInfo found in notification")
        //                return
        //        }
        //        self.rating = rate
        //
        //        performSegue(withIdentifier: "ratingFeedbackSegue", sender: nil)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("UserData.shared.currentContentDay: \(UserData.shared.currentContentDay), UserData.shared.currentTaskNo: \(UserData.shared.currentTaskNo)")
        
        isRated = false
        ratingControl.center.y += self.view.bounds.height * 0.6
        resultTitleLabel.center.y += self.view.bounds.height
        button1.center.y += self.view.bounds.height
        button2.center.y += self.view.bounds.height
        button3.center.y += self.view.bounds.height
        submitButton.center.y += self.view.bounds.height
        
        setupButtons()
        
    }
    
    
    @IBAction func ratingButtonPressed(_ sender: UIButton) {
        
        if let title = sender.titleLabel?.text {
            print("button title: \(title)")
            selectedButtonTitle = title
        }
        
        let buttons = [button1, button2, button3]
        for button in buttons {
            if button!.tag == sender.tag {
                setButtonAppearance(isButtonSelected: true, button: button!)
            } else {
                setButtonAppearance(isButtonSelected: false, button: button!)
            }
        }
    }
    
    @IBAction func cancelClicked(_ sender: UIButton) {
        
        dismiss(animated: false) { 
            NotificationCenter.default.post(name: NSNotification.Name("ratingSubmitted"), object: nil)
        }
        
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
        print("\(UserData.shared.currentContentDay) , \(UserData.shared.currentTaskNo)")
        
        print("task\(UserData.shared.currentTaskNo)")
        print("task\(UserData.shared.currentTaskNo-1)")
        
        // save video's rating
        if let content = Helper.shared.getAvailableTask(taskNo: UserData.shared.currentContentDay) {
            
            let tasks = content.tasks
            
            for task in tasks {
                
                print("task: \(task)")
                
                print("task\(UserData.shared.currentTaskNo)")
                print("task\(UserData.shared.currentTaskNo-1)")
                if task.key.contains("task\(UserData.shared.currentTaskNo-1)") {
                    
                    print("??")
                    
                    UserData.shared.userDayTaskResultDict[task.key]?.rating = "\(ratingControl.rating)"
                    UserData.shared.userDayTaskResultDict[task.key]?.adjective = selectedButtonTitle
                    
                    UserData.shared.userTaskResult?.tasks = [task.key: UserData.shared.userDayTaskResultDict[task.key]!]
                    
                    print("UserData.shared.userTaskResult 2 ❗️ \(UserData.shared.userTaskResult)")
                    
                    // save data to DB
                    if let result = UserData.shared.userTaskResult {
                        print("UserData.shared.userTaskResult 2 ✅")
//                        AWSClientManager.shared.putUserTaskResult(userTaskResult: result)
                    } else {
                        print("UserData.shared.userTaskResult 2 ❌ \(UserData.shared.userTaskResult)")
                    }   
                }
            }
        }

        self.dismiss(animated: false, completion: {
        
            NotificationCenter.default.post(name: NSNotification.Name("ratingSubmitted"), object: nil)
            
        })
        
    }
    
    func setupButtons() {
        setButtonAppearance(isButtonSelected: false, button: button1)
        setButtonAppearance(isButtonSelected: false, button: button2)
        setButtonAppearance(isButtonSelected: false, button: button3)
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
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ratingFeedbackSegue"{
            let vc = segue.destination as! SubmitRatingViewController
            vc.rating = self.rating
            vc.submitRatingDelegate = self
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}

extension GiveRatingViewController : SubmitRatingViewControllerDelegate{
    func dismiss(vc: SubmitRatingViewController) {
        print("submit rating delegate catch")
        vc.dismiss(animated: false, completion: nil)
        giveRatingDelegate?.dismissGiveRating(vc: self)
    }
}
