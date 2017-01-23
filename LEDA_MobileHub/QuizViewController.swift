//
//  QuizViewController.swift
//  LEDA
//
//  Created by Mengying Feng on 17/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit
import AWSDynamoDB


protocol QuizViewControllerDelegate {
    func dismiss(vc: QuizViewController)
    func pauseQuiz(vc: QuizViewController)
}

class QuizViewController: UIViewController {
    
    
    
    var resultsDict = [String]()
    

    var currentSelectedUserTask: UserTask!
    var currentContentDayNo: Int!
    var currentDayTaskNo: Int!
    
    var selectedTaskNo: Int = 0
    
    var buttons = [QuizResultButton]()
    
    var quizViewControllerDelegate: QuizViewControllerDelegate?
    
    var totalScore: Int = 0
    var userResult: Double = 0.0
    var totalSeconds: Int = 0
    
    var totalTaskDuration = ""
    
    @IBOutlet var progressView: UIProgressView!
    var questionsArr = [String]()
    var index = 0
    
    
    @IBOutlet weak var questionLabel: UILabel!

    @IBOutlet weak var button0: QuizResultButton!
    @IBOutlet weak var button1: QuizResultButton!
    @IBOutlet weak var button2: QuizResultButton!
    @IBOutlet weak var button3: QuizResultButton!
    @IBOutlet weak var button4: QuizResultButton!
    
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buttons = [button0, button1, button2, button3, button4]
        
        progressView.setProgress(0.0, animated: false)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("UserData.shared.currentContentDay: \(UserData.shared.currentContentDay), UserData.shared.currentTaskNo: \(UserData.shared.currentTaskNo)")
        
        totalScore = 0
        
        if let content = Helper.shared.getCurrentTask(contentDay: UserData.shared.currentContentDay, task: UserData.shared.currentTaskNo) {
            totalTaskDuration = content.taskDuration
//            endTimeLabel.text = "\(Int(content.taskDuration)!/60):\(Int(content.taskDuration)!%60)"
            endTimeLabel.text = "\(Int(totalTaskDuration)!/60):\(Int(totalTaskDuration)!%60)"
            questionsArr = content.questions
        }
        button0.alpha = 0
        button1.alpha = 0
        button2.alpha = 0
        button3.alpha = 0
        button4.alpha = 0
        questionLabel.center.y += self.view.bounds.height
        button0.center.y += self.view.bounds.height
        button1.center.y += self.view.bounds.height
        button2.center.y += self.view.bounds.height
        button3.center.y += self.view.bounds.height
        button4.center.y += self.view.bounds.height
    }
    
    override func viewDidAppear(_ animated: Bool) {

        questionLabel.text = questionsArr.first
        
        UIView.animate(withDuration: 1.0, animations: {
            self.questionLabel.center.y -= self.view.bounds.height
            self.button0.center.y -= self.view.bounds.height
            self.button1.center.y -= self.view.bounds.height
            self.button2.center.y -= self.view.bounds.height
            self.button3.center.y -= self.view.bounds.height
            self.button4.center.y -= self.view.bounds.height
            self.button0.alpha = 1
            self.button1.alpha = 1
            self.button2.alpha = 1
            self.button3.alpha = 1
            self.button4.alpha = 1
        })
        
    }
    
    @IBAction func dismissPressed(_ sender: UIButton) {
        
//        dismiss(animated: true, completion: nil)
        quizViewControllerDelegate?.pauseQuiz(vc: self)
        
    }
    
    @IBAction func buttonPressed(_ sender: QuizResultButton) {
        
        // calculate scores
        totalScore += (sender.tag-1)
        resultsDict.append("\(sender.tag)")
        userResult = Double(totalScore)/Double((4 * questionsArr.count)) // userScore / highestScore
        
        // for deselecting other buttons once you select
        for button in buttons {
            
            if sender.tag != button.tag {
                
                button.isChecked = false
            }
        }
        
        // add
        index += 1
        progressView.setProgress(Float(index)/Float(questionsArr.count), animated: true)
        let duration = Double(135)/Double(25) * Double(index)
        startTimeLabel.text = "\(Int(duration)/60):\(Int(duration)%60)"
        endTimeLabel.text = "\((Int(totalTaskDuration)! - Int(duration))/60):\((Int(totalTaskDuration)! - Int(duration))%60)"

        if index < questionsArr.count{
            changeQuestions()
        } else {
            print("*** end of the quiz ***")
            
            // save resultsDict
//            guard let userTask = Helper.shared.getCurrentTask(contentDay: UserData.shared.currentContentDay, task: UserData.shared.currentTaskNo) else { return }
            
            guard let userContent = Helper.shared.getAvailableTask(taskNo: UserData.shared.currentContentDay) else { return }
            
            let tasks = userContent.tasks
            for task in tasks {
                print("UserData.shared.currentTaskNo 3❗️ \(UserData.shared.currentTaskNo)")
                
                if task.key.contains("task\(UserData.shared.currentTaskNo)") {
                    
                    if UserData.shared.userTaskResult == nil {
                        UserData.shared.userTaskResult = UserTaskResult(contentDayNo: Int(userContent.contentDay)!)
                    }
                    
                    var dayTask = DayTaskResult()
                    dayTask.type = task.value.taskType
                    dayTask.isComplete = true
                    dayTask.answers = resultsDict
                    dayTask.result = "\(userResult*100)"
                    dayTask.dateComplete = Helper.shared.getCurrentDateStr()
                    
                    UserData.shared.userDayTaskResultDict[task.key] = dayTask
                    
                    UserData.shared.userTaskResult?.isCompleted = UserData.shared.currentTaskNo < 3 ? false : true
                    UserData.shared.userTaskResult?.tasks = UserData.shared.userDayTaskResultDict
                    
                    
                    print("UserData.shared.userTaskResult 3 ❗️ \(UserData.shared.userTaskResult)")
                    
                    // save data to DB
                    if let result = UserData.shared.userTaskResult {
                        print("UserData.shared.userTaskResult 3 ✅")
                        AWSClientManager.shared.putUserTaskResult(userTaskResult: result)
                    } else {
                        print("UserData.shared.userTaskResult 3 ❌ \(UserData.shared.userTaskResult)")
                    }
                }
            }
            
            performSegue(withIdentifier: "showQuizResultSegue", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showQuizResultSegue" {
            let vc = segue.destination as! QuizResultViewController
            vc.quizScore = userResult
            vc.quizResultViewControllerDelegate = self
            
            print("segue : Quiz -> QuizResult ❗️ \(currentDayTaskNo) \(currentContentDayNo))")
        }
    }
    
    @IBAction func closeBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    func changeQuestions() {
        
        questionLabel.alpha = 0
        
        questionLabel.text = questionsArr[index]
        
        UIView.transition(with: questionLabel, duration: 0.5, options: [.curveEaseIn, .transitionFlipFromBottom], animations: {
            self.questionLabel.alpha = 1.0
        }, completion: nil)
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

}


extension QuizViewController: QuizResultViewControllerDelegate {
    func dismiss(vc: QuizResultViewController) {
        UserData.shared.isTask2Finished = true
        
        vc.dismiss(animated: false, completion: {
            self.quizViewControllerDelegate?.dismiss(vc: self)
        })
        
    }
}
