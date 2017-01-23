//
//  CustomVideoPlayerViewController.swift
//  LEDA
//
//  Created by Mengying Feng on 12/12/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit
import AVFoundation

private var playbackLikelyToKeepUpContext = 0

class CustomVideoPlayerViewController: UIViewController {
    
    //========================================
    // MARK: - Outlets
    //========================================
    @IBOutlet weak var ratingContainerView: UIView!
    @IBOutlet weak var ratingThisVideoLabel: UILabel!
    @IBOutlet weak var resutlTitleLabel: UILabel!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var ratingControl: RatingControl!
    
    //========================================
    // MARK: - Properties
    //========================================
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    let invisibleButton = UIButton()
    
    var timeObserver: Any!
    
    let bgView = UIView()
    let timeRemainingLabel = UILabel()
    let timeDurationLabel = UILabel()
    let seekSlider = VideoPlayerSlider()
    var playerRateBeforeSeek: Float = 0
    let loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    var isTotalTimeSet = false
    
    // rating
    var rating = 0
    var isRated = false
    var selectedButtonTitle = ""
    var selectedRating = 0
    
    let positiveFeedbacks = ["Simulating", "Informative", "Practical"]
    let negativeFeedbacks = ["Boring", "Laggy", "Irrelevant"]
    
    let positiveTitle = "What did you like?"
    let negativeTitle = "What didn't work?"
    
    //========================================
    // MARK: - View lifecycle
    //========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(catchNotification(notification:)), name: NSNotification.Name("RatingControlPressed"), object: nil)
        
        view.backgroundColor = UIColor.black
        
        view.addSubview(invisibleButton)
        invisibleButton.addTarget(self, action: #selector(invisibleButtonTapped(sender:)), for: UIControlEvents.touchUpInside)
        
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        if UserData.shared.isTask1Finished && UserData.shared.isTask2Finished && UserData.shared.isTask3Finished {
            
            if let content = Helper.shared.getCurrentTask(contentDay: UserData.shared.currentContentDay, task: 1) {
                
                if let url = URL(string: content.videoUrl) {
                    let playerItem = AVPlayerItem(url: url)
                    NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
                    avPlayer.replaceCurrentItem(with: playerItem)
                }
                
            }
            
        } else {
            
            if let content = Helper.shared.getCurrentTask(contentDay: UserData.shared.currentContentDay, task: UserData.shared.currentTaskNo) {
                print("video url : \(content.videoUrl)")
                if let url = URL(string: content.videoUrl) {
                    
                    let playerItem = AVPlayerItem(url: url)
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(itemDidFinishPlaying(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
                    
                    avPlayer.replaceCurrentItem(with: playerItem)
                    
                    
                    
                } else {
                    print("can't convert video url")
                }
            } else {
                print("can't get video url")
            }
        }
        
        addPeriodicTimeObserver()
        
        // background
        bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        view.addSubview(bgView)
        // slider
        view.addSubview(seekSlider)
        // time label
        timeRemainingLabel.textColor = UIColor.white
        timeRemainingLabel.font = UIFont(name: "Gilroy-Medium", size: 12.0)
        timeRemainingLabel.textAlignment = .right
        view.addSubview(timeRemainingLabel)
        
        timeDurationLabel.textColor = UIColor.white
        timeDurationLabel.font = UIFont(name: "Gilroy-Medium", size: 12.0)
        timeDurationLabel.textAlignment = .left
        view.addSubview(timeDurationLabel)
        
        seekSlider.isUserInteractionEnabled = false
        seekSlider.addTarget(self, action: #selector(sliderBeganTracking(slider:)), for: UIControlEvents.touchDown)
        seekSlider.addTarget(self, action: #selector(sliderEndedTracking(slider:)), for: [.touchUpInside, .touchUpOutside])
        seekSlider.addTarget(self, action: #selector(sliderValueChanged(slider:)), for: UIControlEvents.valueChanged)
        
        loadingIndicatorView.hidesWhenStopped = true
        view.addSubview(loadingIndicatorView)
        avPlayer.addObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp", options: NSKeyValueObservingOptions.new, context: &playbackLikelyToKeepUpContext)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        print("UserData.shared.currentContentDay: \(UserData.shared.currentContentDay), UserData.shared.currentTaskNo: \(UserData.shared.currentTaskNo)")
        
        isRated = false
        
        invisibleButton.isHidden = false
        
        ratingControl.center.y += view.bounds.height * 0.6
        resutlTitleLabel.center.y += view.bounds.height
        button1.center.y += view.bounds.height
        button2.center.y += view.bounds.height
        button3.center.y += view.bounds.height
        submitButton.center.y += view.bounds.height
        
        setupButtons()
        
        bgView.isHidden = false
        timeRemainingLabel.isHidden = false
        timeDurationLabel.isHidden = false
        seekSlider.isHidden = false
        ratingContainerView.isHidden = true
        UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
        
        
        loadingIndicatorView.startAnimating()
        isTotalTimeSet = false
        timeRemainingLabel.text = "00:00"
        timeDurationLabel.text = "00:00"
        
        avPlayer.play()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        avPlayerLayer.frame = view.bounds
        invisibleButton.frame = view.bounds
        
        let gap: CGFloat = 10
        let controlsHeight: CGFloat = 50
        let controlsY: CGFloat = view.bounds.size.height - controlsHeight
        
        bgView.frame = CGRect(x: 0, y: controlsY, width: view.bounds.size.width, height: controlsHeight)
        
        seekSlider.frame = CGRect(x: gap, y: controlsY * 1.01, width: view.bounds.size.width - 2 * gap, height: controlsHeight)
        
        let seekerHeight = view.bounds.size.height - seekSlider.frame.size.height * 0.8
        let timeLabelY = view.bounds.size.width - 60 - gap
        
        timeRemainingLabel.frame = CGRect(x: timeLabelY, y: seekerHeight, width: 60, height: controlsHeight)
        
        timeDurationLabel.frame = CGRect(x: gap, y: seekerHeight, width: 60, height: controlsHeight)
        
        loadingIndicatorView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }
    
    override var shouldAutorotate: Bool {
        if ratingContainerView.isHidden {
            return true
        } else {
            return false
        }
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscape, .portrait]
    }
    
    
    func itemDidFinishPlaying(notification: Notification) {
        
        print("itemDidFinishPlaying")

        UserData.shared.isTask1Finished = true
        UserData.shared.currentTaskNo += 1
        
        
        bgView.isHidden = true
        timeRemainingLabel.isHidden = true
        timeDurationLabel.isHidden = true
        seekSlider.isHidden = true
        
        invisibleButton.isHidden = true
        
        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        ratingContainerView.isHidden = false
        
        //        if UserData.shared.isTask1Finished && UserData.shared.isTask2Finished && UserData.shared.isTask3Finished {
        //
        //            self.dismiss(animated: false, completion: nil)
        //        } else {
        //
        //            UserData.shared.isTask1Finished = true
        //            UserData.shared.currentTaskNo += 1
        //
        //            performSegue(withIdentifier: "customVideoPlayerToGiveRating", sender: nil)
        //
        //            DispatchQueue.main.async {
        //                self.view.alpha = 0
        //            }
        //        }
    }
    
    func invisibleButtonTapped(sender: UIButton) {
        let playerIsPlaying = avPlayer.rate > 0
        if playerIsPlaying {
            avPlayer.pause()
        } else {
            avPlayer.play()
        }
    }
    
    func addPeriodicTimeObserver() {
        let timeInterval = CMTimeMakeWithSeconds(1.0, 10)
        timeObserver = avPlayer.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main, using: { [weak self] elapsedTime in
            guard let weakSelf = self else { return }
            weakSelf.observeTime(elapsedTime: elapsedTime)
        })
        
    }
    
    private func updateTimeLabel(elapsedTime: Float64, duration: Float64) {
        
        //        if let item = avPlayer.currentItem {
        //            let remainingTime = CMTimeSubtract(item.duration, item.currentTime())
        //            let durationInSeconds = CMTimeGetSeconds(item.duration)
        //
        //            print("remaintingTime: \(remainingTime), durationInSeconds: \(durationInSeconds)")
        //        }
        
        if !isTotalTimeSet {
            seekSlider.maximumValue = Float(duration)
            isTotalTimeSet = true
        }
        
        let timeRemaining: Float64 = CMTimeGetSeconds(avPlayer.currentItem!.duration) - elapsedTime
        
        timeRemainingLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
        timeDurationLabel.text = String(format: "%02d:%02d", ((lround(elapsedTime) / 60) % 60), lround(elapsedTime) % 60)
        
        // update slider value
        seekSlider.setValue(Float(lround(elapsedTime) % 60), animated: true)
    }
    
    private func observeTime(elapsedTime: CMTime) {
        if let currentItem = avPlayer.currentItem {
            
            let duration = CMTimeGetSeconds(currentItem.duration)
            
            if duration.isFinite {
                let elapsedTime = CMTimeGetSeconds(elapsedTime)
                updateTimeLabel(elapsedTime: elapsedTime, duration: duration)
            }
            
        } else {
            print("no current item ❌")
        }
    }
    
    func sliderBeganTracking(slider: UISlider) {
        
        playerRateBeforeSeek = avPlayer.rate
        avPlayer.pause()
    }
    
    func sliderEndedTracking(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        
        avPlayer.seek(to: CMTimeMakeWithSeconds(elapsedTime, 100)) { (completed) in
            if self.playerRateBeforeSeek > 0 {
                self.avPlayer.play()
            }
        }
    }
    
    func sliderValueChanged(slider: UISlider) {
        
        let videoDuration = CMTimeGetSeconds(avPlayer.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabel(elapsedTime: elapsedTime, duration: videoDuration)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if context == &playbackLikelyToKeepUpContext {
            if avPlayer.currentItem!.isPlaybackLikelyToKeepUp {
                loadingIndicatorView.stopAnimating()
            } else {
                loadingIndicatorView.startAnimating()
            }
        }
    }
    
    
    deinit {
        avPlayer.removeTimeObserver(timeObserver)
        avPlayer.removeObserver(self, forKeyPath: "currentItem.playbackLikelyToKeepUp")
    }
    
    
    func catchNotification(notification:Notification) -> Void {
        print("Rating: \(ratingControl.rating)")
        
        if (ratingControl.rating < 4 && selectedRating >= 4) || (ratingControl.rating >= 4 && selectedRating < 4) {
            setupButtons()
        }
        
        selectedRating = ratingControl.rating
        
        if ratingControl.rating < 4 {
            resutlTitleLabel.text = negativeTitle
            button1.setTitle(negativeFeedbacks[0], for: .normal)
            button2.setTitle(negativeFeedbacks[1], for: .normal)
            button3.setTitle(negativeFeedbacks[2], for: .normal)
        } else {
            resutlTitleLabel.text = positiveTitle
            button1.setTitle(positiveFeedbacks[0], for: .normal)
            button2.setTitle(positiveFeedbacks[1], for: .normal)
            button3.setTitle(positiveFeedbacks[2], for: .normal)
        }
        
        if !isRated {
            isRated = true
            UIView.animate(withDuration: 1.0) {
                self.ratingThisVideoLabel.center.y -= self.view.bounds.height
                self.descriptionLabel.center.y -= self.view.bounds.height
                self.ratingControl.center.y -= self.view.bounds.height * 0.6
                self.resutlTitleLabel.center.y -= self.view.bounds.height
                self.button1.center.y -= self.view.bounds.height
                self.button2.center.y -= self.view.bounds.height
                self.button3.center.y -= self.view.bounds.height
                self.submitButton.center.y -= self.view.bounds.height
            }
        }
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
    
    @IBAction func skipBtnPressed(_ sender: UIButton) {
        saveDataToDb(rating: "", adjective: "")
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func submitBtnPressed(_ sender: UIButton) {
        
        saveDataToDb(rating: "\(ratingControl.rating)", adjective: selectedButtonTitle)
        
        dismiss(animated: false, completion: nil)
        
    }
    
    func saveDataToDb(rating: String, adjective: String) {
        print("UserData.shared.currentContentDay: \(UserData.shared.currentContentDay), UserData.shared.currentTaskNo: \(UserData.shared.currentTaskNo)")
        
        
        
        // save video's rating
        if let content = Helper.shared.getAvailableTask(taskNo: UserData.shared.currentContentDay) {
            
            
            
            let tasks = content.tasks
            
            
            for task in tasks {
                
                print("task: \(task)")
                
                print("task\(UserData.shared.currentTaskNo)")
                print("task\(UserData.shared.currentTaskNo-1)")
                if task.key.contains("task\(UserData.shared.currentTaskNo-1)") {
                    
                    print(UserData.shared.userDayTaskResultDict)
                    
                    
                    if UserData.shared.userTaskResult == nil {
                        UserData.shared.userTaskResult = UserTaskResult(contentDayNo: Int(content.contentDay)!)
                    }
                    
                    var dayTask = DayTaskResult()
                    dayTask.rating = rating
                    dayTask.adjective = adjective
                    dayTask.type = task.value.taskType
                    dayTask.isComplete = true
                    
                    UserData.shared.userDayTaskResultDict[task.key] = dayTask
                    
                    UserData.shared.userTaskResult?.isCompleted = UserData.shared.currentTaskNo < 3 ? false : true
                    
                    UserData.shared.userTaskResult?.tasks = UserData.shared.userDayTaskResultDict
                    
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
        }
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

}
