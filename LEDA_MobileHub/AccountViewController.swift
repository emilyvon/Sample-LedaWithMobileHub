//
//  AccountViewController.swift
//  LEDA
//
//  Created by Mengying Feng on 5/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
import AWSDynamoDB


class AccountViewController: UIViewController {
    
    //========================================
    // MARK: - Outlets
    //========================================
    
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    //========================================
    // MARK: - Properties
    //========================================
    
    var pool: AWSCognitoIdentityUserPool?
    var user: AWSCognitoIdentityUser?
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    
    @IBOutlet weak var mySwitch: UISwitch!
    //========================================
    // MARK: - View lifecycles
    //========================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let kc = KeychainSwift()
        
        if let first = kc.get(KC_USER_FIRSTNAME), let email = kc.get(KC_USER_EMAIL) {
            print("first ✅ \(first)")
            print("email ✅ \(email)")
            self.firstNameLabel.text = first
            self.emailLabel.text = email
        }
        
        if let keepLoggedIn = UserDefaults.standard.object(forKey: UD_USER_KEEP_LOGGED_IN) as? Bool {
            saveKeepUserLoggedInSettingToUD(aBool: keepLoggedIn)
            mySwitch.isOn = keepLoggedIn
        } else {
            saveKeepUserLoggedInSettingToUD(aBool: true)
            mySwitch.isOn = true
        }
    }
    
    
    //========================================
    // MARK: - Actions
    //========================================
    
    @IBAction func progressBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "accountToProgress", sender: nil)
    }
    
    @IBAction func editBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "accountToEdit", sender: nil)
    }
    
    @IBAction func helpBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "acountToHelp", sender: nil)
    }
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        saveKeepUserLoggedInSettingToUD(aBool: sender.isOn)
    }
    
    @IBAction func dismiss(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //========================================
    // MARK: - Private methods
    //========================================
    
    func saveKeepUserLoggedInSettingToUD(aBool: Bool) {
        
//        if let uid = KeychainSwift().get(KC_USER_UID) {
//            UserDefaults.standard.set(aBool, forKey: uid)
//        } else {
//            print("switchValueChanged : can't save ❌")
//        }
        
        UserDefaults.standard.set(aBool, forKey: UD_USER_KEEP_LOGGED_IN)
        
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }}
