//
//  ForgotViewController.swift
//  LEDA
//
//  Created by Mengying Feng on 1/11/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit

class ForgotViewController: UIViewController {
    
    var passedEmail: String!
    
    @IBOutlet weak var backToLoginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let attrs = [
            NSFontAttributeName : UIFont(name: "Gilroy-Medium", size: 15.0)!,
            NSForegroundColorAttributeName : UIColor(red: 50/255, green: 185/255, blue: 221/255, alpha: 1.0),
            NSUnderlineStyleAttributeName : 1] as [String : Any]
        
        let str = NSMutableAttributedString(string: "Back to Login", attributes: attrs)
        backToLoginButton.setAttributedTitle(str, for: .normal)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        emailTextField.text = passedEmail
    }

    @IBAction func backBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendBtnPrssed(_ sender: UIButton) {
        dismissKeyboard()
        
        guard let email = emailTextField.text else {
            return
        }
        
        if email.isEmpty {
            showAlert(msgStr: "Email cannot be empty")
        } else if !email.isValidEmail() {
            showAlert(msgStr: "Invalid email format")
        } else {
            // TODO: 1. email is not registered, 2. password is incorrect
            
            AWSClientManager.shared.forgotPassword {
                self.showAlert(msgStr: "A link to reset your password has been sent to \(email)")
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        dismissKeyboard()
    }
    
    func dismissKeyboard() {
        emailTextField.resignFirstResponder()
    }

    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
}

extension ForgotViewController: SwiftAlertViewDelegate {
    
    func showAlert(msgStr: String) {
        
        let alertView = SwiftAlertView(title: nil, message: msgStr, delegate: self, cancelButtonTitle: "OK", otherButtonTitles: nil)
        
        alertView.backgroundColor = UIColor.white
        
        alertView.messageLabel.textColor = COLOR_TEXT_DARK_GRAY
        alertView.messageLabel.font = UIFont(name: CUSTOM_FONT_MEDIUM, size: FONT_SIZE_ALERT_SMALL)
        
        alertView.buttonAtIndex(0)?.setTitleColor(COLOR_LIGHT_BLUE, for: UIControlState())
        alertView.buttonAtIndex(0)?.titleLabel?.font = UIFont(name: CUSTOM_FONT_BOLD, size: FONT_SIZE_ALERT_SMALL)
        
        alertView.show()
    }
    
}
