//
//  OrderItem.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 3/31/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import Foundation

struct OrderItem {
    
    var price: Float
    var name: String
    var addons: String
    
    
    var dictionary: [String: Any] {
        return [
            "price": price,
            "name": name,
            "addons": addons            
            
        ]
    }
    
}
