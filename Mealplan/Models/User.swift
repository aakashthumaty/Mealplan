//
//  User.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 4/8/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import Foundation


struct OurUser {
    
    var name: String
    var username: String
    var pushToken: String
    //var email: String
    //var required: Bool
    
    
    var dictionary: [String: Any] {
        return [
            "name": name,
            "username": username,
            "pushToken": pushToken
            //"email": email
            //"required": required,
            
            
        ]
    }
    
}


extension OurUser: DocumentSerializable {
    
    
    init?(dictionary: [String : Any]) {
        guard  let name = dictionary["name"] as? String,
            let username = dictionary["username"] as? String,
            let pushToken = dictionary["pushToken"] as? String
            //let email = dictionary["email"] as? String
            //let required = dictionary["required"] as? Bool
            else{
                return nil
        }
        
        
        self.init(
            name: name,
            username: username,
            pushToken: pushToken
            //email: email
            //required: required
            
        )
    }
    
    
}


struct Friend {
    
    var name: String
    var username: String
    var giftcount: Float
    //var email: String
    //var required: Bool
    
    
    var dictionary: [String: Any] {
        return [
            "name": name,
            "username": username,
            "giftcount": giftcount
            //"email": email
            //"required": required,
            
            
        ]
    }
    
}

extension Friend: DocumentSerializable {
    
    
    init?(dictionary: [String : Any]) {
        guard  let name = dictionary["name"] as? String,
            let username = dictionary["username"] as? String,
            let giftcount = dictionary["giftcount"] as? Float

            //let email = dictionary["email"] as? String
            //let required = dictionary["required"] as? Bool
            else{
                return nil
        }
        
        
        self.init(
            name: name,
            username: username,
            giftcount: giftcount
            //email: email
            //required: required
            
        )
    }
}
    
    
    struct fsuObject {
        
        var titles: [String]

        var dictionary: [String: Any] {
            return [
                "titles": titles
            ]
        }
        
    }
    
    
    extension fsuObject: DocumentSerializable {
        
        
        init?(dictionary: [String : Any]) {
            guard  let titles = dictionary["titles"] as? [String]
                
                else{
                    return nil
            }
            
            
            self.init(
                titles: titles
                
            )
        }
}


