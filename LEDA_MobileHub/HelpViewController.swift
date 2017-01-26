//
//  HelpViewController.swift
//  LEDA
//
//  Created by Mengying Feng on 18/10/16.
//  Copyright © 2016 Andrew Osborne. All rights reserved.
//

import UIKit
import MessageUI
import AWSCognitoIdentityProvider

class HelpViewController: UIViewController {
    
    //========================================
    // MARK: - Properties
    //========================================
    var contactArr = ["Feedback", "Website"]
    var legalArr = ["Privacy Policy", "Terms of Use"]
    var helpArr = ["How To"]
    var sectionArr = ["Contact", "Legal", "Help"]
    
    var pool: AWSCognitoIdentityUserPool?
    var user: AWSCognitoIdentityUser?
    var response: AWSCognitoIdentityUserGetDetailsResponse?
    
    //========================================
    // MARK: - Outlets
    //========================================
    @IBOutlet weak var tableView: UITableView!
    
    //========================================
    // MARK: - View lifecycle
    //========================================
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //========================================
    // MARK: - Private methods
    //========================================
    func sendEmail() {
        
        if MFMailComposeViewController.canSendMail() {
            
            guard let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
                return
            }
            
            guard let givenName = KeychainSwift().get(KC_USER_GIVEN_NAME) else {
                print("no givenName")
                return
            }
            
//            guard let familyName = KeychainSwift().get(KC_USER_LASTNAME) else {
//                print("no familyName")
//                return
//            }
            
            guard let email = KeychainSwift().get(KC_USER_EMAIL) else {
                print("no email")
                return
            }
            
            let mail = MFMailComposeViewController()
            
            mail.mailComposeDelegate = self
            mail.setToRecipients(["feedback@leda.com"])
            mail.setSubject("Feedback")
            mail.setMessageBody("<br/><br/><br/><br/><span style=\"color: #808080;\">--------------</span><br/><span style=\"color: #808080;\">Username: \(givenName)</span><br/><span style=\"color:808080;\"><span style=\"color:#808080;\">Email:&nbsp;\(email)</span><br/></span><span style=\"color: #808080;\">App Version: \(appVersion)</span><br/><span style=\"color: #808080;\">OS: \(UIDevice.current.systemName) \(UIDevice.current.systemVersion)</span>", isHTML: true)
            
            self.present(mail, animated: true, completion: nil)
            
        } else {
            let alert = UIAlertController(title: "", message: "Please try again later", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        
    }
    
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

//========================================
// MARK: - Table view data source
//========================================
extension HelpViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section != 2 {
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HelpTableViewCell") as! HelpTableViewCell
        
        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        
        
        if indexPath.section == 0 {
            cell.titleLabel.text = contactArr[indexPath.row]
        } else if indexPath.section == 1 {
            cell.titleLabel.text = legalArr[indexPath.row]
        } else if indexPath.section == 2 {
            cell.titleLabel.text = helpArr[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Contact"
        } else if section == 1 {
            return "Legal"
        } else {
            return "Help"
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = COLOR_LIGHT_BLUE
        header.textLabel?.text = sectionArr[section].capitalized
        header.textLabel?.font = UIFont(name: "Gilroy-Bold", size: 18.0)
    }
    
    
    @objc(tableView:heightForRowAtIndexPath:) func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}

//========================================
// MARK: - Table view delegate
//========================================
extension HelpViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                sendEmail()
            } else {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: "http://getleda.com")!, options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    UIApplication.shared.openURL(URL(string: "http://getleda.com")!)
                }
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                performSegue(withIdentifier: "helpToPrivacy", sender: nil)
            } else {
                performSegue(withIdentifier: "helpToTerms", sender: nil)
            }
        } else {
            performSegue(withIdentifier: "helpToHowTo", sender: nil)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension HelpViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
