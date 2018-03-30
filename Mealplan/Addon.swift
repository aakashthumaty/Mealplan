//
//  Addon.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 3/29/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import Foundation

struct Addon {

    var multOptions: Bool
    var name: String
    var options: String
    var price: Dictionary<String, Float>
    
    
    var dictionary: [String: Any] {
        return [
            "multOptions": multOptions,
            "name": name,
            "options": options,
            "price": price
            
            
        ]
    }
    
}


extension Addon: DocumentSerializable {
    
    
    init?(dictionary: [String : Any]) {
        guard  let multOptions = dictionary["multOptions"] as? Bool,
            let name = dictionary["name"] as? String,
            let options = dictionary["options"] as? String,
            let price = dictionary["price"] as? Dictionary<String, Float>
            else{
                return nil
        }
        
        
        self.init(
            multOptions: multOptions,
            name: name,
            options: options,
            price: price
            
        )
    }
    
    
}


struct AddonListCategory {
    
    var max: Float
    var name: String
    var required: Bool
    
    
    var dictionary: [String: Any] {
        return [
            "max": max,
            "name": name,
            "required": required,
            
            
        ]
    }
    
}


extension AddonListCategory: DocumentSerializable {
    
    
    init?(dictionary: [String : Any]) {
        guard  let max = dictionary["max"] as? Float,
            let name = dictionary["name"] as? String,
            let required = dictionary["required"] as? Bool
            else{
                return nil
        }
        
        
        self.init(
            max: max,
            name: name,
            required: required
            
        )
    }
    
    
}

