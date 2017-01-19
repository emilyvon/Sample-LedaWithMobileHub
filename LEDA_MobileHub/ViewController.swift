//
//  ViewController.swift
//  LEDA_MobileHub
//
//  Created by Mengying Feng on 13/1/17.
//  Copyright © 2017 iEmRollin. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSDynamoDB

class ViewController: UIViewController {
    

//    var didSignInObserver: AnyObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //        print("Sign In Loading")
        
        
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        presentSignInViewController()
    }
    
    
    @IBAction func insert(_ sender: Any) {
        
        
        insertData()
        
    }
    
    func insertData() {
        
        let objectMapper = AWSDynamoDBObjectMapper.default()
        
        let itemToCreate = Notes()
        
        itemToCreate?._userId = AWSIdentityManager.defaultIdentityManager().identityId!
        itemToCreate?._noteId = "note-1"
        itemToCreate?._content = "This is the content of the note."
        itemToCreate?._creationDate = 2016
        itemToCreate?._title = "Emily's first note"
        objectMapper.save(itemToCreate!) { (error) in
            if let error = error {
                print("Amazon DynamoDB Save Error: \(error)")
                return
            }
            print("Item saved.")
        }
        
    }
    
    
    func presentSignInViewController() {
        print("presentSignInViewController: \(AWSIdentityManager.defaultIdentityManager().isLoggedIn)")
        if !AWSIdentityManager.defaultIdentityManager().isLoggedIn {
            
            
            print("❗️present sign in vc")
            DispatchQueue.main.async {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "SignInViewController") as! SignInViewController
                self.present(vc, animated: false, completion: nil)
            }
            
        }
        
    }
    
}

