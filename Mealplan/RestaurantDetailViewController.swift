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
    @IBOutlet weak var restarauntLabel: UILabel!
    
    
    private var items: [MenuItem] = []
    var restaurant: Restaurant!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemTableView.estimatedRowHeight = 40
        itemTableView.rowHeight = UITableViewAutomaticDimension
        
        //label.text = restaurant.title
        print(restaurant.dictionary)
        
        ///restaurants/tmt0000002/menu
        let db = Firestore.firestore()
        
        db.collection("/restaurants/\(restaurant.id)/menu").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("hi hi hi \(document.documentID) => \(document.data())")
//                    var pls = Restaurant(dictionary: ugh.data())
//                    
//                    self.restaurants.append(pls!)
                    var pls = MenuItem(dictionary: document.data())
                    self.items.append(pls!)
                    
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
            }
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(restaurant.categories.count == 0){
            return 1
        }else{
            return restaurant.categories.count;
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemTableViewCell",
                                                 for: indexPath) as! ItemTableViewCell
//        let rest = restaurants[indexPath.row]
        
        cell.populate(item: self.items[indexPath.row])
        print("populating cell")

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


