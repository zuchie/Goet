//
//  FoodCategoriesCollectionViewController.swift
//  Goet
//
//  Created by Zhe Cui on 11/29/16.
//  Copyright © 2016 Zhe Cui. All rights reserved.
//

import UIKit

class FoodCategoriesCollectionViewController: UICollectionViewController {
    
    // MARK: - Properties
    //fileprivate let sectionInsets = UIEdgeInsets(top: 20.0, left: 5.0, bottom: 10.0, right: 5.0)
    //fileprivate let itemsPerRow = 3
    
    fileprivate var foodCategoriesName = ["All", "Chinese", "Mexican", "Italian", "American", "Japanese", "French", "Korean", "Indian", "Mediterranean"]
    
    fileprivate var category: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            fatalError("Couldn't get layout.")
        }
        layout.invalidateLayout()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    fileprivate func configureCell(_ cell: FoodCategoriesCollectionViewCell, _ indexPath: IndexPath) {
        cell.backgroundView = UIImageView(image: UIImage(named: foodCategoriesName[indexPath.row].lowercased()))
        cell.nameLabel.text = foodCategoriesName[indexPath.row]
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return foodCategoriesName.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FoodCategoriesCell", for: indexPath) as! FoodCategoriesCollectionViewCell
    
        // Configure the cell
        configureCell(cell, indexPath)
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    */
    
    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        
        let cell = collectionView.cellForItem(at: indexPath) as! FoodCategoriesCollectionViewCell
        
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor.darkGray.cgColor
        
        return true
    }
    */
    
    func getCategory() -> String? {
        print("return category: \(String(describing: category))")        
        return category
    }
    
    // Highlight selected cell & pass data.
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCell = collectionView.cellForItem(at: indexPath) as! FoodCategoriesCollectionViewCell
        
        selectedCell.layer.borderWidth = 2.0
        selectedCell.layer.borderColor = UIColor.brown.cgColor
        
        //YelpUrlQueryParameters.category = selectedCell.nameLabel.text?.lowercased()
        category = selectedCell.nameLabel.text
        
        /* 
         Set unwind segue from collection cell to Exit, it'll segue before collection view finish doing didSelectItemAt so category will be nil. Changed to segue from view controller instead of from cell to Exit, and manually trigger segue here to make it work.
        */
        /*
        if navigationController!.isNavigationBarHidden {
            navigationController?.navigationBar.isHidden = false
        }
        */
        performSegue(withIdentifier: "unwindFromCategories", sender: self)
    }
    
    // Clear highlight.
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let deselectedCell = collectionView.cellForItem(at: indexPath) {
            deselectedCell.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        print("category segue")
        if let destinationVC = segue.destination as? MainTableViewController {
            destinationVC.category = getCategory()
        }
    }
    */
}

// Flow Layout.
extension FoodCategoriesCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    // Calculate Cell size.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var itemsPerRow: Int
        if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
            itemsPerRow = 3
        } else {
            itemsPerRow = 5
        }

        let myLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let padding = myLayout.sectionInset.left + myLayout.sectionInset.right + myLayout.minimumInteritemSpacing * CGFloat(itemsPerRow - 1)
        let availableWidth = view.frame.width - padding
        let itemWidth = availableWidth / CGFloat(itemsPerRow)
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    // Section insets.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        var insets: UIEdgeInsets
        if UIInterfaceOrientationIsPortrait(UIApplication.shared.statusBarOrientation) {
            insets = UIEdgeInsets(top: 20.0, left: 5.0, bottom: 10.0, right: 5.0)
        } else {
            insets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        }
        return insets
            
    }
    
    // Space between cells.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
    
    // Space between each line.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5.0
    }
}
