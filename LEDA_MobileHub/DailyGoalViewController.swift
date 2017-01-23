////
////  DailyGoalViewController.swift
////  LEDA
////
////  Created by Hao on 14/10/16.
////  Copyright © 2016 Andrew Osborne. All rights reserved.
////
//
//import UIKit
//
//class DailyGoalViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate, UIScrollViewDelegate {
//
//    let itemsPerRow: CGFloat = 2
//    let sectionInsets = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 0.0, right: 20.0)
//    let reuseIdentifier = "videoCell"
//    let identifier = "cell"
//    // also enter this string as the cell identifier in the storyboard
////    var items = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48"]
//
//    let hashedId = "z2b1h7udsy"
//    var items:[String] = ["1", "2", "3", "4", "5", "6"]
//    
//    @IBOutlet var descriptionLabel: UILabel!
//    @IBOutlet var collectionView: UICollectionView!
//    
//    @IBOutlet var collectionHeight: NSLayoutConstraint!
//    @IBOutlet var closeBtn: UIButton!
//    @IBOutlet var contentView: UIView!
//    @IBOutlet var flowImageView: UIImageView!
//    @IBOutlet var zoombtn: UIButton!
//
//    @IBOutlet var scrollview: UIScrollView!
//
////    @IBOutlet var videoView: VideoPlayerView!
//    
//    @IBOutlet weak var bgButton: UIButton!
//    
////    var fullScreenImageView: UIImageView!
//    var initScale: CGFloat = 1.0
//    var videoWatched = false
//    override func viewDidLoad() {
//        
//        bgButton.layer.shadowRadius = 2
//        bgButton.layer.shadowColor = UIColor.blue.cgColor
//        
//        
//        
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        setupCollectionView()
//        setupInfographic()
//        
//        contentView.bringSubview(toFront: zoombtn)
//        view.bringSubview(toFront: closeBtn)
//        scrollview.delegate = self
////        scrollview.contentSize.height = 2000
//        
////        videoView.hashedId = self.hashedId
////        videoView.currentVC = self
////        videoView.updateView()
////        let awsManager = AWSClientManager.shared
////        awsManager.getItemFromDB(23)
//    }
//    
//    override var shouldAutorotate: Bool {
//        return true
//    }
//    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return .portrait
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
////        if !videoWatched{
////            if videoView.wistiaPlayerVC.isBeingDismissed{
////                print("video watched, is going to show rate video alert")
////                videoWatched = true
////                showRateVideoAlert()
////            }
////        }
//    }
//    
//    func showRateVideoAlert() {
//        showCustomAlertView()
//    }
//    
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//
//        let size = descriptionLabel.frame.origin.y + descriptionLabel.frame.size.height + 60
//        let offset = size - scrollview.frame.height
//        if scrollview.contentOffset.y > offset {
//            scrollview.contentOffset.y = offset
//        }
//    }
//    
//    func setupCollectionView() {
//        collectionView.delegate = self
//        collectionView.dataSource = self
//        
//        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
//        let availableWidth = view.frame.width - paddingSpace
//        let widthPerItem = availableWidth / itemsPerRow
//        
//        collectionHeight.constant = widthPerItem*CGFloat(items.count)/2 + 10*CGFloat(items.count/2-1)+sectionInsets.top*2
//        collectionView.isUserInteractionEnabled = true
//    }
//    
//    func setupInfographic() {
//        flowImageView.image = UIImage(named: "image")
//        flowImageView.isUserInteractionEnabled = true
//        flowImageView.isMultipleTouchEnabled = true
//        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(_ :)))
//        tap.cancelsTouchesInView = false
//        
//        flowImageView.addGestureRecognizer(tap)
//    }
//    
//    
///** GestureRecognizer for Infographic, tap for full screen image and pinch to zoomin  **/
//    func handlePinch(_ sender: UIPinchGestureRecognizer) {
//        // just creating an alert to prove our tap worked!
//        
//        let newScale = sender.scale*initScale
//        print("image pinched, newscale = \(newScale) , init scale = \(initScale)")
//        if sender.state == .began || sender.state == .changed{
//            if newScale > 1 {
//                sender.view?.transform = CGAffineTransform(scaleX: newScale, y: newScale)
//            }
//        }
//        if sender.state == .ended{
//            if newScale > 1 {
//                initScale = newScale
//            }else{
//                initScale = 1
//            }
//        }
//    }
//    
//    func handleTap(_ sender: UIButton!) {
//        print("zoom btn pressed")
//        let originImage = UIImage(named: "infographsample")
////        let rotatedImage = UIImage.init(cgImage: (originImage?.cgImage)!, scale: (originImage?.scale)!, orientation: UIImageOrientation.left)
//        let fullScreenImageView = UIImageView(image: originImage)
//        fullScreenImageView.frame = self.view.frame
//        fullScreenImageView.backgroundColor = COLOR_TEXT_DARK_GRAY
//        fullScreenImageView.contentMode = .scaleAspectFit
//        fullScreenImageView.isUserInteractionEnabled = true
//        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage(_ :)))
//        tap.cancelsTouchesInView = false;
//        fullScreenImageView.addGestureRecognizer(tap)
//        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
//        
//        fullScreenImageView.addGestureRecognizer(pinch)
//        self.view.addSubview(fullScreenImageView)
//    }
//
//
//    @IBAction func zoomPressed(_ sender: UIButton) {
//        print("zoom btn pressed")
//        
//    }
//    
//    func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
//        sender.view?.removeFromSuperview()
//        initScale = 1.0
//    }
//    
//    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
//        print("scroll view did end zooming")
//    }
//    
//    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        return true
//    }
//    
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//    }
//    
//
//    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        print("did layout subview")
//
////        scrollview.contentSize = CGSize(width:self.view.frame.size.width, height:self.view.frame.size.height*1)
//
//    }
//    
//    
//    
//    
//    
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//     */
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        let id = segue.identifier
//        if id == "giveRateSegue"{
//            let vc = segue.destination as! GiveRatingViewController
//            vc.giveRatingDelegate = self
//            vc.hashedId = self.hashedId
//        }
//    }
//
//    @IBAction func closeCurrentView(_ sender: UIButton) {
//        print("close btn clicked")
//    }
//
//    @IBAction func continueBtnPressed(_ sender: UIButton) {
//        print("continue button pressed")
//    }
//    
//    
//    // MARK: - UICollectionViewDataSource protocol
//    
//    // tell the collection view how many cells to make
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.items.count
//    }
//    
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
//    }
//    
//    
//    // make a cell for each cell index path
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        
//        // get a reference to our storyboard cell
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath as IndexPath) as! VideosCollectionViewCell
////        cell.videoPlayerView.thumbnailView.image = UIImage(named: "image")
////        cell.videoName.text = "public speaking"
//        cell.getResFrom(hashedId: "z2b1h7udsy")
//        cell.videoPlayerView.hashedId = "z2b1h7udsy"
//        cell.videoPlayerView.currentVC = self
////        cell.videoPlayerView.updateView()
//        let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped(_ :)))
//        tap.delegate = self
//        
//        cell.addGestureRecognizer(tap)
////
//        cell.layoutIfNeeded()
//
//        return cell
//    }
//    
//    
//    func cellTapped(_ sender: AnyObject) {
//        print("cell tapped")
//    }
//    
//    
//    
//    // MARK: - UICollectionViewDelegate protocol
//    
////    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
////        // handle tap events
////        print("You selected cell #\(indexPath.item)!")
////    }
//    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print("You selected cell #\(indexPath.item)!")
//    }
//    
//    
//
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        //2
//        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
//        let availableWidth = view.frame.width - paddingSpace
//        let widthPerItem = availableWidth / itemsPerRow
//        
//        return CGSize(width: widthPerItem, height: widthPerItem)
//    }
//    
//    //3
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        insetForSectionAt section: Int) -> UIEdgeInsets {
//        return sectionInsets
//    }
//    
//    // 4
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 10
//    }
//
//    
//}
//extension DailyGoalViewController: GiveRatingViewControllerDelegate{
//    func dismissGiveRating(vc: GiveRatingViewController) {
//        vc.dismiss(animated: false, completion: nil)
//    }
//}
//
//extension DailyGoalViewController: SwiftAlertViewDelegate {
//    
//    func showCustomAlertView() {
//        let alertView = SwiftAlertView(title: "Rate This Video", message: "We'd love to know what you thought of our content.", delegate: self, cancelButtonTitle: "Skip", otherButtonTitles: "Rate")
//        
//        alertView.backgroundColor = UIColor.white
//        
//        alertView.titleLabel.textColor = COLOR_LIGHT_BLUE
//        alertView.titleLabel.font = UIFont(name: CUSTOM_FONT_BOLD, size: FONT_SIZE_ALERT_BIG)
//        
//        alertView.messageLabel.textColor = COLOR_TEXT_DARK_GRAY
//        alertView.messageLabel.font = UIFont(name: CUSTOM_FONT_MEDIUM, size: FONT_SIZE_ALERT_SMALL)
//        
//        alertView.buttonAtIndex(0)?.setTitleColor(UIColor.gray, for: UIControlState())
//        alertView.buttonAtIndex(0)?.titleLabel?.font = UIFont(name: CUSTOM_FONT_BOLD, size: FONT_SIZE_ALERT_SMALL)
//        
//        alertView.buttonAtIndex(1)?.setTitleColor(COLOR_LIGHT_BLUE, for: UIControlState())
//        alertView.buttonAtIndex(1)?.titleLabel?.font = UIFont(name: CUSTOM_FONT_BOLD, size: FONT_SIZE_ALERT_SMALL)
//        
//        alertView.show()
//    }
//
//    func alertView(_ alertView: SwiftAlertView, clickedButtonAtIndex buttonIndex: Int) {
//        if buttonIndex == 0 {
//            print("*** SKIP button pressed ***")
//        } else {
//            print("*** rate! ***")
//            self.performSegue(withIdentifier: "giveRateSegue", sender: nil)
//        }
//    }
//    
//}
