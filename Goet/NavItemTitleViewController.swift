//
//  NavItemTitleViewController.swift
//  Goet
//
//  Created by Zhe Cui on 5/23/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit

class NavItemTitleViewController: UIViewController {

    @IBOutlet weak var chooseRadius: UIStackView!
    @IBOutlet weak var chooseCategory: UIStackView!
    var completionForCategoryChoose: (() -> Void)!
    var completionForRadiusChoose: (() -> Void)!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapChooseRadius = UITapGestureRecognizer(target: self, action: #selector(handleChooseRadiusTap(_:)))
        chooseRadius.addGestureRecognizer(tapChooseRadius)
        
        let tapChooseCategory = UITapGestureRecognizer(target: self, action: #selector(handleChooseCategoryTap(_:)))
        chooseCategory.addGestureRecognizer(tapChooseCategory)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc private func handleChooseCategoryTap(_ sender: UITapGestureRecognizer) {
        guard (sender.view != nil) else {
            fatalError("Unexpected view: \(String(describing: sender.view))")
        }
        completionForCategoryChoose()
    }

    @objc private func handleChooseRadiusTap(_ sender: UITapGestureRecognizer) {
        guard (sender.view != nil) else {
            fatalError("Unexpected view: \(String(describing: sender.view))")
        }
        completionForRadiusChoose()
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
