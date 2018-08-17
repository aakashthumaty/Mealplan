//
//  OrderItem.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 3/31/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestore

struct OrderItem {
    
    var price: [Float]
    var name: String
    var addons: [String]
    var discAmount: Discount
    
    var dictionary: [String: Any] {
        return [
            "price": price,
            "name": name,
            "addons": addons,
            "discAmount": discAmount
        ]
    }
    
}

//struct FirestoreOrderItem {
//    let documentID: String!
//    var name: String
//    var price: Float
//}
//
//extension FirestoreOrderItem: FirestoreModel {
//    
//    init?(modelData: FirestoreModelData) {
//        try? self.init(
//            documentID: modelData.documentID,
//            isbn: modelData.value(forKey: "isbn"),
//            title: modelData.value(forKey: "title")
//        )
//    }
//}

struct Discount {
    
    var amount: Float
    var count: Float
    //var description: String
    var item: String
    var shortDescription: String
    var type: String
    var cat: String

    
    var dictionary: [String: Any] {
        return [
            "amount": amount,
            "count": count,
            //"description": description,
            "item": item,
            "shortDescription": shortDescription,
            "type": type,
            "cat": cat
            
        ]
    }
    
}

extension Discount: DocumentSerializable {
    
    
    init?(dictionary: [String : Any]) {
        guard
            //let description = dictionary["description"] as? String,
            let item = dictionary["item"] as? String,
            let shortDescription = dictionary["shortDescription"] as? String,
            let type = dictionary["type"] as? String,
            let cat = dictionary["cat"] as? String

            else{
                return nil
        }
        let amount = (dictionary["amount"] as! NSNumber).floatValue
        let count = (dictionary["count"] as! NSNumber).floatValue
        
        self.init(
            amount: amount,
            count: count,
            //description: description,
            item: item,
            shortDescription: shortDescription,
            type: type,
            cat: cat
            
            
        )
    }
    
    
}




struct Order {
    
    var restaurant: String
    var restPrice: Float
    var time: Date
    var fullPrice: Float
    var orderItems: [Dictionary<String, Any>]

    
    
    var dictionary: [String: Any] {
        return [
            "restaurant": restaurant,
            "restPrice": restPrice,
            "time": time,
            "fullPrice": fullPrice,
            "orderItems": orderItems
        ]
    }
    
}

extension Order: DocumentSerializable {
    
    
    init?(dictionary: [String : Any]) {
        guard  let restaurant = dictionary["restaurant"] as? String,
//            let restPrice = dictionary["restPrice"] as? Float,
            let time = dictionary["time"] as? Date,
//            let fullPrice = dictionary["fullPrice"] as? Float,
            let orderItems = dictionary["orderItems"] as? [Dictionary<String, Any>]

            else{
                return nil
        }
        
        let restPrice = (dictionary["restPrice"] as! NSNumber).floatValue
        let fullPrice = (dictionary["fullPrice"] as! NSNumber).floatValue

        
        self.init(
            restaurant: restaurant,
            restPrice: restPrice,
            time: time,
            fullPrice: fullPrice,
            orderItems: orderItems

            
            
        )
    }
}
