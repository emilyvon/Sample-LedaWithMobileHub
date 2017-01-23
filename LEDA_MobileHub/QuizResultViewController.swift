//
//  QuizResultViewController.swift
//  LEDA
//
//  Created by Hao on 25/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit
import AWSDynamoDB

protocol QuizResultViewControllerDelegate {
    func dismiss(vc: QuizResultViewController)
}

class QuizResultViewController: UIViewController {
    
    //========================================
    // MARK: - Outlets
    //========================================
    @IBOutlet weak var introLabel: UILabel!
    @IBOutlet weak var heading1: UILabel!
    @IBOutlet weak var result1: UILabel!
    @IBOutlet weak var quizScrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var markerView: Marker3View!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    
    //========================================
    // MARK: - Properties
    //========================================
    var quizResultViewControllerDelegate: QuizResultViewControllerDelegate?
    var rangeArray = [String]()
    var textArray = [String]()
    var arrayCount = 0
    var quizScore: Double!
    
    var passedTaskResult: TestResults? = nil
    
    //========================================
    // MARK: - View lifecycle
    //========================================
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("UserData.shared.currentContentDay: \(UserData.shared.currentContentDay), UserData.shared.currentTaskNo: \(UserData.shared.currentTaskNo)")
        
        if let passedTaskResult = self.passedTaskResult {
            
            continueButton.isHidden = true
            closeButton.isHidden = false
            
            print("passedTaskResult ❗️ \(passedTaskResult)")
            
            let dayNoStr = passedTaskResult.taskNo.components(separatedBy: "_")[0].replacingOccurrences(of: "day", with: "")
            
            let taskNoStr = passedTaskResult.taskNo.components(separatedBy: "_")[1].replacingOccurrences(of: "task", with: "")
            
            if let day = Int(dayNoStr), let task = Int(taskNoStr) {
                
                displayResult(dayNo: day, taskNo: task, score: Double(passedTaskResult.score)!/100)
            }
        } else {
            continueButton.isHidden = false
            closeButton.isHidden = true
            
            displayResult(dayNo: UserData.shared.currentContentDay, taskNo: UserData.shared.currentTaskNo, score: quizScore)
        }
    }
    
    override func viewDidLayoutSubviews() {
        adjustScrollViewContentSize()
    }
    
    //========================================
    // MARK: - Actions
    //========================================
    @IBAction func continueClicked(_ sender: UIButton) {
        UserData.shared.currentTaskNo += 1
        quizResultViewControllerDelegate?.dismiss(vc: self)
    }
    
    @IBAction func closeBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //========================================
    // MARK: - Private methods
    //========================================
    func adjustScrollViewContentSize() {
        var height = CGFloat(0)
        for aView in contentView.subviews {
            height += aView.frame.size.height + 20
        }
        quizScrollView.contentSize = CGSize(width: self.view.frame.size.width, height: height)
    }
    
    func displayResult(dayNo: Int, taskNo: Int, score: Double) {
        
        markerView.number = CGFloat(score*100)
        
        if let content = Helper.shared.getCurrentTask(contentDay: dayNo, task: taskNo) {
            
            self.introLabel.text = content.resultIntro
            
            var isResultSet = false
            
            for section in content.resultSection {
                if !isResultSet {
                    for (k,v) in section {
                        
                        if let scoreResultDouble = Double(k) {
                            if score < scoreResultDouble {
                                if let result = Double(k) {
                                    self.heading1.text = "\(Int(result*100))%"
                                }
                                self.result1.text = v
                                isResultSet = true
                            }
                        }
                    }
                }
            }
        }
    }
}
