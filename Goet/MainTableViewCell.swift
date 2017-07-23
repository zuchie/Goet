//
//  MainTableViewCell.swift
//  Goet
//
//  Created by Zhe Cui on 3/1/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit

protocol MainTableViewCellDelegate: class {
    func linkToYelp(cell: MainTableViewCell)
    func showMap(cell: MainTableViewCell)
    func updateSaved(cell: MainTableViewCell, button: UIButton)
}

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var category: UILabel!
    
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var reviewCount: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var yelpButton: UIButton!
    
    
    var yelpUrl: String!
    var latitude: Double!
    var longitude: Double!
    var address: String!
    var rating: Float!
    var imageUrl: String!
    var id: String!
    
    var delegate: MainTableViewCellDelegate?
        
    override func prepareForReuse() {
        super.prepareForReuse()
        self.delegate = nil
    }
    
    @IBAction func handleMapButton(_ sender: UIButton) {
        self.delegate?.showMap(cell: self)
    }
    
    @IBAction func handleYelpButton(_ sender: UIButton) {
        self.delegate?.linkToYelp(cell: self)
    }
    
    @IBAction func handleLikeButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.delegate?.updateSaved(cell: self, button: sender)
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //likeButton.setImage(emptyStar, for: .normal)
        //likeButton.setImage(filledStar, for: .selected)
        
        // Yelp 5-star Red logo background color.
        yelpButton.backgroundColor = UIColor(red: 211 / 255, green: 35 / 255, blue: 35 / 255, alpha: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
