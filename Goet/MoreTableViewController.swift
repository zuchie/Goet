//
//  MoreTableViewController.swift
//  Goet
//
//  Created by Zhe Cui on 6/6/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import GoogleMaps
import MessageUI


class MoreTableViewController: UITableViewController, MFMailComposeViewControllerDelegate {

    private enum MoreItems {
        case aboutTheApp(String)
        case legalNotices(String)
        case sendFeedback(() -> Void)
    }
    
    private let aboutTheApp = "The Goet App is built to let you easily find best restaurants around you.\n\n" +
                            "With simply filtering the search Radius and Category, 5 top rated open restaurants will be ready for you to choose from.\n\n\n" +
                            "All data of the restaurants are from Yelp API. Restaurants are given based on the calculation by Yelp server of rating, review count, and other factors.\n\n" +
                            "All data of Maps and routes are from Google Maps SDK.\n\n\n" +
                            "Please enjoy the app, and I'd love to hear your thoughts about how it works, what's missing, anything wrong, or how it could be improved."
    
    private var items: [String: MoreItems]!
    private var dataSource = ["About the App", "Legal Notices", "Send Feedback"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = [
            dataSource[0]: MoreItems.aboutTheApp(aboutTheApp),
            dataSource[1]: MoreItems.legalNotices(GMSServices.openSourceLicenseInfo()),
            dataSource[2]: MoreItems.sendFeedback(sendFeedback)
        ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func sendFeedback() {
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
        emailComposeVC.setSubject("About the Goet App.")
        emailComposeVC.setMessageBody("", isHTML: false)
        
        return emailComposeVC
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    /*
     private func showSendEmailErrorAlert() {
     let alert = UIAlertController(
     title: "Sorry, email cannot be sent.",
     message: "Please make sure the email account has been properly configured.",
     actions: [.ok]
     )
     present(alert, animated: false, completion: nil)
     }
     */

    
    // MARK: - Table view data source
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return dataSource.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "moreCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = dataSource[indexPath.row]

        return cell
    }
    */
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let title = tableView.cellForRow(at: indexPath)?.textLabel?.text,
            let item = items[title] else {
            fatalError("Couldn't get text from cell.")
        }
        var text = ""
        switch item {
        case .aboutTheApp(let content):
            text = content
        case .legalNotices(let content):
            text = content
        case .sendFeedback(let feedback):
            feedback()
        }
        if !text.isEmpty {
            performSegue(withIdentifier: "segueToAbout", sender: (title: title, text: text))
        }
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "segueToAbout" {
            let vc = segue.destination as! AboutViewController
            guard let sender = sender as? (title: String, text: String) else {
                fatalError("Couldn't case sender.")
            }
            vc.getText(title: sender.title, text: sender.text)
        }
    }

}
