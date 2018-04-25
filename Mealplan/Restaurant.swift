//
//  Restaurant.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 3/25/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import Foundation

////////#WARNING Eventually whereever Restaurant or MenuItem is used add a "if(Restaurant != nil)" check because right now one tiny mistake in the database can fuck up the entire app - DONT BE FUCKING STUPID

struct Restaurant {
    
    var title: String
    var address: String // Could become an enum
    var hours: Array<Any>
    var price: Int // from 1-3
    var rating: Float // from 1 -5
    //replace with average rating or API rating
    var icon: String
    var images: Array<Any>
    var id: String
    var categories: Array<String>
    var description: String
    var discounts: Array<String>
    var open: Bool
    
    
    var dictionary: [String: Any] {
        return [
            "icon": icon,
            "hours": hours,
            "address": address,
            "title": title,
            "rating": rating,
            "images": images,
            "price": price,
            "id": id,
            "categories": categories,
            "description": description,
            "discounts": discounts,
            "open": open

        ]
    }
    
}

extension Restaurant: DocumentSerializable {

    static func imageURL(forName name: String) -> URL {
        let number = (abs(name.hashValue) % 22) + 1
        let URLString =
        "https://storage.googleapis.com/firestorequickstarts.appspot.com/food_\(number).png"
        return URL(string: URLString)!
    }
    
    init?(dictionary: [String : Any]) {
        guard let title = dictionary["title"] as? String,
            let address = dictionary["address"] as? String,
            let hours = dictionary["hours"] as? Array<Any>,
            let price = dictionary["price"] as? Int,
            let rating = dictionary["rating"] as? Float,
            let icon = dictionary["icon"] as? String,
            let images = dictionary["images"] as? Array<Any>,
            let id = dictionary["id"] as? String,
            let categories = dictionary["categories"] as? Array<String>,
            let description = dictionary["description"] as? String,
            let discounts = dictionary["discounts"] as? Array<String>,
            let open = dictionary["open"] as? Bool
            else{
                return nil
            }

        
        self.init(title: title,
                  address: address,
                  hours: hours,
                  price: price,
                  rating: rating,
                  icon: icon,
                  images: images,
                  id: id,
                  categories: categories,
                  description: description,
                  discounts: discounts,
                  open: open
                    )
    }


}


