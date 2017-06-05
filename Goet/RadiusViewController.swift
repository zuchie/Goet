//
//  RadiusViewController.swift
//  Goet
//
//  Created by Zhe Cui on 5/30/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit

class RadiusViewController: UIViewController {
    
    private(set) var radius: Int? = 1600
    private let radiusImgDict = [800: "Radius0", 1600: "Radius1", 8000: "Radius2", 16000: "Radius3", 32000: "Radius4"]
    @IBOutlet weak var radiuses: UIImageView!
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var radiusesWidth: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationController?.navigationBar.isHidden = true
        
        if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
            radiusesWidth.constant = view.frame.width
        } else {
            radiusesWidth.constant = view.frame.height
        }
        radiuses.image = UIImage(named: radiusImgDict[radius!]!)
        
        okButton.layer.cornerRadius = okButton.frame.width / 2
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tap(_ sender: UITapGestureRecognizer) {
        if sender.state == .recognized {
            let location = sender.location(in: radiuses)
            guard let rad = getRadiusByLocation(location) else {
                print("Couldn't get radius by location.")
                return
            }
            radius = rad
            guard let name = radiusImgDict[radius!] else {
                fatalError("Couldn't find an img from given distance.")
            }
            radiuses.image = UIImage(named: name)
        }
    }
    
    private func getRadiusByLocation(_ location: CGPoint) -> Int? {
        let center = CGPoint(x: radiuses.frame.width / 2, y: radiuses.frame.height / 2)
        let distance = hypot(location.x - center.x, location.y - center.y)
        // Get scaler from radius pdf files.
        let radiusesWidthToHalfMiRadiusRatio: CGFloat = 180.0 / 30.0
        let minRadius = (radiuses.frame.width / 2) / radiusesWidthToHalfMiRadiusRatio
        switch distance {
        case 0..<minRadius:
            return 800
        case minRadius..<minRadius * 2:
            return 1600
        case minRadius * 2..<minRadius * 3:
            return 8000
        case minRadius * 3..<minRadius * 4:
            return 16000
        case minRadius * 4..<minRadius * 5:
            return 32000
        default:
            return nil
        }
    }
    
    func getRadius(radius: Int?) {
        self.radius = radius
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
