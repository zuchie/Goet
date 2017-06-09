//
//  AboutViewController.swift
//  Goet
//
//  Created by Zhe Cui on 6/6/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit


class AboutViewController: UIViewController {

    @IBOutlet weak var text: UITextView!
    private var textTitle: String!
    private var textContent: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if textTitle != "About the App" {
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
