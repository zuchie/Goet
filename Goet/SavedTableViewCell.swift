//
//  SavedTableViewCell.swift
//  Goet
//
//  Created by Zhe Cui on 3/18/17.
//  Copyright © 2017 Zhe Cui. All rights reserved.
//

import UIKit

class SavedTableViewCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var categories: UILabel!

    var yelpUrl: String!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
