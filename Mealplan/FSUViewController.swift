//
//  FSUViewController.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 8/15/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import RSSelectionMenu
import OneSignal
import MessageUI

class FSUViewController: UIViewController, MFMessageComposeViewControllerDelegate {
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)

    }
    

    var username: String!
    var friendArr: [Friend] = []
    //var friendArr: [Friend] = []
    var friendNames: [String] = []
    var activityNames: [String] = []
    var locationNames: [String] = []

    var selFriends: [String] = []
    
    @IBOutlet weak var letsGoButton: UIView!
    
    @IBOutlet weak var activityField: UITextField!
    @IBOutlet weak var friendField: UITextField!
    @IBOutlet weak var locationField: UITextField!
    
    enum LINE_POSITION {
        case LINE_POSITION_TOP
        case LINE_POSITION_BOTTOM
    }
    
    func addLineToView(view : UIView, position : LINE_POSITION, color: UIColor, width: Double) {
        let lineView = UIView()
        lineView.backgroundColor = color
        lineView.translatesAutoresizingMaskIntoConstraints = false // This is important!
        view.addSubview(lineView)
        
        let metrics = ["width" : NSNumber(value: width)]
        let views = ["lineView" : lineView]
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[lineView]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:metrics, views:views))
        
        switch position {
        case .LINE_POSITION_TOP:
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[lineView(width)]", options:NSLayoutFormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        case .LINE_POSITION_BOTTOM:
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[lineView(width)]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:metrics, views:views))
            break
        default:
            break
        }
    }
    
    @IBAction func textUs(_ sender: Any) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = ""
            controller.recipients = ["9195900536"]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func inviteAFriend(_ sender: Any) {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = ""
//            controller.recipients = ["4086216172", "9195900536"]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let betterTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        self.letsGoButton.addGestureRecognizer(betterTap)
        
        self.addLineToView(view: activityField, position:.LINE_POSITION_BOTTOM, color: UIColor.white, width: 0.5)
        self.addLineToView(view: friendField, position:.LINE_POSITION_BOTTOM, color: UIColor.white, width: 0.5)
        self.addLineToView(view: locationField, position:.LINE_POSITION_BOTTOM, color: UIColor.white, width: 0.5)

        
        let defaults = UserDefaults.standard
        self.username = defaults.string(forKey: "username")
            
        self.modalPresentationCapturesStatusBarAppearance = true

        getThemFriends()
        // Do any additional setup after loading the view.
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        
        var db = Firestore.firestore()

            
            print("lets go tapped")
        if(self.activityField.text != "" && self.friendField.text != "" && self.locationField.text != ""){
            
            for friend in self.selFriends{
            
                let recipientRef = db.collection("users").document(friend)
                var temp: OurUser!
                
                var dataDesc: String = ""
                var mes: String = ""
                var tit: String = ""

                
                recipientRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        //print("Document data: \(dataDescription)")
                        temp = OurUser(dictionary: document.data()!)
                        
                        
                        let message = "\(self.username!) wants you to come \(self.activityField.text!) at \(self.locationField.text!)"
                        let notificationContent = [
                            "include_player_ids": [temp.pushToken],
                            "contents": ["en": message], // Required unless "content_available": true or "template_id" is set
                            "headings": ["en": "You Bored?"],
                            
                            "ios_badgeType": "Increase",
                            "ios_badgeCount": 1
                            ] as [String : Any]
                        
                        mes = message
                        OneSignal.postNotification(notificationContent)
                        
                        db.collection("users").document(temp.username).collection("notifications").document().setData([
                            "type": "fsuInvite",
                            "body": mes,
                            "title": "You Bored?",
                            "time": FieldValue.serverTimestamp()
                            ])

                        
                    } else {
                        //print("Document does not exist")
                    }
                }
            }
//            db.collection("users").document(self.username!).collection("notifications").document().setData([
//                "type": "fsuInvite",
//                "body": message,
//                "title": "You Bored?",
//                "time": FieldValue.serverTimestamp()
//                ])
            self.selFriends = []
            self.navigationController?.popViewController(animated: true)
            self.dismiss(animated: true) {
                return true
            }
            // send the notif and add to firebase
        }else{
            let alertController = UIAlertController(title: "Darn", message: "Please choose an activity, friend, and location!", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
            {
                (result : UIAlertAction) -> Void in
                //print("You pressed OK")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func aFieldTapped(_ sender: Any) {
        let selectionMenu =  RSSelectionMenu(dataSource: self.activityNames) { (cell, object, indexPath) in
            cell.textLabel?.text = object
            
        }

        
        var simpleSelectedArray: [String] = []
        
        selectionMenu.setSelectedItems(items: simpleSelectedArray) { (text, isSelected, selectedItems) in
            
            // update your existing array with updated selected items, so when menu presents second time updated items will be default selected.
            self.activityField.text = selectedItems.joined(separator: ", ")
            //self.addFriendField = selectedItems
        }
        
        selectionMenu.show(style: .Present, from: self)

    }
    
    @IBAction func fFieldTapped(_ sender: Any) {
        let selectionMenu =  RSSelectionMenu(selectionType: .Multiple,dataSource: self.friendNames) { (cell, object, indexPath) in
            cell.textLabel?.text = object
            
        }
                selectionMenu.showSearchBar{ (searchText) -> ([String]) in
        
   
                        return self.friendNames.filter({ $0.lowercased().hasPrefix(searchText.lowercased()) })
  
                }
        
        var simpleSelectedArray: [String] = []
        
        selectionMenu.setSelectedItems(items: simpleSelectedArray) { (text, isSelected, selectedItems) in
            
            self.selFriends = selectedItems
            // update your existing array with updated selected items, so when menu presents second time updated items will be default selected.
            self.friendField.text = selectedItems.joined(separator: ", ")
            //self.addFriendField = selectedItems
        }
        
        selectionMenu.show(style: .Present, from: self)

    }
    
    @IBAction func pFieldTapped(_ sender: Any) {
        
        let selectionMenu =  RSSelectionMenu(dataSource: self.locationNames) { (cell, object, indexPath) in
            cell.textLabel?.text = object
            
        }
        
        
        var simpleSelectedArray: [String] = []
        
        selectionMenu.setSelectedItems(items: simpleSelectedArray) { (text, isSelected, selectedItems) in
            
            // update your existing array with updated selected items, so when menu presents second time updated items will be default selected.
            self.locationField.text = selectedItems.joined(separator: ", ")
            //self.addFriendField = selectedItems
        }
        
        selectionMenu.show(style: .Present, from: self)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    override var prefersStatusBarHidden: Bool{
        return true
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
                    self.friendNames.append((pls?.username)!)

                    
                }
                //print(self.friendArr.count)
                
                DispatchQueue.main.async(execute: {() -> Void in
                    //do i need deispatch queue for anything?
                })
                
            }
        }
        
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
                        //self.friendNames = self.friendNames.filter {$0 != pls?.username}

                        self.friendNames.append((pls?.username)!)
                    }else{
                        //print("aiyah Database")
                    }
                    
                }
            }
        }
        
        //load the activity names and lcoation names
        db.collection("data").addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                //print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    //print(" 1 \(document["name"])")
                    //if(document.data()){
                    if(document.documentID == "fsuActivities"){
                        
                        var pls = fsuObject(dictionary: document.data())
                        self.activityNames = (pls?.titles)!
                    }
                    
                    if(document.documentID == "fsuLocations"){
                        
                        var pls = fsuObject(dictionary: document.data())
                        self.locationNames = (pls?.titles)!
                    }
                    
                    
                }
                //print(self.friendArr.count)
                DispatchQueue.main.async(execute: {() -> Void in
                    
                    //self.collView?.reloadData();
                    //self.addFriendField.text = ""
                    
                    
                })
                
            }
        }
    }
}


