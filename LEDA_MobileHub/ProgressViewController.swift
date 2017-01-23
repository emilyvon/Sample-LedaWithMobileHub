//
//  ProgressViewController.swift
//  LEDA
//
//  Created by Mengying Feng on 5/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ProgressViewController: UIViewController {
    
    //========================================
    // MARK: - Properties
    //========================================
    var testResults = [("Positive Appraisal", "24 Jan 2017"), ("Resilience", "25 Jan 2017")]
    //    var tapGesture: UITapGestureRecognizer!
    
    var selectedRow = -1
    
    //========================================
    // MARK: - Outlets
    //========================================
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var daysInRowCountLabel: UILabel!
    @IBOutlet weak var tasksCompletedCountLabel: UILabel!
    @IBOutlet weak var resilienceCountLabel: UILabel!
    @IBOutlet weak var growthCountLabel: UILabel!
    @IBOutlet weak var empathyCountLabel: UILabel!
    @IBOutlet weak var negotiationCountLabel: UILabel!
    
    @IBOutlet weak var complexEmotionsButton: UIButton!
    @IBOutlet weak var breathingExerciseButton: UIButton!
    @IBOutlet weak var makingMeaningButton: UIButton!
    
    @IBOutlet weak var actIntContainerView: UIView!
    //========================================
    // MARK: - View lifecycle
    //========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ProgressVC : viewDidLoad ✅")
        
        tableView.dataSource = self
        tableView.delegate = self
        
        scrollView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("ProgressVC : viewWillAppear ✅")
        
        displayData()
        
//        AWSClientManager.shared.registerDynamoDB {
            
            AWSClientManager.shared.queryTestResults {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.actIntContainerView.isHidden = true
                    
                }
            }
            
//        }
        
    }
    
    func displayData() {
        print("displayData ✅")
        
        let kc = KeychainSwift()
        
        // display analytics
        if let tasksCompleted = kc.get(KC_ANALYTICS_TASKS_COMPLETED) {
            tasksCompletedCountLabel.text = tasksCompleted
        }
        
        if let daysInRow = kc.get(KC_ANALYTICS_CURRENT_DAYS_IN_ROW) {
            daysInRowCountLabel.text = daysInRow
        }
        
        if let resilienceCount = kc.get(KC_ANALYTICS_RESILIENCE_COMPLETED) {
            resilienceCountLabel.text = resilienceCount
        }
        
        if let mindsetCount = kc.get(KC_ANALYTICS_MINDSET_COMPLETED) {
            growthCountLabel.text = mindsetCount
        }
        
        if let empathyCount = kc.get(KC_ANALYTICS_EMPATHY_COMPLETED) {
            empathyCountLabel.text = empathyCount
        }
        
        if let negoCount = kc.get(KC_ANALYTICS_NEGOTIATION_COMPLETED) {
            negotiationCountLabel.text = negoCount
        }
        
        // display tools
        if let emotionUnlocked = kc.getBool(KC_TOOLS_EMOTION_UNLOCKED) {
            print("emotionUnlocked ❗️ \(emotionUnlocked)")
            if emotionUnlocked {
                //                        self.complexEmotionsButton.backgroundColor = UIColor.clear
            } else {
                //                        self.complexEmotionsButton.backgroundColor = UIColor.white
                
                //                self.complexEmotionsButton.isUserInteractionEnabled = true
                
            }
        }
        
        if let breathingUnlocked = kc.getBool(KC_TOOLS_BREATHING_UNLOCKED) {
            print("breathingUnlocked ❗️ \(breathingUnlocked)")
            if breathingUnlocked {
                //                self.breathingExerciseButton.backgroundColor = UIColor.clear
                //                self.breathingExerciseButton.isUserInteractionEnabled = true
            } else {
                //                self.breathingExerciseButton.backgroundColor = UIColor.white
                //                self.breathingExerciseButton.isUserInteractionEnabled = true
            }
            
        }
        
        if let meaningUnlocked = kc.getBool(KC_TOOLS_MEANING_UNLOCKED) {
            print("meaningUnlocked ❗️ \(meaningUnlocked)")
            if meaningUnlocked {
                
            } else {
                //                self.makingMeaningButton.isUserInteractionEnabled = true
            }
            
        }
        
    }
    
    //========================================
    // MARK: - Actions
    //========================================
    @IBAction func complexEmotionsBtnPressed(_ sender: UIButton) {
        showToolsAlert()
    }
    
    @IBAction func breathingExerciseBtnPressed(_ sender: AnyObject) {
        showBreathingVideo()
    }
    
    @IBAction func makingMeaningBtnPressed(_ sender: UIButton) {
        showToolsAlert()
    }
    
    @IBAction func dismissBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    //========================================
    // MARK: - Private methods
    //========================================
    
    /*
     func initData(completion:()->()) {
     complexEmotionsButton.isUserInteractionEnabled = false
     breathingExerciseButton.isUserInteractionEnabled = false
     makingMeaningButton.isUserInteractionEnabled = false
     completion()
     }
     */
    
    /*
     func updateContent() {
     print("ProgressVC : updateContent ✅")
     // reload data and save to singletons
     AWSClientManager.shared.queryUserAnalytics(completion: { userAnalytics in
     
     DispatchQueue.main.async {
     self.daysInRowCountLabel.text = userAnalytics.daysInARow
     self.tasksCompletedCountLabel.text = userAnalytics.tasksCompleted
     self.resilienceCountLabel.text = userAnalytics.resilienceTasksCompleted
     self.growthCountLabel.text = userAnalytics.growthMindsetTasksCompleted
     self.negotiationCountLabel.text = userAnalytics.negotiationTasksCompleted
     }
     })
     
     
     AWSClientManager.shared.queryFromUserTools(completion: { tools in
     
     DispatchQueue.main.async {
     
     if tools.isComplexEmotionsUnlocked {
     //                        self.complexEmotionsButton.backgroundColor = UIColor.clear
     } else {
     //                        self.complexEmotionsButton.backgroundColor = UIColor.white
     
     self.complexEmotionsButton.isUserInteractionEnabled = true
     
     }
     
     if tools.isBreathingUnlocked {
     //                self.breathingExerciseButton.backgroundColor = UIColor.clear
     self.breathingExerciseButton.isUserInteractionEnabled = true
     } else {
     //                self.breathingExerciseButton.backgroundColor = UIColor.white
     self.breathingExerciseButton.isUserInteractionEnabled = true
     }
     
     if tools.isMakingMeaningUnlocked {
     
     } else {
     self.makingMeaningButton.isUserInteractionEnabled = true
     }
     }
     })
     }
     */
    
    func showBreathingVideo() {
        
        guard let path = Bundle.main.path(forResource: "Breathe-02", ofType: "mov") else {
            return
        }
        
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        
        let playerController = AVPlayerViewController()
        playerController.player = player
        
        present(playerController, animated: true) {
            player.play()
        }
        
    }
    
    //========================================
    // MARK: - Navigations
    //========================================
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "progressToQuizResult" {
            
            let vc = segue.destination as! QuizResultViewController
            vc.passedTaskResult = UserData.shared.userTestResults[selectedRow]
            
        }
    }
    
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}

extension ProgressViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return UserData.shared.userTestResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TestResultsTableViewCell") as? TestResultsTableViewCell {
            
            if UserData.shared.userTestResults.count > 0 {
                
                cell.configureCell(testResult: UserData.shared.userTestResults[indexPath.row])
                
            }
            
            if indexPath.row == 0 {
                
                let line = UIView(frame: CGRect(x: 10, y: 1, width: cell.contentView.frame.width + 15, height: 0.8))
                line.backgroundColor = UIColor(red: 235/255, green: 235/255, blue: 241/255, alpha: 1.0)
                
                cell.contentView.addSubview(line)
                
            }
            
            return cell
            
        }
        return UITableViewCell()
    }
    
}

extension ProgressViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        
        performSegue(withIdentifier: "progressToQuizResult", sender: nil)
    }
    
    
    
}


extension ProgressViewController: SwiftAlertViewDelegate {
    
    func showToolsAlert() {
        
        let alertView = SwiftAlertView(title: "Content Locked", message: "Please complete more tasks to unlock this tool.", delegate: self, cancelButtonTitle: "OK", otherButtonTitles: nil)
        
        
        
        alertView.backgroundColor = UIColor.white
        
        alertView.titleLabel.textColor = COLOR_LIGHT_BLUE
        alertView.titleLabel.font = UIFont(name: CUSTOM_FONT_BOLD, size: FONT_SIZE_ALERT_BIG)
        
        alertView.messageLabel.textColor = COLOR_TEXT_DARK_GRAY
        alertView.messageLabel.font = UIFont(name: CUSTOM_FONT_MEDIUM, size: FONT_SIZE_ALERT_SMALL)
        
        alertView.buttonAtIndex(0)?.setTitleColor(COLOR_LIGHT_BLUE, for: UIControlState())
        alertView.buttonAtIndex(0)?.titleLabel?.font = UIFont(name: CUSTOM_FONT_BOLD, size: FONT_SIZE_ALERT_SMALL)
        
        alertView.show()
    }
    
}
