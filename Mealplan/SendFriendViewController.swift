//
//  SendFriendViewController.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 4/7/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit
import Firebase

class SendFriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
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
        print(self.friendArr)
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

    override func viewDidLoad() {
        super.viewDidLoad()
        self.friendTable.delegate = self;
        self.friendTable.dataSource = self;
        
        let db = Firestore.firestore()
        print("this the email though \(self.userEmail)")
        db.collection("users/\(self.username!)/friends").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    print(" 1 \(document["name"])")
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
                        print("aiyah Database")
                    }

                    //}
                    
                    
                }
                print(self.friendArr.count)
                self.friendTable.reloadData()

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
            
            print("\(restID).points")
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
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
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
            
            print("\(restID).points")
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

class FriendTableViewCell: UITableViewCell {
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var friendUsername: UILabel!
    
    func populate(friend: Friend) {
        //print("where my cells at \(item)")
        self.friendName.text = friend.name
        self.friendUsername.text = friend.username

        
    }
    

}
