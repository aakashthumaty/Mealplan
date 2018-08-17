//
//  SecondViewController.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 3/24/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit
import Firebase
import RSSelectionMenu
import MessageUI
import OneSignal
import PopupDialog
import FirebaseFirestore

class FriendViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, MFMessageComposeViewControllerDelegate{
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //print("hello text sent")
        self.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func share(_ sender: Any) {
    }
    
    @IBOutlet weak var collView: UICollectionView!
    
    @IBOutlet weak var inviteFriend: UIBarButtonItem!
    
    var username: String!
    var friendArr: [Friend] = []
    var friendNames: [String] = []

    var giftIDS: [String] = []
    var gifts: [Gift] = []
    
    func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        if(self.friendArr != nil){
            return self.friendArr.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "friendCollectionCell", for: indexPath) as! friendCollectionCell
        
        cell.imageView.image = UIImage(named: "heartBig")
        //cell.imageView.backgroundColor = .lightGray
        cell.populate(f: friendArr[indexPath.row])
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.gifts.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 60.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "fCell",
                                                 for: indexPath) as! FriendCell
        
        cell.populate(g: self.gifts[indexPath.row])
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
        self.title = "User: \(self.username!)"

        self.collView.delegate = self;
        self.collView.dataSource = self;
        
        self.friendTable.delegate = self;
        self.friendTable.dataSource = self;
        
        
        self.friendTable.tableFooterView = UIView(frame: CGRect.zero)
        
        let db = Firestore.firestore()
        
        db.collection("gifts").order(by: "time").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot?.documents else {
                //print("Error fetching documents: \(error!)")
                return
            }
            //                let cities = documents.map { $0["name"]! }
            //                print("Current cities in CA: \(cities)")
            for document in querySnapshot!.documents {
                //print("\(document.documentID) => \(document.data())")
                
                var pls = Gift(dictionary: document.data())
                if(!self.giftIDS.contains(document.documentID)){
                    if(pls != nil ){
                        self.gifts.insert(pls!, at: 0)
                        self.giftIDS.append(document.documentID)
                    }else{
                        //print("aiyah Database")
                    }
                }
                
                //print("got here")
            }
            self.friendTable.reloadData()
        }
        
        super.viewDidLoad()
        
        getThemFriends()
        
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                //print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    //print(" 1 \(document["name"])")
                    //if(document.data()){
                    
                    var pls = OurUser(dictionary: document.data())
                    if(pls != nil){
                        //self.friendArr.append(pls!)
                    
                        self.friendNames.append((pls?.username)!)
                    }else{
                        //print("aiyah Database")
                    }
                    
                }
                //print(self.friendArr.count)
                //self.collView.reloadData()
                
            }
        }
        
//        let db = Firestore.firestore()
//        print("this the email though \(self.username)")
//        db.collection("users/\(self.username!)/friends").getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//                    print("\(document.documentID) => \(document.data())")
//                    var pls = Friend(dictionary: document.data())
//                    if(pls! != nil){
//                        self.friendArr.append(pls!)
//                    }else{
//                        print("aiyah Database")
//                    }
//                }
//                self.collView.reloadData()
//            }
//        }
        // Do any additional setup after loading the view.
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    
    
    @IBAction func inviteFriend(_ sender: Any) {
        
        let title = "GET MORE FREE POINTS"
        let message = "The more friends you invite to download the app the more free points you can get!"
        
        let popup = PopupDialog(title: title, message: message)//, image: image)
        
        let buttonTwo = DefaultButton(title: "OK", dismissOnTap: true) {
            //print("You canceled the car dialog.")
            
//            OneSignal.promptForPushNotifications(userResponse: { accepted in
//                //print("User accepted notifications: \(accepted)")
//                UserDefaults.standard.set(true, forKey: "firstsendfriend")
//
//            })
            
            if (MFMessageComposeViewController.canSendText()) {
                let controller = MFMessageComposeViewController()
                controller.body = "Hey, download this app, so we can both get some free food https://itunes.apple.com/us/app/mealplan-lets-eat/id1376003167?ls=1&mt=8"
                //controller.recipients = [phoneNumber.text]
                controller.messageComposeDelegate = self
                self.present(controller, animated: true, completion: nil)
            }
        }
        
        popup.addButtons([buttonTwo])
        self.present(popup, animated: true, completion: nil)
        
        
    }
    
    func getThemFriends(){
        self.friendArr = []
        var db = Firestore.firestore()
        db.collection("users/\(self.username!)/friends").addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                //print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    //print(" 1 \(document["name"])")
                    //if(document.data()){
                    
                    var pls = Friend(dictionary: document.data())
                    
                    self.friendArr = self.friendArr.filter {$0.username != pls?.username}
                    self.friendArr.append(pls!)
//
//                    if(pls != nil ){
//                        self.friendArr.append(pls!)
//                        //                        self.friendNames.append((pls?.username)!)
//                    }else{
//                        print("aiyah Database")
//                    }
                    
                }
                //print(self.friendArr.count)
                DispatchQueue.main.async(execute: {() -> Void in
                    
                    self.collView?.reloadData();
                    //self.addFriendField.text = ""
                    
                    
                })
                
            }
        }
    }
    
    func updateTheColl(){
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func friendBeganAdding(_ sender: Any) {
        
        let db = Firestore.firestore()
        
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                //print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    //print(" 1 \(document["name"])")
                    //if(document.data()){
                    
                    var pls = OurUser(dictionary: document.data())
                    if(pls != nil){
                        //self.friendArr.append(pls!)
                        
                        self.friendNames.append((pls?.username)!)
                    }else{
                        //print("aiyah Database")
                    }
                    
                }
                //print(self.friendArr.count)
                //self.collView.reloadData()
                
                
                let selectionMenu =  RSSelectionMenu(dataSource: self.friendNames) { (cell, object, indexPath) in
                    cell.textLabel?.text = object
                    
                }
                selectionMenu.showSearchBar { (searchtext) -> ([String]) in
                    
                    // return filtered array based on any condition
                    // here let's return array where name starts with specified search text
                    
                    return self.friendNames.filter({ $0.lowercased().hasPrefix(searchtext.lowercased()) })
                }
                
                var simpleSelectedArray: [String] = []
                
                selectionMenu.setSelectedItems(items: simpleSelectedArray) { (text, isSelected, selectedItems) in
                    
                    // update your existing array with updated selected items, so when menu presents second time updated items will be default selected.
                    self.addFriendField.text = selectedItems.joined(separator: ", ")
                    //self.addFriendField = selectedItems
                    
                }
                
                // show as PresentationStyle = Push
                selectionMenu.show(style: .Present, from: self)
                
                //this is where i put the completion shit
                
                
            }
        }
        
        
    }
    
    
    @IBAction func addFriend(_ sender: Any) {
        
        self.addFriendField.resignFirstResponder()
        
        let trimmedString = self.addFriendField.text?.trimmingCharacters(in: .whitespaces)

        if(self.addFriendField.text == "" || trimmedString == ""){
            
            let alertController = UIAlertController(title: "Invalid Username", message: "Please choose a username without spaces. You're not a ghost.", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
            {
                (result : UIAlertAction) -> Void in
                //print("You pressed OK")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
            return;
            
        }

        let db = Firestore.firestore()

        var friendAdding = self.addFriendField.text
        let fReference = db.collection("users").document(friendAdding!)

        var temp: OurUser!
        fReference.getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                //print("Document data: \(dataDescription)")
                temp = OurUser(dictionary: document.data()!)
                
                
                let message = "\(self.username!) added you as a friend!"
                let notificationContent = [
                    "include_player_ids": [temp.pushToken],
                    "contents": ["en": message], // Required unless "content_available": true or "template_id" is set
                    "headings": ["en": "You have friends!"],
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
        
        let userReference = db.collection("users")
        let sfReference = db.collection("users").document(self.username).collection("friends")
        
        let friendReference = db.collection("users").document(friendAdding!)

        let meReference = db.collection("users").document(self.username)

        // Create a query against the collection.
        let query = userReference.whereField("username", isEqualTo: friendAdding).getDocuments(){ (querySnapshot, err) in
            if let err = err {
                //print("Error getting documents: \(err)")
            } else {
                //add user
                let numCheck = 1
                if((querySnapshot?.count)! >= numCheck){
                    // handle user and error as necessary
                    //print("You have friends.")
                
                    var tempFriend: OurUser!
                    
                    friendReference.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                            //print("Document data: \(dataDescription)")
                            tempFriend = OurUser(dictionary: document.data()!)
                            
                            
                            sfReference.document(friendAdding!).setData([
                                "username": friendAdding,//the text in the field,""
                                "giftcount": 0,
                                "name": tempFriend.name
                                ])
                            
//                            DispatchQueue.main.async(execute: {() -> Void in
//                                
//                                self.collView?.reloadData();
//                                
//                            })
                        } else {
                            //print("Document does not exist")
                        }
                    }
                    
 
                    //let meReference = db.collection("users").document(self.username)

                    var tempMe: OurUser!
                    
                    meReference.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                            //print("Document data: \(dataDescription)")
                            tempMe = OurUser(dictionary: document.data()!)
                            
                        userReference.document(friendAdding!).collection("friends").document(self.username).setData([
                                "username": self.username,//the text in the field,""
                                "giftcount": 0,
                                "name": tempMe.name
                                ])
                            
                            self.getThemFriends()
                            self.addFriendField.text = ""
                            
                        } else {
                            //print("Document does not exist")
                        }
                    }
                }else{
                    // username taken
                    //print("User Does Not Exist")
                    let alertController = UIAlertController(title: "User Does Not Exist", message: "Imagination is a breautiful thing. Sorry, that username doesn't belong to any user. Did you mispell it?", preferredStyle: UIAlertControllerStyle.alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                    {
                        (result : UIAlertAction) -> Void in
                        //print("You pressed OK")
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

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var friendName: UILabel!
    
    @IBOutlet weak var locName: UILabel!
    
    @IBOutlet weak var white: UIView!

    
    func populate(g: Gift) {

        self.friendName.text = g.receiver
        self.userName.text = g.sender
        self.locName.text = "@ \(g.restaurant)"
        
        white.clipsToBounds = true
        white.layer.cornerRadius = 6
    
    }


}



class friendCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var giftCount: UILabel!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    

//
//    override var bounds: CGRect {
//        didSet {
//            self.layoutIfNeeded()
//        }
//    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
     //   self.imageView.layer.masksToBounds = true
    }
    
    func populate(f: Friend) {
        self.friendName.text = f.username
        self.giftCount.text = "\(f.giftcount)"
        
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        self.setCircularImageView()
//    }
//
//    func setCircularImageView() {
//        self.imageView.layer.cornerRadius = CGFloat(roundf(Float(self.imageView.frame.size.width / 2.0)))
//    }
}
