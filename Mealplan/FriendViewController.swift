//
//  SecondViewController.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 3/24/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit
import Firebase

class FriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    var username: String!
    var friendArr: Array<Dictionary<String,Any>> = [[:]]
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fCell",
                                                 for: indexPath) as! FriendCell
        
        cell.populate(friend: friendArr[indexPath.row])
        return cell
    }
    

    @IBOutlet weak var friendTable: UITableView!
    
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var addFriendField:
    
    UITextField!
    override func viewDidLoad() {
        let defaults = UserDefaults.standard
        self.username = defaults.string(forKey: "username")

        super.viewDidLoad()
        
        let db = Firestore.firestore()
        print("this the email though \(self.username)")
        db.collection("users/\(self.username!)/friends").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    self.friendArr.append(document.data())
                    
                    
                }
            }
        }
        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addFriend(_ sender: Any) {
        let db = Firestore.firestore()
        
        let userReference = db.collection("users")
        let sfReference = db.collection("users").document(self.username).collection("friends")
        // Create a query against the collection.
        let query = userReference.whereField("username", isEqualTo: self.addFriendField.text).getDocuments(){ (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                //add user
                let numCheck = 1
                if((querySnapshot?.count)! >= numCheck){
                    // handle user and error as necessary
                    print("You have friends.")
                
                    
                        sfReference.document(self.addFriendField.text!).setData([
                        "username": self.addFriendField.text,//the text in the field,""
                        "giftcount": 0
                        ])
                    
                        userReference.document(self.addFriendField.text!).collection("friends").document(self.username).setData([
                        "username": self.username,//the text in the field,""
                        "giftcount": 0
                        ])

//
//                    UIView.animate(withDuration: 0.5, delay: 0,
//                                   options: [.curveEaseInOut],
//                                   animations: {
//                                    self.oView.alpha = 0
//                                    self.signupView.alpha = 0
//                                    self.doneSignup.alpha = 0
//
//                    },
//                                   completion: {finished in self.disappear()}
//                    )
                    
                }else{
                    // username taken
                    print("User Does Not Exist")
                    let alertController = UIAlertController(title: "User Does Not Exist", message: "Imagination is a breautiful thing. Sorry, that username doesn't belong to any user. Did you mispell it?", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                    {
                        (result : UIAlertAction) -> Void in
                        print("You pressed OK")
                    }
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
            }
        

        
//        db.runTransaction({ (transaction, errorPointer) -> Any? in
//            let sfDocument: DocumentSnapshot
//            do {
//                try sfDocument = transaction.getDocument(sfReference)
//            } catch let fetchError as NSError {
//                errorPointer?.pointee = fetchError
//                return nil
//            }
        
        
        
        
//            print("\friends")
//            var oldRestPoints = sfDocument.data()?["\friends"] as? Dictionary<String,Int>
            
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
            
//            var pointsToAdd: Int = 0
//            if(oldRestPoints == nil){
//                pointsToAdd = 1
//            }else{
//                pointsToAdd = oldRestPoints!["points"]!+1
//            }
        
        
        
        
//            transaction.updateData([
//                "\friends": pointsToAdd,
//                "touched": oldTouched
//
//                ], forDocument: sfReference)
//            return nil
//        }) { (object, error) in
//            if let error = error {
//                print("Transaction failed: \(error)")
//            } else {
//                print("Transaction successfully committed!")
//            }
//        }
//    }
    
            }
        }
    }



class FriendCell: UITableViewCell {

    @IBOutlet weak var friendUsername: UILabel!
    @IBOutlet weak var friendName: UILabel!
    func populate(friend: Dictionary<String,Any>) {
        //print("where my cells at \(item)")
        self.friendName.text = friend["name"] as! String
        self.friendUsername.text = friend["username"] as! String
        //item.options[]
    
    
    }


}
