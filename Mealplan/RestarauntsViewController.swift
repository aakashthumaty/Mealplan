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
    
    private var listener: ListenerRegistration?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor.orange
        
        let sectionIcon = UIImageView(image: UIImage(named: "restIcon")!)
        sectionIcon.frame = CGRect(x: 25, y: 20, width: 60, height: 60)
        sectionIcon.clipsToBounds = true
        sectionIcon.layer.cornerRadius = 30
        view.addSubview(sectionIcon)
        
        let label = UILabel()
        label.text = "sectionTitles[section]"
        label.frame = CGRect(x: 75, y: 20, width: 300, height: 35)
        view.addSubview(label)
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 120
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("got here pleae")
        print(restaurants.count)
        return restaurants.count 
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 250.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantTableViewCell",
                                                 for: indexPath) as! RestaurantTableViewCell

        let rest = restaurants[indexPath.row]

        cell.populate(restaurant: rest)
        
        print("populating cell")
        return cell
        
    }

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        guard let restaurantDetailViewController = segue.destination as? RestaurantDetailViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        
        guard let selectdRestCell = sender as? RestaurantTableViewCell else {
            fatalError("Unexpected sender: \(sender)")
        }
        
        guard let indexPath = restTable.indexPath(for: selectdRestCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }
        
        let selectedRest = restaurants[indexPath.row]
        restaurantDetailViewController.restaurant = selectedRest
        print("got here segue stuff")

//        switch(segue.identifier ?? "") {
//
//        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view, typically from a nib.
        
        let db = Firestore.firestore()
        
        db.collection("restaurants").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    
                    var pls = Restaurant(dictionary: document.data())
                    self.restaurants.append(pls!)
                    print("Current data: \(document.data())")
  
                    print(self.restaurants)
                    
                    //#warning - make sure the listener is being removed correctly here
                    print("got here")
                }
                self.restTable.reloadData()

            }
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

