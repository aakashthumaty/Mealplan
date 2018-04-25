//
//  CheckoutTableViewCell.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 4/22/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit

class CheckoutTableViewCell: UITableViewCell {

    @IBOutlet weak var orderItemTitle: UILabel!
    @IBOutlet weak var orderItemDescription: UILabel!
    @IBOutlet weak var orderItemCost: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
