//
//  RestaurantTableViewCell.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 3/25/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import Foundation
import UIKit

class RestaurantTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    func populate(restaurant: Restaurant) {
        
        titleLabel.text = restaurant.title
        cellView.layer.cornerRadius = 15
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}
