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
    private var textTitle: String!
    private var textContent: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if textTitle != "About the Goet App" {
            navigationItem.rightBarButtonItem = nil
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
    
    @IBAction func handleEmailTap(_ sender: UIBarButtonItem) {
        let emailComposeVC = configureEmailComposeVC()
        if MFMailComposeViewController.canSendMail() {
            present(emailComposeVC, animated: true, completion: nil)
        } else {
            showSendEmailErrorAlert()
        }
    }
    
    private func configureEmailComposeVC() -> MFMailComposeViewController {
        let emailComposeVC = MFMailComposeViewController()
        emailComposeVC.mailComposeDelegate = self
        
        emailComposeVC.setToRecipients(["contact@lazyself.io"])
        emailComposeVC.setSubject("About Goet App.")
        emailComposeVC.setMessageBody("", isHTML: false)
        
        return emailComposeVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    private func showSendEmailErrorAlert() {
        let alert = UIAlertController(
            title: "Email cannot be sent.",
            message: "Sorry, email cannot be sent for now, please try at a later time.",
            actions: [.ok]
        )
        present(alert, animated: false, completion: nil)
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
