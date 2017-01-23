//
//  LoginViewController.swift
//  LEDA
//
//  Created by Mengying Feng on 11/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider
//import AWSCore
//import AWSDynamoDB
import AWSMobileHubHelper

class LoginViewController: UIViewController {
    
    //========================================
    // MARK: - Properties
    //========================================
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    
    var overlayView = UIView(frame: UIScreen.main.bounds)
    var actInd = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    //    var pool: AWSCognitoIdentityUserPool?
    //    var user: AWSCognitoIdentityUser?
    //========================================
    // MARK: - Outlets
    //========================================
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var forgotButton: UIButton!
    @IBOutlet weak var showButton: UIButton!
    @IBOutlet weak var keepLoggedInIcon: KeepLoggedInButton!
    
    //========================================
    // MARK: - View Lifecycle
    //========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showButton.isHidden = true
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        overlayView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
        actInd.center = overlayView.center
        overlayView.addSubview(actInd)
        actInd.startAnimating()
        
        
        let attrs = [
            NSFontAttributeName : UIFont(name: "Gilroy-Medium", size: 17.0)!,
            NSForegroundColorAttributeName : UIColor(red: 50/255, green: 185/255, blue: 221/255, alpha: 1.0),
            NSUnderlineStyleAttributeName : 1] as [String : Any]
        
        let str = NSMutableAttributedString(string: "Forgot Password", attributes: attrs)
        forgotButton.setAttributedTitle(str, for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if let keptLoggedIn = UserDefaults.standard.object(forKey: UD_USER_KEEP_LOGGED_IN) as? Bool {
            keepLoggedInIcon.isKeepLoggedInEnabled = keptLoggedIn
        }
    }
    
    
    //========================================
    // MARK: - Actions
    //========================================
    @IBAction func logInBtnPressed(_ sender: UIButton) {
        passwordTextField.resignFirstResponder()
        
        // add loading screen
        view.addSubview(overlayView)
        
        
        AWSCognitoUserPoolsSignInProvider.sharedInstance().setInteractiveAuthDelegate(self)
        handleLoginWithSignInProvider(signInProvider: AWSCognitoUserPoolsSignInProvider.sharedInstance())
        
        //
        //        guard let email = emailTextField.text, let password = passwordTextField.text else {
        //            return
        //        }
        //
        //        if !(email.isEmpty || password.isEmpty) {
        //
        //            AWSClientManager.shared.signInUser(name: email, password: password, completion:{ (result) in
        //                if result {
        //                    print("signInBtnPressed ✅ successfully")
        //
        //                    Helper.shared.isLoggedIn = true
        //
        //                    NotificationCenter.default.post(name: NSNotification.Name("updateWeekviewTasks"), object: nil)
        //
        //                    DispatchQueue.main.async {
        //                        self.dismiss(animated: true, completion: nil)
        //                    }
        //                } else {
        //                    print("signInBtnPressed ❌")
        //                    DispatchQueue.main.async {
        //                        self.overlayView.removeFromSuperview()
        //                        self.showAlert(msgStr: "Incorrect email or password.")
        //                    }
        //                }
        //            })
        //        } else {
        //            showAlert(msgStr: "Please fill in your email and password.")
        //        }
    }
    
    func handleLoginWithSignInProvider(signInProvider: AWSSignInProvider) {
        
        AWSIdentityManager.defaultIdentityManager().loginWithSign(signInProvider) { (result: Any?, error: Error?) in
            DispatchQueue.main.async {
                if error == nil {
                    // handle successful login
                    
                    print("✅ handle successful login")
                    Helper.shared.isLoggedIn = true
                    self.overlayView.removeFromSuperview()
                    NotificationCenter.default.post(name: NSNotification.Name("updateWeekviewTasks"), object: nil)
                    self.dismiss(animated: true, completion: nil)
                    
                }
                print("❗️ Login with signin provider result = \(result), error = \(error?.localizedDescription)")
            }
            
        }
        
    }
    
    
    @IBAction func forgotBtnPressed(_ sender: UIButton) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if let email = emailTextField.text {
            if email.isEmpty {
                performSegue(withIdentifier: "loginToForgot", sender: nil)
            } else {
                if !email.isValidEmail() {
                    showAlert(msgStr: "Invalid email format")
                } else {
                    performSegue(withIdentifier: "loginToForgot", sender: nil)
                }
            }
        }
    }
    
    @IBAction func showBtnPressed(_ sender: UIButton) {
        
        toggleTextFieldSecureEntry(textField: passwordTextField)
        
        if passwordTextField.isSecureTextEntry {
            showButton.setImage(UIImage(named: "ico_invisible"), for: UIControlState.normal)
        } else {
            showButton.setImage(UIImage(named: "ico_visible"), for: UIControlState.normal)
        }
        
    }
    
    
    
    //========================================
    // MARK: - Private Methods
    //========================================
    func toggleTextFieldSecureEntry(textField: UITextField) {
        let isFirstResponder = textField.isFirstResponder
        
        if isFirstResponder {
            textField.resignFirstResponder()
        }
        
        textField.isSecureTextEntry = !textField.isSecureTextEntry
        
        if isFirstResponder {
            textField.becomeFirstResponder()
        }
    }
    
    
    // dismiss keyboard
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        showButton.isHidden = true
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "loginToForgot" {
            let vc = segue.destination as! ForgotViewController
            vc.passedEmail = emailTextField.text
        }
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextField.becomeFirstResponder()
            showButton.isHidden = false
        } else if textField == passwordTextField {
            passwordTextField.resignFirstResponder()
            showButton.isHidden = true
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == passwordTextField {
            showButton.isHidden = false
        } else {
            showButton.isHidden = true
        }
        return true
    }
    
}

extension LoginViewController: SwiftAlertViewDelegate {
    
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
            
            overlayView.removeFromSuperview()
            
        }
    }
    
}

extension LoginViewController: AWSCognitoIdentityInteractiveAuthenticationDelegate {
    
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        return self
    }
    
}

extension LoginViewController: AWSCognitoIdentityPasswordAuthentication {
    
    func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
    }
    
    func didCompleteStepWithError(_ error: Error?) {
        if let err = error {
            
            print("❌ didCompleteStepWithError : \(err.localizedDescription)")
            DispatchQueue.main.async {
                self.overlayView.removeFromSuperview()
                self.showAlert(msgStr: "Incorrect email or password.")
            }
            
        }
    }
}

extension LoginViewController: AWSCognitoUserPoolsSignInHandler {
    
    func handleUserPoolSignInFlowStart() {
        guard let email = self.emailTextField.text, let _ = self.passwordTextField.text else { return }
        
//        let emailTemp = "chris"
        let passwordTemp = "passwordA1#"
        
        self.passwordAuthenticationCompletion?.setResult(AWSCognitoIdentityPasswordAuthenticationDetails(username: email, password: passwordTemp))
    }
    
    
}
