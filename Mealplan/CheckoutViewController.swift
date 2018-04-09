//
//  CheckoutViewController.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 4/5/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit
import Firebase


class CheckoutViewController: UIViewController {

    @IBOutlet weak var orderButton: UIButton!
    
    var rest: Restaurant!
    var userEmail: String = ""
    var username: String = ""
    var order: [OrderItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        self.username = defaults.string(forKey: "username")!

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func placeOrder(_ sender: Any) {
        print("wat")
        
//add the roder to the root order collection
        var obj: [Dictionary<String, Any>] = [[:]]
        let db = Firestore.firestore()
        for ord in order{
//
            var ele: Dictionary<String, Any> = [:]
            print("hi hello pls \(ord.name)")

            ele["name"] = ord.name
            ele["addons"] = ord.addons
            ele["price"] = ord.price
//
            print("hi hello pls \(ord.dictionary)")
            
            obj.append(ele)

        }
        obj.remove(at: 0)
        db.collection("orders").document().setData([
            "restaurant": rest?.id,
            "user": userEmail,
            "orderItems": obj,
            "username": username,
            "time": FieldValue.serverTimestamp()
            ])
        
        db.collection("users").document(self.username).collection("orders").document().setData([
            "restaurant": rest?.id,
            "user": userEmail,
            "orderItems": obj,
            "time": FieldValue.serverTimestamp()])
//add the order to the user
        //get the current state of user's restaurant properties
        //let docRef = db.collection("users").document(username)
        var touchArray: [String] = []
        var pointForRest: Int = 0
        var restID = self.rest.id

        
        
        
        
        let sfReference = db.collection("users").document(self.username)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            print("\(restID).points")
            var oldRestPoints = sfDocument.data()?["\(restID)"] as? Dictionary<String,Int>

            guard var oldTouched = sfDocument.data()?["touched"] as? [String] else {
                let error = NSError(
                    domain: "AppErrorDomain",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Unable to retrieve touched from snapshot \(sfDocument)"
                    ]
                )
                errorPointer?.pointee = error
                return nil
            }
            if(oldTouched.contains(restID)){
                
            }else{
                oldTouched.append(restID)
            }
            
            var pointsToAdd: Int = 0
            if(oldRestPoints == nil){
                pointsToAdd = 1
            }else{
                pointsToAdd = oldRestPoints!["points"]!+1
            }
            transaction.updateData([
                "\(restID).points": pointsToAdd,
                "touched": oldTouched
                
                ], forDocument: sfReference)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
