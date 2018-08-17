//
//  MenuItem.swift
//  Mealplan
//
//  Created by Cara Price on 3/26/18.
//  Copyright © 2018 Cara Price. All rights reserved.
//

import Foundation

struct MenuItem {
    
    var name: String
    var description: String
    var price: Float
    var addons: Dictionary<String, Array<Any>>
    var cat: String
    var hasaddons: Bool
    
    var dictionary: [String: Any] {
        return [
        "name": name,
        "description": description,
        "price": price,
        "addons": addons,
        "cat": cat,
        "hasaddons": hasaddons
        
        
        ]
    }
    
}

extension MenuItem: DocumentSerializable {
    
    
    init?(dictionary: [String : Any]) {
      guard  let name = dictionary["name"] as? String,
        let description = dictionary["description"] as? String,
        let addons = dictionary["addons"] as? Dictionary<String, Array<Any>>,
        let cat = dictionary["cat"] as? String,
        let hasaddons = dictionary["hasaddons"] as? Bool
        else{
            return nil
        }
        let price = (dictionary["price"] as! NSNumber).floatValue
        
        self.init(
                  name: name,
                  description: description,
                  price: price,
                  addons: addons,
                  cat:cat,
                  hasaddons:hasaddons
            
        )
    }
    
    
}
