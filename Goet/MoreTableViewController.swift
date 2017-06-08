//
//  MoreTableViewController.swift
//  Goet
//
//  Created by Zhe Cui on 6/6/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import GoogleMaps


class MoreTableViewController: UITableViewController {

    private enum MoreItems {
        case aboutApp(String)
        case legalNotices(String)
    }
    
    private let aboutApp = "About the app..."
    
    private var items: [String: MoreItems]!
    private let dataSource = ["About the Goet App", "Google Maps Legal Notices"]
    
    private var aboutAppText: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        items = [
            dataSource[0]: MoreItems.aboutApp(aboutApp),
            dataSource[1]: MoreItems.legalNotices(GMSServices.openSourceLicenseInfo())
        ]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

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

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueToAbout", sender: tableView.cellForRow(at: indexPath))
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
            var text = ""
            guard let cellLabelText = (sender as? UITableViewCell)?.textLabel?.text else {
                fatalError("Unexpected sender.")
            }

            guard let item = items[cellLabelText] else {
                fatalError("Unexpected item.")
            }
            switch item {
            case .aboutApp(let content):
                text = content
            case .legalNotices(let content):
                text = content
            }
        
            vc.getText(title: cellLabelText, text: text)
        }
    }

}
