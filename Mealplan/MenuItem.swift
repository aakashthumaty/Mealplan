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
    
    
    var dictionary: [String: Any] {
        return [
        "name": name,
        "description": description,
        "price": price,
        "addons": Dictionary<String, Array<Any>>(),
        "cat": cat
        
        
        ]
    }
    
}

extension MenuItem: DocumentSerializable {
    
    
    init?(dictionary: [String : Any]) {
      guard  let name = dictionary["name"] as? String,
        let price = dictionary["price"] as? Float,
        let description = dictionary["description"] as? String,
        let addons = dictionary["addons"] as? Dictionary<String, Array<Any>>,
        let cat = dictionary["cat"] as? String
        else{
            return nil
        }
        
        
        self.init(
                  name: name,
                  description: description,
                  price: price,
                  addons: addons,
                  cat:cat
            
        )
    }
    
    
}
