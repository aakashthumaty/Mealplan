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


class RestaurantDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var itemTableView: UITableView!
    @IBOutlet weak var discountsCollection: UICollectionView!
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var restaurantDescription: UITextView!
    @IBOutlet weak var ratingImage: UIImageView!
    
    @IBOutlet weak var headerView: UIView!
    
    
    var items: [MenuItem] = []
    var restaurant: Restaurant!
    var catDict: Dictionary<String, [MenuItem]> = [:]

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.restaurantName.text = ""
        self.restaurantDescription.text = ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let header = self.headerView
        itemTableView.tableHeaderView = header
        
        itemTableView.estimatedRowHeight = 40
        itemTableView.rowHeight = UITableViewAutomaticDimension
        
        //label.text = restaurant.title
        print("hi rest dict\(restaurant.dictionary)")
        
        ///restaurants/tmt0000002/menu
        let db = Firestore.firestore()
        
        
        
        db.collection("/restaurants/\(restaurant.id)/menu").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("hi hi hi \(document.documentID) => \(document.data())")

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
                    print("this my key\(key)")
                    
                    // end of adding into category array

                    self.restaurantName.text = self.restaurant.title
                    self.restaurantDescription.text = self.restaurant.description
                    
                    //// eventually get rid of everything below this
                    var emptyDictionary = [String: Any?]()
                    var emptyDictionary1 = [String: Any?]()
                    var emptyDictionary2 = [String: Any?]()
                    
                    emptyDictionary = document.data()
                    var emptyArray = [String?]()
                    
                    for (key, value) in emptyDictionary{
                        print(key)
                        print(emptyDictionary[key])
                        emptyArray.append(key)
                    }
                    emptyDictionary1 = emptyDictionary["addons"] as! [String : Any?]
                    
                    for(key,value) in emptyDictionary1{
                        print(key)
                    }
                    var ao = (emptyDictionary["addons"])

                    print("junk print")
                }

                self.itemTableView.reloadData()

            }
        }
 
 
        
        self.itemTableView.dataSource = self;
        self.itemTableView.delegate = self;
        self.itemTableView.tableFooterView = UIView(frame: CGRect.zero)

        //self.itemTableView.reloadData()

    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(restaurant.categories.count == 0){
            return 1
        }else{
            return restaurant.categories.count;
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: SectionHeaderHeight))
//        view.backgroundColor = UIColor(red: 253.0/255.0, green: 240.0/255.0, blue: 196.0/255.0, alpha: 1)
//        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.bounds.width - 30, height: SectionHeaderHeight))
//        label.font = UIFont.boldSystemFont(ofSize: 15)
//        label.textColor = UIColor.black
//        if let tableSection = TableSection(rawValue: section) {
//            switch tableSection {
//            case .action:
//                label.text = "Action"
//            case .comedy:
//                label.text = "Comedy"
//            case .drama:
//                label.text = "Drama"
//            case .indie:
//                label.text = "Indie"
//            default:
//                label.text = ""
//            }
//        }
//        view.addSubview(label)
//        return view
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 250.0;//Choose your custom row height
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {


        //we have to return the number of items in each category here
        let key = self.restaurant.categories[section]
        var arrayOfItems = self.catDict[key]
        print(arrayOfItems)
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
        if(self.items.count > 0){
            
            print("index path is \(indexPath.row)")
            var keyForItemCat = self.restaurant.categories[indexPath.section]
            
            cell.populate(item: self.catDict[keyForItemCat]![indexPath.row])
            //cell.populate(item: self.items[indexPath.row])
        }
        print("populating cell for item")

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1
        
        guard let cell = tableView.cellForRow(at: indexPath) as? ItemTableViewCell else { return }
        
        
        var item = items[indexPath.row]
        cell
        
        // 2
//        work.isExpanded = !work.isExpanded
//        selectedArtist.works[indexPath.row] = work
//
//        // 3
//        cell.moreInfoTextView.text = work.isExpanded ? work.info : moreInfoText
//        cell.moreInfoTextView.textAlignment = work.isExpanded ? .left : .center
        
        // 4
        tableView.beginUpdates()
        tableView.endUpdates()
        
        // 5
        tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
    
    
    func updateTableView() {
        itemTableView.beginUpdates()
        itemTableView.endUpdates()
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


