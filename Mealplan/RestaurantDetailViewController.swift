//
//  RestaurantDetailViewController.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 3/26/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import PopupDialog


class RestaurantDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var discountsCollectionView: UICollectionView!
    var oldTouched: [String]?

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(discs != nil){
            if(discs.count > 3){
                return discs.count - 2
            }else{
                return 1
                }
        }else{
            return 1
        }
        //return discs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell: discountCollectionViewCell
        var rcell: rewardsCollectionViewCell

        
        
        if(indexPath.row == 0){
                rcell = collectionView.dequeueReusableCell(withReuseIdentifier: "rewardsCollectionCell", for: indexPath) as! rewardsCollectionViewCell
            
            var points: [Discount] = []
            for d in self.discs{
                if(d.cat == "points"){
                    points.append(d)
                }

            }
            points.sorted(by: { $0.count > $1.count })

            if(!(points == nil) && points.count > 0){
                rcell.disc0 = points[0]
                rcell.disc1 = points[1]
                rcell.disc2 = points[2]
            }
            if(self.userPoints != nil){
                rcell.displayContent(uP: self.userPoints)
            }else{
                rcell.displayContent(uP: 0)
            }

            
            return rcell

        }else {
                cell = collectionView.dequeueReusableCell(withReuseIdentifier: "discCollectionCell", for: indexPath) as! discountCollectionViewCell
            
            var nahPoints: [Discount] = []
            for d in self.discs{
                if(d.cat != "points"){
                    nahPoints.append(d)
                }
                
            }
            
            cell.disc = nahPoints[indexPath.row-1]
            cell.displayContent()

            return cell

        }
        //cell.displayContent(img: rest.images[indexPath.row] as! String)
        
    }
    
    func runTransaction(howMany: Int){
        let db = Firestore.firestore()
        
        let sfReference = db.collection("users").document(self.username)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            //print("\(self.restaurant.id).points")
            var oldRestPoints = sfDocument.data()?["\(self.restaurant.id)"] as? Dictionary<String,Int>

            
            var pointsToAdd: Int = 0

            pointsToAdd = oldRestPoints!["points"]! - howMany
            
            transaction.updateData([
                "\(self.restaurant.id).points": pointsToAdd
                
                ], forDocument: sfReference)
            return nil
        }) { (object, error) in
            if let error = error {
                //print("Transaction failed: \(error)")
            } else {
                //print("Transaction successfully committed!")
            }
        }
        
    }
    
    func presentSadPop(){
        let title = "NOT ENOUGH POINTS"
        let message = "Sorry bud, you don't have enough points just yet."
        
        let popup = PopupDialog(title: title, message: message)//, image: image)
        
        let buttonOne = CancelButton(title: "OK") {
            //print("You canceled the car dialog.")
        }
        
        popup.addButtons([buttonOne])
        self.present(popup, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if(indexPath.row > 0){
            
            let cell = collectionView.cellForItem(at: indexPath) as! discountCollectionViewCell
            if(cell.disc.cat == "firsttime"){
            
                if (oldTouched != nil && !((oldTouched?.contains(self.restaurant.id))!)){
                    //print(!((oldTouched?.contains(self.restaurant.id))!))
                    let title = "ACTIVATE DISCOUNT"
                    let message = "Are you sure you're ready to activate this discount?"
                    
                    let popup = PopupDialog(title: title, message: message)//, image: image)
                    
                    let buttonOne = CancelButton(title: "CANCEL") {
                        //print("You canceled the car dialog.")
                    }
                    
                    let buttonTwo = DefaultButton(title: "Activate", dismissOnTap: true) {
                        //print("What a beauty!")
                        
                        self.discMode = true
                        self.disc = cell.disc
                        
                        self.discModeSections = self.restaurant.categories
                        self.discModeSectionCount = self.restaurant.categories.count
                        
                        self.discountsCollectionView.cellForItem(at: indexPath)?.contentView.layer.borderColor = UIColor.green.cgColor
                        self.discountsCollectionView.cellForItem(at: indexPath)?.contentView.layer.borderWidth = 5
                        
                        self.discountsCollectionView.isUserInteractionEnabled = false
                        
                    
                    }
                    
                    popup.addButtons([buttonOne, buttonTwo])
                    self.present(popup, animated: true, completion: nil)
                }else{
                    
                    let title = "YOU'VE ALREADY EATEN HERE"
                    let message = "Sorry bud, this discount only works the first time you eat somewhere :("
                    
                    let popup = PopupDialog(title: title, message: message)//, image: image)
                    
                    let buttonOne = CancelButton(title: "OK") {
                        //print("You canceled the car dialog.")
                    }
                    
                    popup.addButtons([buttonOne])
                    self.present(popup, animated: true, completion: nil)
                    
                }
            }else if(cell.disc.cat == "constant"){
                
                let title = "ACTIVATE DISCOUNT"
                let message = "Are you sure you're ready to activate this discount?"
                
                let popup = PopupDialog(title: title, message: message)//, image: image)
                
                let buttonOne = CancelButton(title: "CANCEL") {
                    //print("You canceled the car dialog.")
                }
                
                let buttonTwo = DefaultButton(title: "Activate", dismissOnTap: true) {
                    //print("What a beauty!")
                    
                    self.discMode = true
                    self.disc = cell.disc
                    
                    self.discModeSections = self.restaurant.categories
                    self.discModeSectionCount = self.restaurant.categories.count
                    
                    self.discountsCollectionView.cellForItem(at: indexPath)?.contentView.layer.borderColor = UIColor.green.cgColor
                    self.discountsCollectionView.cellForItem(at: indexPath)?.contentView.layer.borderWidth = 5
                    
                    self.discountsCollectionView.isUserInteractionEnabled = false
                    
                    
                }
                
                popup.addButtons([buttonOne, buttonTwo])
                self.present(popup, animated: true, completion: nil)
            }
            
        }
//
        if(indexPath.row == 0){
            
            let cell = collectionView.cellForItem(at: indexPath) as! rewardsCollectionViewCell
            
            let title = "REDEEM A REWARD"
            let message = "Choose the reward you'd like to spend your points on!"
            
            let popup = PopupDialog(title: title, message: message)//, image: image)
            
            // Create buttons
            let buttonOne = CancelButton(title: "CANCEL") {
                //print("You canceled the car dialog.")
            }
            // This button will not the dismiss the dialog
            let buttonTwo = DefaultButton(title: cell.disc0.shortDescription, dismissOnTap: true) {
                //print("What a beauty!")
                
                if(Int(cell.disc0.count) <= self.userPoints){
                self.userPoints = self.userPoints - Int(cell.disc0.count)
                    self.runTransaction(howMany: Int(cell.disc0.count))
                    
                if(cell.disc0.type == "category"){

    //if the discount is a category based discount do all of this //we also reload the entire tableview based on a new list of categories
                    self.discMode = true
                    self.disc = cell.disc0
                    var arrayofDiscItems = cell.disc0.item.components(separatedBy: ",")
                    self.discModeSections = arrayofDiscItems
                    self.discModeSectionCount = arrayofDiscItems.count
                    
                    var iSet: [Int] = []
                    self.itemTableView.beginUpdates()

                    for thing in 0...self.restaurant.categories.count-1{
                        
                        if(!(arrayofDiscItems.contains(self.restaurant.categories[thing]))){
                            iSet.insert(thing, at: 0)
                            //self.itemTableView.deleteSections(NSIndexSet(index: thing) as IndexSet, with: .automatic)
                        }

                    }
                    //itemTableView.sectionforsectionindexT
                    let s: IndexSet = IndexSet(iSet)
                    self.itemTableView.deleteSections(s, with: .automatic)
                    
                    
                    self.itemTableView.endUpdates()
                    //self.itemTableView.reloadData()
                    
                    popup.dismiss(animated: true, completion: nil)
                    let ip = IndexPath(item: 0, section: 0)

                    self.discountsCollectionView.cellForItem(at: ip)?.contentView.layer.borderColor = UIColor.green.cgColor
                    self.discountsCollectionView.cellForItem(at: ip)?.contentView.layer.borderWidth = 5
                    self.discountsCollectionView.isUserInteractionEnabled = false

                }else if(cell.disc0.type == "item"){
                    
                    var finalip = IndexPath(item: 0, section: 0)
                    for thing in 0...self.restaurant.categories.count-1 {
                        
                        var plskey = self.restaurant.categories[thing]
                        //print(plskey)
                        var iter = (self.catDict[plskey]?.count)! - 1
                        
                        for thing2 in 0...iter{
                            let ip = IndexPath(item: thing2, section: thing)
                            //let tcell: ItemTableViewCell = self.itemTableView.cellForRow(at: ip) as! ItemTableViewCell
                            let titem: MenuItem = self.catDict[plskey]![thing2]
                            //print("looking through this \(titem.name)")
                            //print("looking for this \(cell.disc0.item)")
                            if(titem.name == cell.disc0.item ){
                                finalip = ip
                            }
                        }
                    }
                    
                    self.itemTableView.selectRow(at: finalip, animated: true, scrollPosition: UITableViewScrollPosition.middle)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // change 2 to desired number of seconds
                        self.performSegue(withIdentifier: "addonSegue", sender: self.itemTableView.cellForRow(at: finalip))
                    }
                    
                }
                }else{
                    
                    
                    self.presentSadPop()
                    // present popup saying you dont have enough points
                }

            }
            let buttonThree = DefaultButton(title: cell.disc1.shortDescription, height: 60) {
                //print("Ah, maybe next time :)")
                
                if(Int(cell.disc1.count) <= self.userPoints){
                    self.userPoints = self.userPoints - Int(cell.disc1.count)
                    self.runTransaction(howMany: Int(cell.disc1.count))
                    
                if(cell.disc1.type == "category"){
                    
                    //if the discount is a category based discount do all of this //we also reload the entire tableview based on a new list of categories
                    self.discMode = true
                    self.disc = cell.disc1
                    var arrayofDiscItems = cell.disc1.item.components(separatedBy: ",")
                    self.discModeSections = arrayofDiscItems
                    self.discModeSectionCount = arrayofDiscItems.count
                    
                    var iSet: [Int] = []
                    self.itemTableView.beginUpdates()
                    
                    for thing in 0...self.restaurant.categories.count-1{
                        
                        if(!(arrayofDiscItems.contains(self.restaurant.categories[thing]))){
                            iSet.insert(thing, at: 0)
                            //self.itemTableView.deleteSections(NSIndexSet(index: thing) as IndexSet, with: .automatic)
                        }
                        
                    }
                    //itemTableView.sectionforsectionindexT
                    let s: IndexSet = IndexSet(iSet)
                    self.itemTableView.deleteSections(s, with: .automatic)
                    
                    
                    self.itemTableView.endUpdates()
                    self.itemTableView.reloadData()

                    popup.dismiss(animated: true, completion: nil)
                    let ip = IndexPath(item: 0, section: 0)
                    
                    self.discountsCollectionView.cellForItem(at: ip)?.contentView.layer.borderColor = UIColor.green.cgColor
                    self.discountsCollectionView.cellForItem(at: ip)?.contentView.layer.borderWidth = 5
                    self.discountsCollectionView.isUserInteractionEnabled = false

                }else if(cell.disc1.type == "item"){

                    var finalip = IndexPath(item: 0, section: 0)
                    for thing in 0...self.restaurant.categories.count-1 {
                        
                        var plskey = self.restaurant.categories[thing]
                        //print(plskey)
                        var iter = (self.catDict[plskey]?.count)! - 1
                        
                        for thing2 in 0...iter{
                            let ip = IndexPath(item: thing2, section: thing)
                            //let tcell: ItemTableViewCell = self.itemTableView.cellForRow(at: ip) as! ItemTableViewCell
                            let titem: MenuItem = self.catDict[plskey]![thing2]
                            //print("looking through this \(titem.name)")
                            //print("looking for this \(cell.disc1.item)")
                            if(titem.name == cell.disc1.item ){
                                finalip = ip
                            }
                        }
                    }

                    self.itemTableView.selectRow(at: finalip, animated: true, scrollPosition: UITableViewScrollPosition.middle)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // change 2 to desired number of seconds
                        self.performSegue(withIdentifier: "addonSegue", sender: self.itemTableView.cellForRow(at: finalip))
                    }
                }
                }else{
                    
                    self.presentSadPop()
                    
                    
                    //present popup saying you dont have enough points
                }
                

            }
            let buttonFour = DefaultButton(title: cell.disc2.shortDescription, height: 60) {
                //print("Ah, maybe next time :)")
                if(Int(cell.disc2.count) <= self.userPoints){
                    self.userPoints = self.userPoints - Int(cell.disc2.count)
                    self.runTransaction(howMany: Int(cell.disc2.count))
                
                if(cell.disc2.type == "category"){
                    
                    //if the discount is a category based discount do all of this //we also reload the entire tableview based on a new list of categories
                    self.discMode = true
                    self.disc = cell.disc2
                    var arrayofDiscItems = cell.disc2.item.components(separatedBy: ",")
                    self.discModeSections = arrayofDiscItems
                    self.discModeSectionCount = arrayofDiscItems.count
                    
                    var iSet: [Int] = []
                    self.itemTableView.beginUpdates()
                    
                    for thing in 0...self.restaurant.categories.count-1{
                        
                        if(!(arrayofDiscItems.contains(self.restaurant.categories[thing]))){
                            iSet.insert(thing, at: 0)
                            //self.itemTableView.deleteSections(NSIndexSet(index: thing) as IndexSet, with: .automatic)
                        }
                        
                    }
                    //itemTableView.sectionforsectionindexT
                    let s: IndexSet = IndexSet(iSet)
                    self.itemTableView.deleteSections(s, with: .automatic)
                    
                    
                    self.itemTableView.endUpdates()
                    self.itemTableView.reloadData()

                    popup.dismiss(animated: true, completion: nil)
                    let ip = IndexPath(item: 0, section: 0)
                    
                    self.discountsCollectionView.cellForItem(at: ip)?.contentView.layer.borderColor = UIColor.green.cgColor
                    self.discountsCollectionView.cellForItem(at: ip)?.contentView.layer.borderWidth = 5
                    self.discountsCollectionView.isUserInteractionEnabled = false

                }else if(cell.disc2.type == "item"){
                    
                    var finalip = IndexPath(item: 0, section: 0)
                    for thing in 0...self.restaurant.categories.count-1 {
                        
                        var plskey = self.restaurant.categories[thing]
                        //print(plskey)
                        var iter = (self.catDict[plskey]?.count)! - 1
                        
                        for thing2 in 0...iter{
                            let ip = IndexPath(item: thing2, section: thing)
                            //let tcell: ItemTableViewCell = self.itemTableView.cellForRow(at: ip) as! ItemTableViewCell
                            let titem: MenuItem = self.catDict[plskey]![thing2]
                            //print("looking through this \(titem.name)")
                            //print("looking for this \(cell.disc2.item)")
                            if(titem.name == cell.disc2.item ){
                                finalip = ip
                            }
                        }
                    }
                    
                    self.itemTableView.selectRow(at: finalip, animated: true, scrollPosition: UITableViewScrollPosition.middle)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // change 2 to desired number of seconds
                        self.performSegue(withIdentifier: "addonSegue", sender: self.itemTableView.cellForRow(at: finalip))
                    }
                }
                }else{
                    //present popup saying you dont have enough points
                    
                    self.presentSadPop()
                    
                }

            }
            
            popup.addButtons([buttonOne, buttonTwo, buttonThree, buttonFour])
            self.present(popup, animated: true, completion: nil)
            
        }
        
    }
    
    
    var userEmail: String!
    var username: String!
    var presFriend: Bool = false
    
    var userPoints: Int = 0
    
    var disc: Discount!
    var discMode: Bool = false;
    var discModeSectionCount: Int = 0;
    var discModeSections: [String] = []
    
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var restaurantDescription: UITextView!
    @IBOutlet weak var ratingImage: UIImageView!
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var footerView: UIView!
    
    @IBOutlet weak var proceedToCheckout: UIButton!
    
    var items: [MenuItem] = []
    var discs: [Discount] = []

    var restaurant: Restaurant!
    var catDict: Dictionary<String, [MenuItem]> = [:]

    var order: Array<OrderItem> = []

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //self.disc = nil
        //self.discMode = false
        
        
        let header = self.headerView
        itemTableView.tableHeaderView = header
        itemTableView.tableFooterView = footerView
        
        self.restaurantName.text = ""
        self.restaurantDescription.text = ""
        
        
        self.restaurantName.text = self.restaurant.title
        self.restaurantDescription.text = self.restaurant.description
        let defaults = UserDefaults.standard
        let uName = defaults.string(forKey: "username")
        if(uName == nil){
            self.discountsCollectionView.isUserInteractionEnabled = false
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        discountsCollectionView.delegate = self
        discountsCollectionView.dataSource = self
        
        if presFriend {

            let sendFriend : SendFriendViewController = self.storyboard?.instantiateViewController(withIdentifier: "sfvc") as! SendFriendViewController
                sendFriend.navigationController?.setNavigationBarHidden(true, animated: false)
            sendFriend.rest = self.restaurant
            sendFriend.userEmail = self.userEmail
            sendFriend.username = self.username
            
    
            self.present(sendFriend, animated: true, completion: nil)
            presFriend = false;
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let sv = UIViewController.displaySpinner(onView: self.view)

        self.proceedToCheckout.isHidden = true;
        self.order = [];
        
//        itemTableView.estimatedRowHeight = 40
//        itemTableView.rowHeight = UITableViewAutomaticDimension
        
        //label.text = restaurant.title
        //print("hi rest dict\(restaurant.dictionary)")
        
        ///restaurants/tmt0000002/menu
        let db = Firestore.firestore()
        
        if(self.username != ""){
            
        
        let meReference = db.collection("users").document(self.username)
        
        meReference.addSnapshotListener { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                //print("Document data: \(dataDescription)")
                
                self.oldTouched = document.data()?["touched"] as? [String]
                //print("these are the touched")
                //print(self.oldTouched)
                
            }
        }
    }
        
        
        db.collection("/restaurants/\(restaurant.id)/rewards").getDocuments() { (querySnapshot, err) in
            if let err = err {
                //print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("hi hi hi \(document.documentID) => \(document.data())")
                    
                    var pls = Discount(dictionary: document.data())
                    self.discs.append(pls!)
                    
                    
                }
                self.discountsCollectionView.reloadData()
            }
        }
        
        
        db.collection("/restaurants/\(restaurant.id)/menu").getDocuments() { (querySnapshot, err) in
            if let err = err {
                //print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("hi hi hi \(document.documentID) => \(document.data())")

                    var pls = MenuItem(dictionary: document.data())
                    self.items.append(pls!)
                    
                    //adding item to dictionary into array for its category
                    let key = pls!.cat
                    if(self.catDict.keys.contains(key)){
                        var tempArr = self.catDict[key]
                        tempArr?.append(pls!)
                        self.catDict.updateValue(tempArr!, forKey: key)
                    }else{
                        self.catDict[key] = [pls!]
                    }
                    //self.catDict[key]?.append(pls!)
                    //print("this my key\(key)")
                    
                    // end of adding into category array
                    
                    //// eventually get rid of everything below this
//                    var emptyDictionary = [String: Any?]()
//                    var emptyDictionary1 = [String: Any?]()
//                    var emptyDictionary2 = [String: Any?]()
//
//                    emptyDictionary = document.data()
//                    var emptyArray = [String?]()
//
//                    for (key, value) in emptyDictionary{
//                        //print(key)
//                        //print(emptyDictionary[key])
//                        emptyArray.append(key)
//                    }
//                    emptyDictionary1 = emptyDictionary["addons"] as! [String : Any?]
//
//                    for(key,value) in emptyDictionary1{
//                        //print(key)
//                    }
//                    var ao = (emptyDictionary["addons"])
//
//                    //print("junk print")
                }

                self.itemTableView.reloadData()

                UIViewController.removeSpinner(spinner: sv)
                
            }
        }
 
 

        
        self.itemTableView.dataSource = self;
        self.itemTableView.delegate = self;
        self.itemTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.itemTableView.rowHeight = UITableViewAutomaticDimension
        self.itemTableView.estimatedRowHeight = 140
        //self.itemTableView.reloadData()

    }
    
    
    func loadThatData(){
        let db = Firestore.firestore()
        
        
        db.collection("/restaurants/\(restaurant.id)/rewards").getDocuments() { (querySnapshot, err) in
            if let err = err {
                //print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    var pls = Discount(dictionary: document.data())
                    self.discs.append(pls!)
                    
                    
                }
                self.discountsCollectionView.reloadData()
            }
        }
        
        
        db.collection("/restaurants/\(restaurant.id)/menu").getDocuments() { (querySnapshot, err) in
            if let err = err {
                //print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    var pls = MenuItem(dictionary: document.data())
                    self.items.append(pls!)
                    
                    //adding item to dictionary into array for its category
                    let key = pls!.cat
                    if(self.catDict.keys.contains(key)){
                        var tempArr = self.catDict[key]
                        if(pls != nil){
                            tempArr?.append(pls!)
                            self.catDict.updateValue(tempArr!, forKey: key)
                        }
                    }else{
                        self.catDict[key] = [pls!]
                    }

                }
                
                self.itemTableView.reloadData()
                
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(self.discMode == true){
            
            return self.discModeSectionCount
        }
        if(restaurant.categories.count == 0){
            return 1
        }else{
            return restaurant.categories.count;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(self.discMode == true){
            
            return self.discModeSections[section]
        }
        
        if(restaurant.categories.count == 0){
            return "Section"
        }else{
            return restaurant.categories[section];
        }    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        (view as! UITableViewHeaderFooterView).backgroundView?.backgroundColor = self.itemTableView.backgroundColor//UIColor.red.withAlphaComponent(0.4)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if(self.discMode == true){
            let key = self.discModeSections[section]
            var arrayOfItems = self.catDict[key]

            return (arrayOfItems?.count)!;
        }
        //we have to return the number of items in each category here
        let key = self.restaurant.categories[section]
        var arrayOfItems = self.catDict[key]
        //print(arrayOfItems)
        if(arrayOfItems == nil){
            return 1
        }else{
            return (arrayOfItems?.count)!;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell",
                                                 for: indexPath) as! ItemTableViewCell
//        let rest = restaurants[indexPath.row]
//        if(indexPath.row == 0){
//            let cell = tableView.dequeueReusableCell(withIdentifier: "firstCell", for: indexPath as IndexPath)
//
//            cell.viewWithTag(1)
//
//        }
        if(self.discMode == true){
            var keyForItemCat = self.discModeSections[indexPath.section]
            
            cell.populate(item: self.catDict[keyForItemCat]![indexPath.row])
            
            return cell
        }
        
        if(self.items.count > 0){
            var keyForItemCat = self.restaurant.categories[indexPath.section]
            cell.populate(item: self.catDict[keyForItemCat]![indexPath.row])
        }

        return cell
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        let defaults = UserDefaults.standard
        let uName = defaults.string(forKey: "username")
        
        if (uName == nil){
            //if ident == "YourIdentifier" {

                return false
            //}
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1
        let defaults = UserDefaults.standard
        let uName = defaults.string(forKey: "username")
        if(uName == nil){
            
            let title = "PLEASE LOGIN"
            let message = "Please sign up and login to order food!"
            let popup = PopupDialog(title: title, message: message)//, image: image)
            let buttonTwo = DefaultButton(title: "OK", dismissOnTap: true) {

                self.navigationController?.popToRootViewController(animated: true)

            }
            
            popup.addButtons([buttonTwo])
            self.present(popup, animated: true, completion: nil)
            //self.performSegue(withIdentifier: "plslogin", sender: self)
            return
        }
        
        guard let cell = tableView.cellForRow(at: indexPath) as? ItemTableViewCell else { return }
        
        
        var item = items[indexPath.row]
        

        tableView.beginUpdates()
        tableView.endUpdates()
        self.itemTableView.reloadData()

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch segue.identifier {
        
        case "addonSegue"?:
            guard let selectdRestCell = sender as? ItemTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            
            guard let indexPath = itemTableView.indexPath(for: selectdRestCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            guard let itemDetailViewController = segue.destination as? ItemDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            var keyForItemCat = self.restaurant.categories[indexPath.section]
            
            // item need to pass: self.catDict[keyForItemCat]![indexPath.row]
            //beginining of new shit
            if(self.discMode == true){
                if(self.disc.type == "category"){
                    keyForItemCat = self.discModeSections[indexPath.section]
                }
            }
            
            //end of new shit
            let selectedRest = self.catDict[keyForItemCat]![indexPath.row]
            
            itemDetailViewController.item = selectedRest
            
            if(self.discMode == true){
                itemDetailViewController.discounted = true
                itemDetailViewController.dis = self.disc
            }else{
                itemDetailViewController.discounted = false
            }
            //itemDetailViewController.
            
                //        restaurantDetailViewController.catDict = catDict
                //        restaurantDetailViewController.items = items
            
                //        switch(segue.identifier ?? "") {
                //
                //        }
                // Get the new view controller using segue.destinationViewController.
                // Pass the selected object to the new view controller.

        
            func updateTableView() {
                itemTableView.beginUpdates()
                itemTableView.endUpdates()
                self.itemTableView.reloadData()

            }
            
        case"orderSegue"?:
            
            guard let checkoutVC = segue.destination as? CheckoutViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            checkoutVC.order = self.order
            checkoutVC.rest = self.restaurant
            checkoutVC.userEmail = self.userEmail
            checkoutVC.username = self.username

            //print("pls print")
        default:
            //self.order = []
            print("statement")
        }
        
    }
        
    
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ItemDetailViewController{
            
            if(sourceViewController.isFullItem){
                let stringRep = sourceViewController.selections.joined(separator: ", ")
                var totPrice = sourceViewController.selectionPrice.reduce(0, +)
                //print(totPrice)
                //base price is last item in the array
                var fullListPrices = sourceViewController.selectionPrice
                fullListPrices.append(sourceViewController.basePrice)
                
                var temp: OrderItem!
                if(sourceViewController.discounted){
                     temp = OrderItem(price: fullListPrices, name: sourceViewController.selectionName, addons: sourceViewController.selections, discAmount: sourceViewController.dis)
                    
                }else{
                    var t = Discount(amount: 0.0,
                     count: 0.0,
                     item: "none",
                     shortDescription: "none",
                     type: "none",
                     cat: "none"
                    )
                    temp = OrderItem(price: fullListPrices, name: sourceViewController.selectionName, addons: sourceViewController.selections, discAmount: t)
                }

                self.discMode = false
                self.disc = nil
                self.discountsCollectionView.isUserInteractionEnabled = true

                DispatchQueue.main.async(execute: {() -> Void in
                
                    self.discountsCollectionView.reloadData();
                    self.itemTableView.reloadData()
                
                })
                //self.discountsCollectionView.reloadData()
                if(sourceViewController.specs != nil && sourceViewController.specs != ""){
                    temp.addons.append(sourceViewController.specs)
                }
                self.order.append(temp)
                //print("this is the order right now \(self.order)")
                
            }
            
            if(self.order.count > 0){
                self.tabBarController?.tabBar.isHidden = true;
                self.proceedToCheckout.isHidden = false;
            }
            
        }else if let sourceViewController = sender.source as? SendFriendViewController{
            //this means it came from after order done and gift sent
            //print("teehee hahahaha looool")
            self.order = []
            self.proceedToCheckout.isHidden = true;
            //add animation that says SENT!
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // your code here
            
            let title = "ORDER PLACED"
            let message = "A point was gifted and your order is confirmed! It will be ready in about 5 - 15 minutes and you will get a notification when it's done! You can go in and pick it up at the counter, no need to wait in line!"
            
            let popup = PopupDialog(title: title, message: message)//, image: image)
            
            let buttonOne = CancelButton(title: "OK") {
                //print("You canceled the car dialog.")
            }
            
            popup.addButtons([buttonOne])
            self.present(popup, animated: true, completion: nil)
            }
            
        } else if let sourceViewController = sender.source as? CheckoutViewController{
            //this means it came from place order
            //print("teehee hahahaha looool")
            if(sourceViewController.orderPlaced){
                presFriend = true
                self.order = []
                self.proceedToCheckout.isHidden = true;
            }else if (sourceViewController.exit){
                print("nothing happened :( ")

            
            }else{
                print("nothing happened :( ")
                self.order = []
                self.proceedToCheckout.isHidden = true;
            }

        }
            
            //, let meal = sourceViewController.meal {
            
            // Add a new meal.
            //let newIndexPath = IndexPath(row: meals.count, section: 0)
            
            //meals.append(meal)
            //tableView.insertRows(at: [newIndexPath], with: .automatic)
        
    }
    
//    - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    // Deselect cell
//    [tableView deselectRowAtIndexPath:indexPath animated:TRUE];
//
//    // Toggle 'selected' state
//    BOOL isSelected = ![self cellIsSelected:indexPath];
//    
//    // Store cell 'selected' state keyed on indexPath
//    NSNumber *selectedIndex = [NSNumber numberWithBool:isSelected];
//    [selectedIndexes setObject:selectedIndex forKey:indexPath];
//
//    // This is where magic happens...
//    [demoTableView beginUpdates];
//    [demoTableView endUpdates];
//    }
    


}

class rewardsCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var reward0label: UILabel!
    @IBOutlet weak var reward2price: UILabel!
    @IBOutlet weak var reward1price: UILabel!
    @IBOutlet weak var reward0price: UILabel!
    @IBOutlet weak var reward1label: UILabel!
    @IBOutlet weak var reward2label: UILabel!
    
    
    var disc0: Discount!
    var disc1: Discount!
    var disc2: Discount!

    @IBOutlet weak var userPointCount: UILabel!
    
    
    func displayContent(uP: Int){
        //        cellImage.kf.indicatorType = .activity
        //        let imgurl = URL(string: img)
        //        cellImage.kf.setImage(with: imgurl)
        
        self.userPointCount.text = "\(uP)"
        
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.borderColor = UIColor.gray.cgColor
        self.contentView.layer.masksToBounds = true
        if(disc0 != nil){
            reward0label.text = disc0.shortDescription
            reward1label.text = disc1.shortDescription
            reward2label.text = disc2.shortDescription
            
            reward0price.text = String(describing: disc0.count)
            reward1price.text = String(describing: disc1.count)
            reward2price.text = String(describing: disc2.count)
        }

        //        self.layer.shadowColor = UIColor.black.cgColor
        //        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        //        self.layer.shadowRadius = 2.0
        //        self.layer.shadowOpacity = 0.5
        //        self.layer.masksToBounds = false
        //        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        //
    }
    
}

class discountCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var reward0label: UILabel!
    
    var disc: Discount!
    @IBOutlet weak var discountDesc: UILabel!
    
    func displayContent(){
//        cellImage.kf.indicatorType = .activity
//        let imgurl = URL(string: img)
//        cellImage.kf.setImage(with: imgurl)
        discountDesc.text = disc.shortDescription
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.borderColor = UIColor.gray.cgColor
        self.contentView.layer.masksToBounds = true
        
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
//        self.layer.shadowRadius = 2.0
//        self.layer.shadowOpacity = 0.5
//        self.layer.masksToBounds = false
//        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
//
    }
    
}



