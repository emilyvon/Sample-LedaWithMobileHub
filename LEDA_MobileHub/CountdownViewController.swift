//
//  CountdownViewController.swift
//  LEDA
//
//  Created by Mengying Feng on 23/11/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol CountdownViewControllerDelegate {
    @objc optional func dismissVC(vc: CountdownViewController)
    @objc optional func showQuizVC(taskNo: Int)
    
}

class CountdownViewController: UIViewController {
    
    //========================================
    // MARK: - Outlets
    //========================================
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var taskTypeLabel: UILabel!
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var bgImageView: UIImageView!
    @IBOutlet weak var progressBgView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    //========================================
    // MARK: - Properties
    //========================================
    var videoHashId: String!
    var selectedTaskNo: Int?
    var selectedContentDayNo: Int?
    var selectedTaskType: String!
    var finishedTaskType: String!
    var finishedTaskNo: Int?
    var countdownViewControllerDelegate: CountdownViewControllerDelegate?
    
    var countdownNo = 0
    
    var timer: Timer = Timer()
    
    var avPlayer: AVPlayer!
    var avPlayerViewController: CustomVideoPlayerViewController!
    
    
    //========================================
    // MARK: - View Lifecycles
    //========================================
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("UserData.shared.currentContentDay: \(UserData.shared.currentContentDay), UserData.shared.currentTaskNo: \(UserData.shared.currentTaskNo)")
        
        countdownLabel.text = "Starting in 5 seconds"
        
        if let content = Helper.shared.getCurrentTask(contentDay: UserData.shared.currentContentDay, task: UserData.shared.currentTaskNo) {
            
            if content.taskType == TaskType.Video.rawValue {
                showVideoUI()
            } else if content.taskType == TaskType.Quiz.rawValue {
                showQuizUI()
            } else if content.taskType == TaskType.Checkoff.rawValue {
                showCheckoffUI()
            }
            
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        print("CountdownViewController ✅ selectedTaskNo: \(selectedTaskNo), selectedContentDayNo: \(selectedContentDayNo), selectedTaskType: \(selectedTaskType)")
        
        if UserData.shared.currentTaskNo < 4 {
            
            countdownNo = 4
            
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(segueToOtherVC), userInfo: nil, repeats: true)
        }
    }
    
    
    @IBAction func dismissBtnPressed(_ sender: UIButton) {
        timer.invalidate()
        dismiss(animated: true, completion: nil)
    }
    
    func segueToOtherVC() {
        print(countdownNo)
        
        countdownLabel.text = "Starting in \(countdownNo) seconds"
        
        if countdownNo > 0 {
            
            countdownNo -= 1
            
        } else {
            timer.invalidate()
            
            print("UserData.shared.currentContentDay: \(UserData.shared.currentContentDay), UserData.shared.currentTaskNo: \(UserData.shared.currentTaskNo)")
            
            if let userTask = Helper.shared.getCurrentTask(contentDay: UserData.shared.currentContentDay, task: UserData.shared.currentTaskNo) {
                
                if userTask.taskType == TaskType.Video.rawValue {
                    showVideo()
                } else if userTask.taskType == TaskType.Quiz.rawValue {
                    showQuiz(dayNo: UserData.shared.currentContentDay)
                } else if userTask.taskType == TaskType.Checkoff.rawValue {
                    showCheckoff()
                } else {
                    let alert = UIAlertController(title: "Error", message: "Task type unknow", preferredStyle: UIAlertControllerStyle.alert)
                    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (alertAction) in
                        self.dismiss(animated: true, completion: nil)
                    })
                    alert.addAction(action)
                    present(alert, animated: true, completion: nil)
                }
                
                
                
                
            }
            
            
            
            
        }
    }
    
    func showVideo() {
//        avPlayerViewController = CustomVideoPlayerViewController()
//        present(avPlayerViewController, animated: true, completion: nil)
        
        performSegue(withIdentifier: "countdownToCustomVideoPlayer", sender: nil)
    }
    
    func videoDidEnd() {
        
        print("videDidEnd ❗️ ")
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "GiveRatingViewController") as! GiveRatingViewController
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func showQuiz(dayNo: Int) {
        performSegue(withIdentifier: "countdownToQuiz", sender: nil)
    }
    
    func showCheckoff() {
        performSegue(withIdentifier: "countdownToDailyGoalCheckList", sender: nil)
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "countdownToQuiz" {
            
            let vc = segue.destination as! QuizViewController
            vc.quizViewControllerDelegate = self
            
        } else if segue.identifier == "countdownToDailyGoalCheckList" {
            let vc = segue.destination as! DailyGoalCheckListViewController
            vc.dailyGoalCheckListViewControllerDelegate = self
        }
    }
    
    
    
    func showVideoUI() {
        if let content = Helper.shared.getCurrentTask(contentDay: UserData.shared.currentContentDay, task: UserData.shared.currentTaskNo) {
            taskTitleLabel.text = content.taskTitle
            taskTypeLabel.text = content.taskType.capitalized
            endTimeLabel.text = Helper.shared.formatTime(withDuration: content.taskDuration)
        }
        
        
        backgroundView.backgroundColor = UIColor(red: 64/255, green: 191/255, blue: 233/255, alpha: 1.0)
        taskTypeLabel.textColor = UIColor.white
        taskTitleLabel.textColor = UIColor.white
        countdownLabel.textColor = UIColor.white
        bgImageView.image = UIImage(named: "line-Characters_transparent")
        progressBgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        startTimeLabel.textColor = UIColor.white
        endTimeLabel.textColor = UIColor.white
        
    }
    
    func showQuizUI() {
        
        if let content = Helper.shared.getCurrentTask(contentDay: UserData.shared.currentContentDay, task: UserData.shared.currentTaskNo) {
            taskTitleLabel.text = content.taskTitle
            taskTypeLabel.text = content.taskType.capitalized
            endTimeLabel.text = Helper.shared.formatTime(withDuration: content.taskDuration)
        }

        backgroundView.backgroundColor = UIColor.white
        taskTypeLabel.textColor = UIColor(red: 64/255, green: 191/255, blue: 233/255, alpha: 1.0)
        taskTitleLabel.textColor = UIColor(red: 64/255, green: 191/255, blue: 233/255, alpha: 1.0)
        countdownLabel.textColor = UIColor(red: 64/255, green: 191/255, blue: 233/255, alpha: 1.0)
        bgImageView.image = nil
        progressBgView.backgroundColor = UIColor.white
        startTimeLabel.textColor = UIColor.black
        endTimeLabel.textColor = UIColor.black
    }
    
    
    func showCheckoffUI() {
        
        if let content = Helper.shared.getCurrentTask(contentDay: UserData.shared.currentContentDay, task: UserData.shared.currentTaskNo) {
            taskTitleLabel.text = content.taskTitle
            //            taskTypeLabel.text = content.taskType.capitalized
            taskTypeLabel.text = "Practice"
            endTimeLabel.text = Helper.shared.formatTime(withDuration: content.taskDuration)
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}

extension CountdownViewController: QuizViewControllerDelegate {
    
    func dismiss(vc: QuizViewController) {
        self.finishedTaskNo = selectedTaskNo
        print("CountdownViewController: QuizViewControllerDelegate ❗️ \(selectedTaskNo)")
        vc.dismiss(animated: false, completion: nil)
//        countdownViewControllerDelegate?.dismissVC!(vc: self)
    }
    
    func pauseQuiz(vc: QuizViewController) {
        vc.dismiss(animated: true, completion: {
            
            self.dismiss(animated: false, completion: nil)
        })
    }
    
}


extension CountdownViewController: DailyGoalCheckListViewControllerDelegate {
    
    func dismissDailyGoalCheckList(vc: DailyGoalCheckListViewController) {
        vc.dismiss(animated: false, completion: {
            Helper.shared.areThreeCurrentTasksCompleted = true
            self.dismiss(animated: false, completion: {
                
            })
        })
    }
    
}
