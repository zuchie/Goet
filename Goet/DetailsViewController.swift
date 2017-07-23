//
//  DetailsViewController.swift
//  Goet
//
//  Created by Zhe Cui on 7/23/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    typealias JSON = [String: Any?]
    var businessID: String?
    var photoUrls: [String]?
    var photos: [UIImage]?
    var reviews: [JSON]?
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var photo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // TODO: Download images and reviews from Yelp.
        downloadPhotosAndReviews() { (photos, reviews) in
            
            self.photoUrls = photos
            self.pageControl.numberOfPages = self.photoUrls!.count
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handlePageChange(_ sender: UIPageControl) {
        let index = sender.currentPage
            photo.image = photos?[index]
    }

    func getID(_ id: String) {
        businessID = id
    }
    
    func downloadPhotosAndReviews(completionHandler: @escaping ([String], JSON) -> Void) {
        
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
