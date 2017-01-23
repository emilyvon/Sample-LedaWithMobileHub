////
////  VideoPlayerView.swift
////  LEDA
////
////  Created by Hao on 14/10/16.
////  Copyright © 2016 Andrew Osborne. All rights reserved.
////
//
//import UIKit
//import AVFoundation
//import WistiaKit
//
//class VideoPlayerView: UIView {
//
//    let thumbnailView = UIImageView()
//    let playBtn = UIButton()
////    var url:URL = URL.init(string: "http://www.html5videoplayer.net/videos/toystory.mp4")!
//    var url:URL = URL.init(string: "http")!
//    let wistiaPlayerVC = WistiaPlayerViewController(referrer: "WistiaKitDemo", requireHLS: false)
//
//    var hashedId: String!
//    var currentVC: UIViewController!
//    override init(frame: CGRect)efo {
//        super.init(frame: frame)
//        addSubview(playBtn)
//        addSubview(thumbnailView)
//        
//        playBtn.setImage(UIImage(named: "play_circle_fill"), for: .normal)
//        playBtn.addTarget(self, action:#selector(self.playbtnPressed(_:)), for: .touchUpInside)
//    }
//
//    
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        addSubview(playBtn)
//        addSubview(thumbnailView)
//        playBtn.setImage(UIImage(named: "play_circle_fill"), for: .normal)
//        playBtn.addTarget(self, action:#selector(self.playbtnPressed(_:)), for: .touchUpInside)
//    }
//    
//    
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        // Set the button's width and height to a square the size of the frame's height.
//        let thumbFrame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
//        thumbnailView.frame = thumbFrame
//        let playbtnHeight = frame.size.height/3
//        let playBtnFrame = CGRect(x: (frame.size.width - playbtnHeight)/2, y: (frame.size.height - playbtnHeight)/2, width: playbtnHeight, height: playbtnHeight)
//        playBtn.frame = playBtnFrame
//        bringSubview(toFront: playBtn)
//        
//        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(playbtnPressed(_ :)))
//        tap.cancelsTouchesInView = false
//        thumbnailView.addGestureRecognizer(tap)
//
//    }
//    
//    func updateView() {
//        if hashedId != nil {
//            
//            
//            globalAPI.listProjects(completionHandler: { (projects: [WistiaProject], error: WistiaAPIError?) in
//                for _ in projects {
//                    globalAPI.listMedias(completionHandler: { (medias: [WistiaMedia], error: WistiaAPIError?) in
//                        for media in medias {
//                            if media.hashedID == self.hashedId{
//                                if let thumbnail = media.thumbnail{
//                                    let url = URL(string: (thumbnail.url))
//                                    self.downloadImage(url: url!)
//                                }
//                            }
//                            
//                        }
//                    })
//                }
//
//            })
//            
//            
//            /*
//            globalAPI.listProjects { (projects: [WistiaProject]) in
//                for proj in projects {
//                    
////                    print("*** \(proj) medias *** : ")
//                    globalAPI.listMedias(completionHandler: { (medias: [WistiaMedia]) in
//                        for media in medias {
//                            if media.hashedID == self.hashedId{
////                                print("*** media *** : \(media)")
//                                if let thumbnail = media.thumbnail{
//                                    let url = URL(string: (thumbnail.url))
//                                    self.downloadImage(url: url!)
//                                }
//                            }
//                            
//                        }
//                    })
//                    
//                }
//            }
//            */
//        }
//  
//    
//    }
//    
//    func playbtnPressed(_ sender: UIButton!) {
//        //show video as full screen
//        print("play btn pressed")
//        if hashedId != nil {
//            wistiaPlayerVC.replaceCurrentVideoWithVideo(forHashedID: hashedId)
//            currentVC.present(wistiaPlayerVC, animated: true, completion: nil)
//        }
//    }
//    
//    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
//        URLSession.shared.dataTask(with: url) {
//            (data, response, error) in
//            completion(data, response, error)
//            }.resume()
//    }
//
//    func downloadImage(url: URL) {
//        print("Download Started")
//        getDataFromUrl(url: url) { (data, response, error)  in
//            guard let data = data, error == nil else { return }
//            print(response?.suggestedFilename ?? url.lastPathComponent)
//            print("Download Finished")
//            DispatchQueue.main.async() { () -> Void in
//                self.thumbnailView.image = UIImage(data: data)
//            }
//        }
//    }
//}
