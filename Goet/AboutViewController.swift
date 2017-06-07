//
//  AboutViewController.swift
//  Goet
//
//  Created by Zhe Cui on 6/6/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit
import GoogleMaps

class AboutViewController: UIViewController {

    @IBOutlet weak var text: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let attribution = GMSServices.openSourceLicenseInfo()
        text.text = attribution
        //print("attribution: \(attribution)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
