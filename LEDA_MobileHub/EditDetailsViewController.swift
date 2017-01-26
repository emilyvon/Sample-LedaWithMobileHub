//
//  EditDetailsViewController.swift
//  LEDA
//
//  Created by Mengying Feng on 18/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit

class EditDetailsViewController: UIViewController, UITextFieldDelegate {
    
    
    //========================================
    // MARK: - Outlets
    //========================================
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    //========================================
    // MARK: - View lifecycle
    //========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        emailTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let first = KeychainSwift().get(KC_USER_GIVEN_NAME),/* let last = KeychainSwift().get(KC_USER_LASTNAME), */let email = KeychainSwift().get(KC_USER_EMAIL) else {
            print("*** ❌ uid is nil ***")
            return
        }
        
        nameTextField.text = "\(first.capitalized)"
        emailTextField.text = email.lowercased()
        

    }
    
    //========================================
    // MARK: - Actions
    //========================================
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        dismissKeyboard()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func forgotBtnPressed(_ sender: UIButton) {
        
        dismissKeyboard()
        
        guard let email = emailTextField.text else {
            return
        }
        
        if email.isEmpty {
            showAlert(msgStr: "Email cannot be empty")
        } else if !email.isValidEmail() {
            showAlert(msgStr: "Invalid email format")
        } else {
            performSegue(withIdentifier: "editDetailsToForgot", sender: nil)
        }
    }
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        
        dismissKeyboard()
        
        guard let name = nameTextField.text, let email = emailTextField.text  else { return }
        
        // 1. no empty fields
        if name.isEmpty {
            showAlert(msgStr: "Please fill in your name.")
        }
            
        else if email.isEmpty {
            showAlert(msgStr: "Please fill in your email.")
        }
            // 2. valid email format
        else if !email.isValidEmail() {
            showAlert(msgStr: "Invalid email format.")
        }
        else {
            
            // actInd.start
            let uiview = UIView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: self.view.bounds.size.height))
            uiview.backgroundColor = UIColor.gray
            uiview.alpha = 0.5
            self.view.addSubview(uiview)
            
            let actInt = UIActivityIndicatorView(activityIndicatorStyle: .white)
            actInt.center = uiview.center
            actInt.startAnimating()
            
            uiview.addSubview(actInt)
            
            /*
            AWSClientManager.shared.saveUserInfo(givenName: name.components(separatedBy: " ")[0], familyName: name.components(separatedBy: " ")[1], email: email) {
                DispatchQueue.main.async {
                    // actInt.stop
                    uiview.removeFromSuperview()
                    self.showAlert(msgStr: "Your information has been saved!")
                    
                    if let name = self.nameTextField.text, let email = self.emailTextField.text {
                        KeychainSwift().set(name.components(separatedBy: " ")[0], forKey: KC_USER_GIVEN_NAME)
                        KeychainSwift().set(name.components(separatedBy: " ")[1], forKey: KC_USER_LASTNAME)
                        KeychainSwift().set(email, forKey: KC_USER_EMAIL)
                    }
                    
                }
            }
            */
        }
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    //========================================
    // MARK: - Navigations
    //========================================
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editDetailsToForgot" {
            let vc = segue.destination as! ForgotViewController
            vc.passedEmail = emailTextField.text
        }
    }
    
    //========================================
    // MARK: - Private Methods
    //========================================
    
    
    func dismissKeyboard() {
        nameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
}

extension EditDetailsViewController: SwiftAlertViewDelegate {
    
    func showAlert(msgStr: String) {
        
        let alertView = SwiftAlertView(title: nil, message: msgStr, delegate: self, cancelButtonTitle: "OK", otherButtonTitles: nil)
        
        alertView.backgroundColor = UIColor.white
        
        alertView.messageLabel.textColor = COLOR_TEXT_DARK_GRAY
        alertView.messageLabel.font = UIFont(name: CUSTOM_FONT_MEDIUM, size: FONT_SIZE_ALERT_SMALL)
        
        alertView.buttonAtIndex(0)?.setTitleColor(COLOR_LIGHT_BLUE, for: UIControlState())
        alertView.buttonAtIndex(0)?.titleLabel?.font = UIFont(name: CUSTOM_FONT_BOLD, size: FONT_SIZE_ALERT_SMALL)
        
        alertView.show()
    }
    
    func alertView(_ alertView: SwiftAlertView, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == 0 {
            if let message = alertView.messageLabel.text {
                if message.contains("has been saved") {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
}
