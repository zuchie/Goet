//
//  AboutViewController.swift
//  Goet
//
//  Created by Zhe Cui on 6/6/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import MessageUI


class AboutViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var text: UITextView!
    @IBOutlet weak var textBottomToBottomLayoutGuideOffset: NSLayoutConstraint!
    @IBOutlet weak var sendFeedback: UIButton!
    
    private var textTitle: String!
    private var textContent: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if textTitle != "About the App" {
            sendFeedback = nil
            textBottomToBottomLayoutGuideOffset.constant = 0
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = textTitle
        
        DispatchQueue.main.async {
            self.text.text = self.textContent
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func sendFeedbackButtonTapped(_ sender: Any) {
        let emailComposeVC = configureEmailComposeVC()
        if MFMailComposeViewController.canSendMail() {
            present(emailComposeVC, animated: true, completion: nil)
        }
    }
    
    private func configureEmailComposeVC() -> MFMailComposeViewController {
        let emailComposeVC = MFMailComposeViewController()
        emailComposeVC.mailComposeDelegate = self
        if emailComposeVC.view != nil {
            emailComposeVC.view.tintColor = UIColor(red: 80 / 255, green: 170 / 255, blue: 170 / 255, alpha: 1)
        }
        
        emailComposeVC.setToRecipients(["zcui7@icloud.com"])
        emailComposeVC.setSubject("Feedback to the Goet App.")
        emailComposeVC.setMessageBody("", isHTML: false)
        
        return emailComposeVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

    func getText(title: String, text: String) {
        textTitle = title
        textContent = text
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
