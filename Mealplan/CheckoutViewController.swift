//
//  CheckoutViewController.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 4/5/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import BraintreeDropIn
import Braintree
import OneSignal
import PopupDialog

//import Braintree/Venmo

class CheckoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkoutCell",
                                                 for: indexPath) as! CheckoutTableViewCell
        
        
        
        var o: OrderItem = self.order[indexPath.row]
        
        cell.orderItemTitle.text = o.name
        cell.orderItemDescription.text = o.addons.joined(separator: ", ")
        
        var totPrice = o.price.reduce(0, +)
        var finalPrice = totPrice - totPrice*o.discAmount.amount
        cell.orderItemCost.text = "\(finalPrice)"
        if(o.discAmount.amount > 0){
            cell.orderItemCost.textColor = UIColor.green
        }
        return cell
    }
    

    @IBOutlet weak var checkoutTable: UITableView!
    @IBOutlet weak var checkoutTitle: UILabel!
    
    @IBOutlet weak var orderButton: UIButton!
    
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var taxLabel: UILabel!
    var rest: Restaurant!
    var userEmail: String = ""
    var username: String = ""
    var order: [OrderItem] = []
    var fullPrice:Float = 0.0
    var restPrice: Float = 0.0
    var name: String = ""
    var orderPlaced = false;
    var exit = false;
    var triedOrder = false;
    
    var dito = ""
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func tidoSelected(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0:
            dito = "TAKE OUT"
        case 1:
            dito = "DINE IN"
        default:
            break
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        self.username = defaults.string(forKey: "username")!

        var db = Firestore.firestore()
        let meReference = db.collection("users").document(self.username)
        
        var tempMe: OurUser!
        
        meReference.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                //print("Document data: \(dataDescription)")
                tempMe = OurUser(dictionary: document.data()!)
                self.name = tempMe.name
                
            } else {
                //print("Document does not exist")
            }
        }
        
        //print("this is the final order")

        self.checkoutTable.delegate = self
        self.checkoutTable.dataSource = self
        
        self.checkoutTitle.text = self.rest.title
        
        //print(order)
        for o in self.order{
            fullPrice += o.price.reduce(0, +) - (o.price.reduce(0, +)*o.discAmount.amount)
            restPrice += o.price.reduce(0, +) - (o.price.reduce(0, +)*o.discAmount.amount)
        }
        //print("pretax = \(self.fullPrice)")
        self.taxLabel.text = String("$\(0.075*self.fullPrice)")
        
        self.fullPrice = self.fullPrice + 0.30 + (0.075*self.fullPrice)
        //print("post tax = \(self.fullPrice)")

        self.totalLabel.text = String("$\(self.fullPrice)")

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func xTap(_ sender: Any) {
        self.exit = true
        self.performSegue(withIdentifier: "please", sender: self)
        
    }
    func fetchClientToken(totCost: Float) {
        // TODO: Switch this URL to your own authenticated API
        
        let sv = UIViewController.displaySpinner(onView: self.view)
        
        //https://us-central1-mealplan-dd302.cloudfunctions.net/clientTokenwid
        let clientTokenURL = NSURL(string: "https://us-central1-mealplan-dd302.cloudfunctions.net/clientTokenwid?id=\(self.username)")!
        let clientTokenRequest = NSMutableURLRequest(url: clientTokenURL as URL)
        clientTokenRequest.setValue("text/plain", forHTTPHeaderField: "Accept")
        clientTokenRequest.setValue(self.username, forHTTPHeaderField: "id")

        URLSession.shared.dataTask(with: clientTokenRequest as URLRequest) { (data, response, error) -> Void in
            // TODO: Handle errors
            let clientToken = String(data: data!, encoding: String.Encoding.utf8)
            
            // As an example, you may wish to present Drop-in at this point.
            // Continue to the next section to learn more...
            self.showDropIn(clientTokenOrTokenizationKey: clientToken!, totCost: totCost)
            UIViewController.removeSpinner(spinner: sv)

            }.resume()
    }
    
    func showDropIn(clientTokenOrTokenizationKey: String, totCost: Float) {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: clientTokenOrTokenizationKey, request: request)
        { (controller, result, error) in
            if (error != nil) {
                //print("ERROR")
                //print(error)
            } else if (result?.isCancelled == true) {
                //print("CANCELLED")
            } else if let result = result {
                
                //cancel activity indicator here
                
                
                // Use the BTDropInResult properties to update your UI
                // result.paymentOptionType
                // result.paymentMethod
                // result.paymentIcon
                self.postNonceToServer(paymentMethodNonce: (result.paymentMethod?.nonce)!, totCost: totCost)
                // result.paymentDescription
//                func postNonceToServer(paymentMethodNonce: String) {
//                    // Update URL with your server
//                    let paymentURL = URL(string: "https://your-server.example.com/payment-methods")!
//                    var request = URLRequest(url: paymentURL)
//                    request.httpBody = "payment_method_nonce=\(paymentMethodNonce)".data(using: String.Encoding.utf8)
//                    request.httpMethod = "POST"
//
//                    URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
//                        // TODO: Handle success or failure
//                        }.resume()
//                }
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    
    
    func postNonceToServer(paymentMethodNonce: String, totCost: Float) {
        // Update URL with your server
        let paymentURL = URL(string: "https://us-central1-mealplan-dd302.cloudfunctions.net/postNonce?amount=\(totCost)")!
        var request = URLRequest(url: paymentURL)
        request.httpBody = "payment_method_nonce=\(paymentMethodNonce)".data(using: String.Encoding.utf8)
        request.httpMethod = "POST"
        
        
        //"https://us-central1-mealplan-dd302.cloudfunctions.net/clientTokenwid?id=\(self.username)
        
//        var obj: [Dictionary<String, Any>] = [[:]]
//        let db = Firestore.firestore()
//        for ord in self.order{
//            //
//            var ele: Dictionary<String, Any> = [:]
//            //print("hi hello pls \(ord.name)")
//
//            ele["name"] = ord.name
//            ele["addons"] = ord.addons
//            ele["price"] = ord.price
//            ele["discount"] = ord.discAmount.amount
//            //
//            //print("hi hello pls \(ord.dictionary)")
//
//            obj.append(ele)
//
//        }
//        obj.remove(at: 0)
//        db.collection("orders").document().setData([
//            "restaurant": self.rest?.id,
//            "user": self.userEmail,
//            "orderItems": obj,
//            "username": self.username,
//            "time": FieldValue.serverTimestamp(),
//            "fullPrice": self.fullPrice,
//            "restPrice": self.restPrice,
//            "fullname": self.name
//            ])
//
//        db.collection("users").document(self.username).collection("orders").document().setData([
//            "restaurant": self.rest?.id,
//            "user": self.userEmail,
//            "orderItems": obj,
//            "time": FieldValue.serverTimestamp(),
//            "fullPrice": self.fullPrice,
//            "restPrice": self.restPrice,
//            "fullname": self.name
//            ])
//        //add the order to the user
//        //get the current state of user's restaurant properties
//        //let docRef = db.collection("users").document(username)
//        var touchArray: [String] = []
//        var pointForRest: Int = 0
//        var restID = self.rest.id
//
//
        
        
        
//        let sfReference = db.collection("users").document(self.username)
//
//        db.runTransaction({ (transaction, errorPointer) -> Any? in
//            let sfDocument: DocumentSnapshot
//            do {
//                try sfDocument = transaction.getDocument(sfReference)
//            } catch let fetchError as NSError {
//                errorPointer?.pointee = fetchError
//                return nil
//            }
//
//            //print("\(restID).points")
//            var oldRestPoints = sfDocument.data()?["\(restID)"] as? Dictionary<String,Int>
//
//            guard var oldTouched = sfDocument.data()?["touched"] as? [String] else {
//                let error = NSError(
//                    domain: "AppErrorDomain",
//                    code: -1,
//                    userInfo: [
//                        NSLocalizedDescriptionKey: "Unable to retrieve touched from snapshot \(sfDocument)"
//                    ]
//                )
//                errorPointer?.pointee = error
//                return nil
//            }
//            if(oldTouched.contains(restID)){
//
//            }else{
//                oldTouched.append(restID)
//            }
//
//            var pointsToAdd: Int = 0
//            if(oldRestPoints == nil){
//                pointsToAdd = 1
//            }else{
//                pointsToAdd = oldRestPoints!["points"]!+1
//            }
//            transaction.updateData([
//                "\(restID).points": pointsToAdd,
//                "touched": oldTouched
//
//                ], forDocument: sfReference)
//            return nil
//        }) { (object, error) in
//            if let error = error {
//                //print("Transaction failed: \(error)")
//            } else {
//                //print("Transaction to firestore successfully committed!")
//            }
//        }
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            // TODO: Handle success or failure
            
            if(error != nil){
                
                let db = Firestore.firestore()
                
                //var friendAdding = self.addFriendField.text
                let fReference = db.collection("users").document((self.username))
                
                var temp: OurUser!
                fReference.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        //print("Document data: \(dataDescription)")
                        temp = OurUser(dictionary: document.data()!)
                        
                        
                        let message = "There was an error processing your payment method, your order was not placed. Please try a different card or make sure your information is accurate."
                        let notificationContent = [
                            //35805a71-5aae-43b3-ae04-ec928cadaf0b
                            "app_id": "35805a71-5aae-43b3-ae04-ec928cadaf0b",
                            // xue p id 9f2a50ac-5a7b-4af2-92ab-f57609aa058e
                            "include_player_ids": [temp.pushToken],
                            "contents": ["en": message], // Required unless "content_available": true or "template_id" is set
                            "headings": ["en": "Payment Error, Order NOT Placed"],
                            //"subtitle": ["en": "An English Subtitle"],
                            // If want to open a url with in-app browser
                            //"url": "https://google.com",
                            // If you want to deep link and pass a URL to your webview, use "data" parameter and use the key in the AppDelegate's notificationOpenedBlock
                            //"data": ["OpenURL": "https://imgur.com"],
                            //"ios_attachments": ["id" : "https://cdn.pixabay.com/photo/2017/01/16/15/17/hot-air-balloons-1984308_1280.jpg"],
                            "ios_badgeType": "Increase",
                            "ios_badgeCount": 1
                            ] as [String : Any]
                        
                        OneSignal.postNotification(notificationContent)
                    }else{
                        
                        
                    }
                    
                }
                
                
            }
            else if(data != nil){
            let re = String(data: data!, encoding: String.Encoding.utf8)
            print(re!)

            if(error != nil || (re?.contains(find: "Error: could not handle the request"))!){
                print("error!!!!")

                
                let db = Firestore.firestore()
                
                //var friendAdding = self.addFriendField.text
                let fReference = db.collection("users").document((self.username))
                
                var temp: OurUser!
                fReference.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        //print("Document data: \(dataDescription)")
                        temp = OurUser(dictionary: document.data()!)
                        
                        
                        let message = "There was an error processing your payment method, your order was not placed. Please try a different card or make sure your information is accurate."
                        let notificationContent = [
                            //35805a71-5aae-43b3-ae04-ec928cadaf0b
                            "app_id": "35805a71-5aae-43b3-ae04-ec928cadaf0b",
                            // xue p id 9f2a50ac-5a7b-4af2-92ab-f57609aa058e
                            "include_player_ids": [temp.pushToken],
                            "contents": ["en": message], // Required unless "content_available": true or "template_id" is set
                            "headings": ["en": "Payment Error, Order NOT Placed"],
                            //"subtitle": ["en": "An English Subtitle"],
                            // If want to open a url with in-app browser
                            //"url": "https://google.com",
                            // If you want to deep link and pass a URL to your webview, use "data" parameter and use the key in the AppDelegate's notificationOpenedBlock
                            //"data": ["OpenURL": "https://imgur.com"],
                            //"ios_attachments": ["id" : "https://cdn.pixabay.com/photo/2017/01/16/15/17/hot-air-balloons-1984308_1280.jpg"],
                            "ios_badgeType": "Increase",
                            "ios_badgeCount": 1
                            ] as [String : Any]
                        
                        OneSignal.postNotification(notificationContent)
                    }else{
                        
                        
                    }
                    
                }
                // show an alert
            }else{
                print(re!)
//                self.orderPlaced = true;

                //print(response.statusCo)
                var obj: [Dictionary<String, Any>] = [[:]]
                let db = Firestore.firestore()
                for ord in self.order{
                    //
                    var ele: Dictionary<String, Any> = [:]
                    //print("hi hello pls \(ord.name)")
                    
                    ele["name"] = "\(ord.name) - \(self.dito)"
                    ele["addons"] = ord.addons
                    ele["price"] = ord.price
                    ele["discount"] = ord.discAmount.amount
                    //
                    //print("hi hello pls \(ord.dictionary)")
                    
                    obj.append(ele)
                    
                }
                //idk why it was adding an empy object at beginning
                obj.remove(at: 0)
                db.collection("orders").document().setData([
                    "restaurant": self.rest?.id,
                    "user": self.userEmail,
                    "orderItems": obj,
                    "username": self.username,
                    "time": FieldValue.serverTimestamp(),
                    "fullPrice": self.fullPrice,
                    "restPrice": self.restPrice,
                    "fullname": self.name
                    ])
                
                db.collection("users").document(self.username).collection("orders").document().setData([
                    "restaurant": self.rest?.id,
                    "user": self.userEmail,
                    "orderItems": obj,
                    "time": FieldValue.serverTimestamp(),
                    "fullPrice": self.fullPrice,
                    "restPrice": self.restPrice,
                    "fullname": self.name
                    ])
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
                    
                    //print("\(restID).points")
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
                        //print("Transaction failed: \(error)")
                    } else {
                        //print("Transaction to firestore successfully committed!")
                    }
                }
            }
            //print("order completed loodoo")
            }else{
                print("shit smae popup here")
                let db = Firestore.firestore()
                
                //var friendAdding = self.addFriendField.text
                let fReference = db.collection("users").document((self.username))
                
                var temp: OurUser!
                fReference.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        //print("Document data: \(dataDescription)")
                        temp = OurUser(dictionary: document.data()!)
                        
                        
                        let message = "There was an error processing your payment method, your order was not placed. Please try a different card or make sure your information is accurate."
                        let notificationContent = [
                            //35805a71-5aae-43b3-ae04-ec928cadaf0b
                            "app_id": "35805a71-5aae-43b3-ae04-ec928cadaf0b",
                            // xue p id 9f2a50ac-5a7b-4af2-92ab-f57609aa058e
                            "include_player_ids": [temp.pushToken],
                            "contents": ["en": message], // Required unless "content_available": true or "template_id" is set
                            "headings": ["en": "Payment Error, Order NOT Placed"],
                            //"subtitle": ["en": "An English Subtitle"],
                            // If want to open a url with in-app browser
                            //"url": "https://google.com",
                            // If you want to deep link and pass a URL to your webview, use "data" parameter and use the key in the AppDelegate's notificationOpenedBlock
                            //"data": ["OpenURL": "https://imgur.com"],
                            //"ios_attachments": ["id" : "https://cdn.pixabay.com/photo/2017/01/16/15/17/hot-air-balloons-1984308_1280.jpg"],
                            "ios_badgeType": "Increase",
                            "ios_badgeCount": 1
                            ] as [String : Any]
                        
                        OneSignal.postNotification(notificationContent)
                        
                    } else {
                        //print("Document does not exist")
                    }
                }
                
            }
            
            }.resume()
        
        self.orderPlaced = true;

               let sv = UIViewController.displaySpinner(onView: self.view)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 2 to desired
            UIViewController.removeSpinner(spinner: sv)

            self.performSegue(withIdentifier: "please", sender: self)
            
        }

        
//        self.navigationController?.popViewController(animated: true)
//        self.presentingViewController?.dismiss(animated: true, completion: nil)

//        self.dismiss(animated: true, completion: nil)
//        [self performSegue:@"unwindToViewController1" sender:self];
 


    }
    
    
    @IBAction func placeOrder(_ sender: Any) {
        //print("wat")
        if(self.dito != ""){
            var btPrice = self.fullPrice.rounded(toPlaces: 2)
            self.fetchClientToken(totCost: btPrice)
        }else{
            let title = "Please Choose To-Go or Dine In"
            let message = "At the top of the screen please select whether you'd like to take your order to-go or eat in."
            
            let popup = PopupDialog(title: title, message: message)//, image: image)
            
            let buttonTwo = DefaultButton(title: "OK", dismissOnTap: true) {
                //print("You canceled the car dialog.")
                
                OneSignal.promptForPushNotifications(userResponse: { accepted in
                    // print("User accepted notifications: \(accepted)")
                })
            }
            
            popup.addButtons([buttonTwo])
            self.present(popup, animated: true, completion: nil)
        }
        //self.orderPlaced = true
        //print("\(self.fullPrice) is the full price")
        
//add the roder to the root order collection
        
        
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

extension Float {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Float {
        let divisor = pow(10.0, Float(places))
        return (self * divisor).rounded() / divisor
    }
}

extension String {
    func contains(find: String) -> Bool{
        return self.range(of: find) != nil
    }
    func containsIgnoringCase(find: String) -> Bool{
        return self.range(of: find, options: .caseInsensitive) != nil
    }
}
