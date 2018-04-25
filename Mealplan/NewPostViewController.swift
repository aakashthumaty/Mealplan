//
//  NewPostViewController.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 4/10/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit
import Firebase
import RSSelectionMenu


class NewPostViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var greatFood: UIImageView!
    @IBOutlet weak var aightFood: UIImageView!
    @IBOutlet weak var badFood: UIImageView!
    
    @IBOutlet weak var captionField: UITextField!
    @IBOutlet weak var postImage: UIImageView!
    
    @IBOutlet weak var restField: UITextField!
    @IBOutlet weak var friendsField: UITextField!
    
    
    var friendSelected: [String] = []
    var restaurantSelected: String  = ""
    var caption: String  = ""
    var rating: String = ""
    var imageURL: String = ""
    
    var restaurants: [Restaurant] = []
    var restaurantNames: [String] = []
    var username: String = ""
    var friendArr: [Friend] = []
    var friendNames: [String] = []
    var img: UIImage!
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        let defaults = UserDefaults.standard
        self.username = defaults.string(forKey: "username")!

        self.postImage.image = self.img
        let db = Firestore.firestore()

        
        db.collection("restaurants").getDocuments() { (querySnapshot, err) in
            if let err = err {
                //print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    ////print("\(document.documentID) => \(document.data())")
                    
                    var pls = Restaurant(dictionary: document.data())
                    if(pls != nil){
                        self.restaurants.append(pls!)
                        self.restaurantNames.append((pls?.title)!)
                    }else{
                        //print("aiyah Database")
                    }

                    //print("got here")
                }
                //self.restTable.reloadData()
                
            }
        }
        
        //print("this the email though \(self.username)")
        db.collection("users/\(self.username)/friends").getDocuments() { (querySnapshot, err) in
            if let err = err {
                //print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    //print(" 1 \(document["name"])")
                    
                    var pls = Friend(dictionary: document.data())

                    if(pls != nil){
                        self.friendArr.append(pls!)
                        self.friendNames.append((pls?.name)!)
                    }else{
                        //print("aiyah Database")
                    }
                }
                //print(self.friendArr.count)
                
            }
        }
        
        
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(NewPostViewController.imageTapped(gesture:)))
        
        let tapGestureGreat = UITapGestureRecognizer(target: self, action: #selector(NewPostViewController.imageTappedGreat(gesture:)))
        
        let tapGestureBad = UITapGestureRecognizer(target: self, action: #selector(NewPostViewController.imageTappedBad(gesture:)))
        // add it to the image view;
        greatFood.addGestureRecognizer(tapGestureGreat)
        greatFood.isUserInteractionEnabled = true
        badFood.addGestureRecognizer(tapGestureBad)
        badFood.isUserInteractionEnabled = true
        aightFood.addGestureRecognizer(tapGesture)
        aightFood.isUserInteractionEnabled = true
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func postTapped(_ sender: Any) {
        
        
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    
    
    @IBAction func poop(_ sender: Any) {
        
        let selectionMenu =  RSSelectionMenu(dataSource: self.restaurantNames) { (cell, object, indexPath) in
            cell.textLabel?.text = object
            
            // Change tint color (if needed)
            //cell.tintColor = .orange
        }
        
        // set default selected items when menu present on screen.
        // Here you'll get onDidSelectRow
        var simpleSelectedArray: [String] = []
        
        selectionMenu.setSelectedItems(items: simpleSelectedArray) { (text, isSelected, selectedItems) in
            
            // update your existing array with updated selected items, so when menu presents second time updated items will be default selected.
            self.restaurantSelected = selectedItems[0]
            self.restField.text = selectedItems[0]
            
        }
        
        // show as PresentationStyle = Push
        selectionMenu.show(style: .Present, from: self)
    }
    
    
    @IBAction func friendsFieldTapped(_ sender: Any) {
        let selectionMenu =  RSSelectionMenu(dataSource: self.friendNames) { (cell, object, indexPath) in
            cell.textLabel?.text = object

        }

        var simpleSelectedArray: [String] = []
        
        selectionMenu.setSelectedItems(items: simpleSelectedArray) { (text, isSelected, selectedItems) in
            
            // update your existing array with updated selected items, so when menu presents second time updated items will be default selected.
            self.friendsField.text = selectedItems.joined(separator: ", ")
            self.friendSelected = selectedItems

        }
        
        // show as PresentationStyle = Push
        selectionMenu.show(style: .Present, from: self)
        
        
    }

    @IBAction func doneTapped(_ sender: Any) {
        self.caption = captionField.text!
    }
    @objc func imageTapped(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview

                //print("aight")
                self.rating = "aight"
                self.aightFood.image = UIImage(named:"selectedBoxRed.png")
                self.greatFood.image = UIImage(named:"heartBig.png")
                self.badFood.image = UIImage(named:"sadBig.png")

    }
    
    @objc func imageTappedGreat(gesture: UIGestureRecognizer) {
        // if the tapped view is a UIImageView then set it to imageview
                //print("great")
                self.rating = "great"
                self.greatFood.image = UIImage(named:"selectedBoxRed.png")
                self.aightFood.image = UIImage(named:"ehBig.png")
                self.badFood.image = UIImage(named:"sadBig.png")
    }
    
    @objc func imageTappedBad(gesture: UIGestureRecognizer) {

                //print("bad")
                self.rating = "bad"
                self.badFood.image = UIImage(named:"selectedBoxRed.png")
                self.aightFood.image = UIImage(named:"ehBig.png")
                self.greatFood.image = UIImage(named:"heartBig.png")

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
