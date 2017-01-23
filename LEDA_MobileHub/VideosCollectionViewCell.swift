////
////  VideosCollectionViewCell.swift
////  LEDA
////
////  Created by Hao on 17/10/16.
////  Copyright © 2016 Andrew Osborne. All rights reserved.
////
//
//import UIKit
//import WistiaKit
//class VideosCollectionViewCell: UICollectionViewCell {
//    @IBOutlet var videoPlayerView: VideoPlayerView!
//    
//    @IBOutlet var videoName: UILabel!
//
//    
//    
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    
//    
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//    }
//    
//    
//    func getResFrom(hashedId:String) {
//        globalAPI.listProjects { (projects: [WistiaProject], error: WistiaAPIError?) in
//            for _ in projects {
//                globalAPI.listMedias(completionHandler: { (medias: [WistiaMedia], error: WistiaAPIError?) in
//                    for media in medias {
//                        if media.hashedID == hashedId{
//                            print("*** media *** : \(media)")
//                            if let thumbnail = media.thumbnail{
//                                let url = URL(string: (thumbnail.url))
//                                self.downloadImage(url: url!)
//                            }
//                            if let name = media.name {
//                                self.videoName.text = name
//                            }
//                        }
//                    }
//                })
//            }
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
//                self.videoPlayerView.thumbnailView.image = UIImage(data: data)
//            }
//        }
//    }
//
//}
