//
//  CheckoutViewController.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 4/5/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit
import Firebase
import BraintreeDropIn
import Braintree
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

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        self.username = defaults.string(forKey: "username")!

        //print("this is the final order")

        self.checkoutTable.delegate = self
        self.checkoutTable.dataSource = self
        
        self.checkoutTitle.text = self.rest.title
        
        //print(order)
        for o in self.order{
            fullPrice += o.price.reduce(0, +) - (o.price.reduce(0, +)*o.discAmount.amount)
        }
        //print("pretax = \(self.fullPrice)")
        self.taxLabel.text = String(0.075*self.fullPrice)
        
        self.fullPrice = self.fullPrice + 0.30 + (0.075*self.fullPrice)
        //print("post tax = \(self.fullPrice)")

        self.totalLabel.text = String(self.fullPrice)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        URLSession.shared.dataTask(with: request) { (data, response, error) -> Void in
            // TODO: Handle success or failure

            //print("order completed loodoo")
            
            }.resume()
        
        
        self.performSegue(withIdentifier: "please", sender: self)
        
//        self.navigationController?.popViewController(animated: true)
//        self.presentingViewController?.dismiss(animated: true, completion: nil)

//        self.dismiss(animated: true, completion: nil)
//        [self performSegue:@"unwindToViewController1" sender:self];
 


    }
    
    
    @IBAction func placeOrder(_ sender: Any) {
        //print("wat")
        self.fetchClientToken(totCost: self.fullPrice)
        
        //print("\(self.fullPrice) is the full price")
        
//add the roder to the root order collection
        var obj: [Dictionary<String, Any>] = [[:]]
        let db = Firestore.firestore()
        for ord in order{
//
            var ele: Dictionary<String, Any> = [:]
            //print("hi hello pls \(ord.name)")

            ele["name"] = ord.name
            ele["addons"] = ord.addons
            ele["price"] = ord.price
            ele["discount"] = ord.discAmount.amount
//
            //print("hi hello pls \(ord.dictionary)")
            
            obj.append(ele)

        }
        obj.remove(at: 0)
        db.collection("orders").document().setData([
            "restaurant": rest?.id,
            "user": userEmail,
            "orderItems": obj,
            "username": username,
            "time": FieldValue.serverTimestamp(),
            "fullPrice": fullPrice
            ])
        
        db.collection("users").document(self.username).collection("orders").document().setData([
            "restaurant": rest?.id,
            "user": userEmail,
            "orderItems": obj,
            "time": FieldValue.serverTimestamp(),
            "fullPrice": fullPrice])
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
