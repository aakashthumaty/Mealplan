//
//  SendFriendViewController.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 4/7/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit
import Firebase
import OneSignal
import PopupDialog

class SendFriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var rest: Restaurant!
    var userEmail: String!
    var username: String!
    var friendArr: [Friend] = []
    
    @IBOutlet weak var giftTitle: UILabel!
    
    @IBOutlet weak var friendTable: UITableView!
    @IBOutlet weak var sendToUserInput: UITextField!
    @IBOutlet weak var sendToUser: UIButton!
    @IBOutlet weak var sendToRandom: UIButton!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print(self.friendArr)
        if(self.friendArr != nil){
            return self.friendArr.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell",
                                                 for: indexPath) as! FriendTableViewCell
        
        cell.populate(friend: friendArr[indexPath.row])
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    self.navigationController?.setNavigationBarHidden(true, animated: false)
        sendToUserInput.setBottomBorder()

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.friendTable.delegate = self;
        self.friendTable.dataSource = self;
        
        let db = Firestore.firestore()
        //print("this the email though \(self.userEmail)")
        db.collection("users/\(self.username!)/friends").getDocuments() { (querySnapshot, err) in
            if let err = err {
                //print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    //print(" 1 \(document["name"])")
                    //if(document.data()){
                    
                    var pls = Friend(dictionary: document.data())
                    
//                    var newDick: Dictionary<String,Any>!
//                    if document["name"] != nil{
//                        newDick["name"] = document["name"] as? String
//                        newDick["username"] = document["username"] as? String
//                    }
                    if(pls != nil){
                        self.friendArr.append(pls!)
                    }else{
                        //print("aiyah Database")
                    }

                    //}
                    
                    
                }
                //print(self.friendArr.count)
                self.friendTable.reloadData()

                let launchedBefore = UserDefaults.standard.bool(forKey: "firstsendfriend")
                if launchedBefore  {
                    // not first sendfriend
                }else{
                    //first sendfriend
                    let title = "YOU GET TO GIFT A POINT"
                    let message = "Everytime you order food you get one point to keep AND one point to send! Pick a friend from this list to send a gift to or send one to a rando at the bottom! P.S. If you want to add friends, add them from the friends tab."
                    
                    let popup = PopupDialog(title: title, message: message)//, image: image)
                    
                    let buttonTwo = DefaultButton(title: "OK", dismissOnTap: true) {
                        //print("You canceled the car dialog.")
                        
                        OneSignal.promptForPushNotifications(userResponse: { accepted in
                            //print("User accepted notifications: \(accepted)")
                            UserDefaults.standard.set(true, forKey: "firstsendfriend")

                        })
                    }
                    
                    popup.addButtons([buttonTwo])
                    self.present(popup, animated: true, completion: nil)
                    
                }
            }
        }
        //self.friendTable.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        let pushToken = status.subscriptionStatus.pushToken
        let userId = status.subscriptionStatus.userId
        //print(pushToken)
        
        //if pushToken != nil {

        //}
        // 1
        
        var db = Firestore.firestore()
        
        guard let cell = tableView.cellForRow(at: indexPath) as? FriendTableViewCell else { return }
        
        let sfReference = db.collection("users").document(friendArr[indexPath.row].username)
        
        var restID = rest.id
        
        
        //adds a point to the friends restaurant point count
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
                //print("Transaction successfully committed!")
                
                let db = Firestore.firestore()
                
                // Create a reference to the cities collection
                let giftsRef = db.collection("gifts")
                let postsRef = db.collection("posts")

                // Add a new document with a generated id.
                giftsRef.document().setData([
                    "sender": self.username,
                    "receiver": self.friendArr[indexPath.row].username,
                    "restaurant": self.rest.title,
                    "time": FieldValue.serverTimestamp()
                    ])
            }
        }
        
        
        //adds a point to the the giftcount of the friend being sent the gift
        let friendRef = db.collection("users").document(friendArr[indexPath.row].username).collection("friends").document(self.username)

        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(friendRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            //print("\(restID).points")
            var oldFriendPoints = sfDocument.data()?["giftcount"] as? Int

            
            var pointsToAdd: Int = 0
            if(oldFriendPoints == 0){
                pointsToAdd = 1
            }else{
                pointsToAdd = Int(oldFriendPoints! + 1)
            }
            transaction.updateData([
                "giftcount": pointsToAdd
                
                ], forDocument: friendRef)
            return nil
        }) { (object, error) in
            if let error = error {
                //print("Transaction failed: \(error)")
            } else {
                //print("Transaction successfully committed!")
            }
        }
        
        
        //adds a point to the the giftcount of you
        let userRef = db.collection("users").document(self.username).collection("friends").document(friendArr[indexPath.row].username)
        
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(userRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            //print("\(restID).points")
            var oldFriendPoints = sfDocument.data()?["giftcount"] as? Int
            
            
            var pointsToAdd: Int = 0
            if(oldFriendPoints == 0){
                pointsToAdd = 1
            }else{
                pointsToAdd = Int(oldFriendPoints! + 1)
            }
            transaction.updateData([
                "giftcount": pointsToAdd
                
                ], forDocument: userRef)
            return nil
        }) { (object, error) in
            if let error = error {
                //print("Transaction failed: \(error)")
            } else {
                //print("Transaction successfully committed!")
            }
        }
        
        var temp: OurUser!
        sfReference.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                //print("Document data: \(dataDescription)")
                temp = OurUser(dictionary: document.data()!)
                
 
                let message = "\(self.username!) sent you a 🎁 from \(self.rest.title)"
                let notificationContent = [
                    "include_player_ids": [temp.pushToken],
                    "contents": ["en": message], // Required unless "content_available": true or "template_id" is set
                    "headings": ["en": "You got a free point!"],
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
    
    

    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

class FriendTableViewCell: UITableViewCell {
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendUsername: UILabel!
    
    func populate(friend: Friend) {
        //print("where my cells at \(item)")
        self.friendName.text = friend.name
        self.friendUsername.text = friend.username

        
    }
    

}
