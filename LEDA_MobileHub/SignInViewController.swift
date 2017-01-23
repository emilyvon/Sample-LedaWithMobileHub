//
//  SignInViewController.swift
//  LEDA_MobileHub
//
//  Created by Mengying Feng on 13/1/17.
//  Copyright © 2017 iEmRollin. All rights reserved.
//

import UIKit
import AWSMobileHubHelper
import AWSCognitoIdentityProvider

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
//    var didSignInObserver: AnyObject!
    
    var passwordAuthenticationCompletion: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
//        didSignInObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AWSIdentityManagerDidSignIn, object: AWSIdentityManager.defaultIdentityManager(), queue: OperationQueue.main, using: { (notification: Notification) in
//            // perform successful login actions here
//            
//            print("perform successful login actions here ✅")
//            
//        })
        
    }
    
//    deinit {
//        NotificationCenter.default.removeObserver(didSignInObserver)
//    }
    
    @IBAction func signInBtnPressed(_ sender: Any) {
        
        handleCustomSignIn()
        
    }
    
    func handleLoginWithSignInProvider(signInProvider: AWSSignInProvider) {
        
        AWSIdentityManager.defaultIdentityManager().loginWithSign(signInProvider) { (result: Any?, error: Error?) in
            DispatchQueue.main.async {
                if error == nil {
                    // handle successful login
                    
                    print("handle successful login ✅")
                    self.dismiss(animated: true, completion: nil)
                    
                }
                print("❗️ Login with signin provider result = \(result), error = \(error?.localizedDescription)")
            }
            
        }
        
    }
    
    func handleCustomSignIn() {
        
        AWSCognitoUserPoolsSignInProvider.sharedInstance().setInteractiveAuthDelegate(self)
        
        self.handleLoginWithSignInProvider(signInProvider: AWSCognitoUserPoolsSignInProvider.sharedInstance())
        
    }
}

extension SignInViewController: AWSCognitoIdentityInteractiveAuthenticationDelegate {
    
    func startPasswordAuthentication() -> AWSCognitoIdentityPasswordAuthentication {
        return self
    }
    
}

extension SignInViewController: AWSCognitoIdentityPasswordAuthentication {
    
    func getDetails(_ authenticationInput: AWSCognitoIdentityPasswordAuthenticationInput, passwordAuthenticationCompletionSource: AWSTaskCompletionSource<AWSCognitoIdentityPasswordAuthenticationDetails>) {
        self.passwordAuthenticationCompletion = passwordAuthenticationCompletionSource
    }
    
    func didCompleteStepWithError(_ error: Error?) {
        if let err = error {
            
            print("❌ didCompleteStepWithError : \(err.localizedDescription)")
            
        }
    }
}

extension SignInViewController: AWSCognitoUserPoolsSignInHandler {
    
    func handleUserPoolSignInFlowStart() {
        //        guard let email = self.emailTextField.text, let password = self.passwordTextField.text else { return }
        
        let email = "chris"
        let password = "passwordA1#"
        
        self.passwordAuthenticationCompletion?.setResult(AWSCognitoIdentityPasswordAuthenticationDetails(username: email, password: password))
    }
    
    
}
