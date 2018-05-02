//
//  Post.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 4/11/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import Foundation


struct Post {
    
    var id: String
    var user: String
    var caption: String // Could become an enum
    var rating: String // from 1 -5
    //replace with average rating or API rating
    var image: String
    var friends: String
    var restaurant: String
    var licks: Int
    var gags: Int
    var time: Date

    
    
    var dictionary: [String: Any] {
        return [
            "user": user,
            "caption": caption,
            "friends": friends,
            "restaurant": restaurant,
            "rating": rating,
            "image": image,
            "licks": licks,
            "gags": gags,
            "time": time
            
        ]
    }
    
}

extension Post: DocumentSerializable {
    
    static func imageURL(forName name: String) -> URL {
        let number = (abs(name.hashValue) % 22) + 1
        let URLString =
        "https://storage.googleapis.com/firestorequickstarts.appspot.com/food_\(number).png"
        return URL(string: URLString)!
    }
    
    init?(dictionary: [String : Any]) {
        guard let user = dictionary["user"] as? String,
            let caption = dictionary["caption"] as? String,
            let restaurant = dictionary["restaurant"] as? String,
            let friends = dictionary["friends"] as? String,
            let rating = dictionary["rating"] as? String,
            let image = dictionary["image"] as? String,
            let gags = dictionary["gags"] as? Int,
            let licks = dictionary["licks"] as? Int,
            let time = dictionary["time"] as? Date
            else{
                return nil
        }
        
        
        self.init(id: "",
                  user: user,
                  caption: caption,
                  rating: rating,
                  image: image,
                  friends: friends,
                  restaurant: restaurant,
                  licks: licks,
                  gags: gags,
                  time:time
        )
    }
    
    
}


struct Gift {
    
    var sender: String
    var receiver: String // Could become an enum
    var restaurant: String // from 1 -5
    var time: Date
    
    
    
    var dictionary: [String: Any] {
        return [
            "sender": sender,
            "receiver": receiver,
            "restaurant": restaurant,
            "time": time
            
        ]
    }
    
}

extension Gift: DocumentSerializable {

    
    init?(dictionary: [String : Any]) {
        guard let sender = dictionary["sender"] as? String,
            let receiver = dictionary["receiver"] as? String,
            let restaurant = dictionary["restaurant"] as? String,
            let time = dictionary["time"] as? Date
            else{
                return nil
        }
        
        
        self.init(sender: sender,
                  receiver: receiver,
                  restaurant: restaurant,
                  time:time
        )
    }
    
    
}
