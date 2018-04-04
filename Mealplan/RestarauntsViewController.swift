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
import FirebaseAuthUI
import FacebookLogin
import FacebookCore

import FirebaseGoogleAuthUI
import FirebaseTwitterAuthUI
import FirebasePhoneAuthUI

class RestarauntsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FUIAuthDelegate {
    
    private var restaurants: [Restaurant] = []
    private var documents: [DocumentSnapshot] = []

    @IBOutlet weak var restTable: UITableView!
    
    @IBOutlet weak var restHeaderView: UIView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        restTable.tableHeaderView = restHeaderView
        // Hide the navigation bar on the this view controller
        //self.view.sendSubview(toBack: self.restHeaderView)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        //self.tabBarController?.tabBar.isHidden = false

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView()
//        view.backgroundColor = UIColor.white
//
//        let sectionIcon = UIImageView(image: UIImage(named: "restIcon")!)
//        sectionIcon.frame = CGRect(x: 25, y: 20, width: 60, height: 60)
////        sectionIcon.clipsToBounds = true
////        sectionIcon.layer.cornerRadius = 30
//        view.addSubview(sectionIcon)
//
//        let label = UILabel()
//        label.text = "Restaurants"
//        label.frame = CGRect(x: 0, y: 15, width: 375, height: 60)
//        label.font = UIFont(name: "AvenirNextUltraLight", size: 48)
//        view.addSubview(label)
//
//        return self.restHeaderView
//    }
//    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 60
//    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("got here pleae")
        //print(restaurants.count)
        return restaurants.count 
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 225.0;//Choose your custom row height
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantTableViewCell",
                                                 for: indexPath) as! RestaurantTableViewCell

        let rest = restaurants[indexPath.row]

        cell.populate(restaurant: rest)
        
        print("populating cell")
        return cell
        
    }
    
    
   
     
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("shit a bird out")
    }
        
    /*
     
     ///restaurants/tmt0000002/menu
     let db = Firestore.firestore()
     
     let selectedRest = restaurants[indexPath.row]
     var items: [MenuItem] = []
     var catDict: Dictionary<String, [MenuItem]> = [:]
     
     
     db.collection("/restaurants/\(selectedRest.id)/menu").getDocuments() { (querySnapshot, err) in
     if let err = err {
     print("Error getting documents: \(err)")
     } else {
     for document in querySnapshot!.documents {
     print("hi hi hi \(document.documentID) => \(document.data())")
     //                    var pls = Restaurant(dictionary: ugh.data())
     //
     //                    self.restaurants.append(pls!)
     var pls = MenuItem(dictionary: document.data())
     items.append(pls!)
     
     let key = pls!.cat
     catDict[key]!.append(pls!)
     print("this my key\(key)")
     
     }
     
     print("got here segue stuff")
     
     }
     }
     
     self
     .performSegue(withIdentifier: "showRestDetail", sender: self)
     func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
     if segue.identifier == "showRestDetail" {
     guard let restaurantDetailViewController = segue.destination as? RestaurantDetailViewController else {
     fatalError("Unexpected destination: \(segue.destination)")
     }
     
     
     restaurantDetailViewController.restaurant = selectedRest
     restaurantDetailViewController.catDict = catDict
     restaurantDetailViewController.items = items
     
     }
     }
     }
 
 */

     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        
        guard let selectdRestCell = sender as? RestaurantTableViewCell else {
            fatalError("Unexpected sender: \(sender)")
        }
        
        guard let indexPath = restTable.indexPath(for: selectdRestCell) else {
            fatalError("The selected cell is not being displayed by the table")
        }

        let selectedRest = restaurants[indexPath.row]

        guard let restaurantDetailViewController = segue.destination as? RestaurantDetailViewController else {
            fatalError("Unexpected destination: \(segue.destination)")
        }
        restaurantDetailViewController.restaurant = selectedRest
//        restaurantDetailViewController.catDict = catDict
//        restaurantDetailViewController.items = items

//        switch(segue.identifier ?? "") {
//
//        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        // handle user and error as necessary
        print("this just happened")
        let db = Firestore.firestore()

        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            let uid = user.uid
            let email = user.email
            
            // Add a new document with a generated id.
            db.collection("users").document(email!).setData([
                "name": "Tokyo",
                "country": "Japan"
                ])
            
            db.collection("users").document(email!).collection("orders").document().setData([
                "order": "test",
                "country": "Japan"
                ])

//            var ref: DocumentReference? = nil
//            ref = db.collection("users").addDocument(data: [
//                "name": "Tokyo",
//                "country": "Japan"
//            ]) { err in
//                if let err = err {
//                    print("Error adding document: \(err)")
//                } else {
//                    print("Document added with ID: \(ref!.documentID)")
//                }
//            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //FirebaseApp.configure()

        let authUI = FUIAuth.defaultAuthUI()
        // You need to adopt a FUIAuthDelegate protocol to receive callback
        authUI?.delegate = self as? FUIAuthDelegate
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            FUITwitterAuth(),
            FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
            ]
        authUI?.providers = providers
        
        let authViewController = authUI!.authViewController()

        self.present(authViewController, animated: true, completion: nil)
//        FacebookSignInManager.basicInfoWithCompletionHandler(self) { (dataDictionary:Dictionary<String, AnyObject>?, error:NSError?) -> Void in
//
//        }
        
        //login for first time use
            //eventually change this to first time somone tries to order
//
//        let loginButton = LoginButton(readPermissions: [ .publicProfile, .email ])
//        loginButton.center = view.center
//        view.addSubview(loginButton)

        // Do any additional setup after loading the view, typically from a nib.
        
        let db = Firestore.firestore()

        db.collection("restaurants").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    
                    var pls = Restaurant(dictionary: document.data())
                    self.restaurants.append(pls!)
                    //print("Current data: \(document.data())")
  
                    //print(self.restaurants)
                    
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

