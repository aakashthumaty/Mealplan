//
//  ItemTableViewCell.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 3/26/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit

class ItemTableViewCell: UITableViewCell {
    
    //content of this class is from more specific to less specific (top to bottom)
    

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func populate(item: MenuItem) {
        print("where my cells at \(item)")
        titleLabel.text = item.name
        cellView.layer.cornerRadius = 6
        descriptionLabel.text = item.description
        priceLabel.text = "$\(item.price)"
        
    }

}
