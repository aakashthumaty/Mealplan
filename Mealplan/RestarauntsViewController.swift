//
//  FirstViewController.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 3/24/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//


//reference code for later

//time formatter///////////////////////////////////////////////////////////////////////////////////////////////

//let dateFormatter = DateFormatter()
//dateFormatter.dateFormat = "hh:mm a"
//dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
//
//let item = "7:00 PM"
//let date = dateFormatter.date(from: item)
//print("Start: \(date)") // Start: Optional(2000-01-01 19:00:00 +0000)

import UIKit
import Firebase


class RestarauntsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var restaurants: [Restaurant] = []
    private var documents: [DocumentSnapshot] = []

    @IBOutlet weak var restTable: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("got here pleae")
        print(restaurants.count)
        return restaurants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantTableViewCell",
                                                 for: indexPath) as! RestaurantTableViewCell
        let rest = restaurants[indexPath.row]
        
        cell.populate(restaurant: rest)
        print("populating cell")
        return cell
        
    }
    
    fileprivate var query: Query? {
        didSet {
            if let listener = listener {
                listener.remove()
                observeQuery()
            }
        }
    }
    
    private var listener: ListenerRegistration?
    
    fileprivate func observeQuery() {
//        guard let query = query else { return }
//        stopObserving()
        

                //print("Current data: \(document.data())")
//        }
    }
    
    fileprivate func stopObserving() {
        listener?.remove()
        print("got here")
    }
    
    fileprivate func baseQuery() -> Query {
        return Firestore.firestore().collection("restaurants")
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        
        query = baseQuery()
//        observeQuery()
        
        let db = Firestore.firestore()
        
        db.collection("restaurants")
            .addSnapshotListener { QuerySnapshot, error in
                guard let document = QuerySnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                for ugh in (QuerySnapshot?.documents)!{
                    var pls = Restaurant(dictionary: ugh.data())
                    
                    self.restaurants.append(pls!)
                    print("Current data: \(ugh.data())")
                }
                print(self.restaurants)
                
                self.restTable.reloadData()


        }
//        stackViewHeightConstraint.constant = 0
//        activeFiltersStackView.isHidden = true
        
        self.restTable.dataSource = self;
        self.restTable.delegate = self;

        self.restTable.tableFooterView = UIView(frame: CGRect.zero)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

