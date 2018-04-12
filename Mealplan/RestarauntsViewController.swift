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
import FirebaseFacebookAuthUI
import FirebaseGoogleAuthUI
import FirebasePhoneAuthUI


class RestarauntsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FUIAuthDelegate {
    
    private var restaurants: [Restaurant] = []
    private var documents: [DocumentSnapshot] = []
    var userEmail: String!
    var username: String = ""
    
    @IBOutlet weak var restTable: UITableView!
    @IBOutlet weak var restHeaderView: UIView!
    @IBOutlet weak var oView: UIView!
    @IBOutlet weak var signupView: UIView!
    @IBOutlet weak var doneSignup: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.title = "Restaurants"
        
        restTable.tableHeaderView = restHeaderView
        // Hide the navigation bar on the this view controller
        //self.view.sendSubview(toBack: self.restHeaderView)
        
        self.signupView.isHidden = true;
        self.oView.isHidden = true;
        self.doneSignup.isHidden = true;
        
//        self.doneSignup.clipsToBounds = true
//        self.doneSignup.layer.cornerRadius = 15
        //self.navigationController?.setNavigationBarHidden(true, animated: false)
        //self.tabBarController?.tabBar.isHidden = false

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Show the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//        super.prepare(for: segue, sender: sender)
//
//        switch segue.identifier {
//            case "showRestDetail"?:
//            print("showing rest detail")
//            guard let restDetailVC = segue.destination as? RestaurantDetailViewController else {
//                fatalError("Unexpected destination: \(segue.destination)")
//            }
//            restDetailVC.username = self.username
//            restDetailVC.userEmail = self.userEmail
//
//        default:
//            print("error with segue")
//
//        }
//
//    }
    
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
        restaurantDetailViewController.username = self.username
        restaurantDetailViewController.userEmail = self.userEmail
//        restaurantDetailViewController.catDict = catDict
//        restaurantDetailViewController.items = items

//        switch(segue.identifier ?? "") {
//
//        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            self.userEmail = user.email!
        }
            usernameField.setBottomBorder()
            nameField.setBottomBorder()
        
            self.signupView.clipsToBounds = true
            self.signupView.layer.cornerRadius = 30
            self.signupView.isHidden = false;
            self.oView.isHidden = false;
            self.doneSignup.isHidden = false;
            
            self.signupView.alpha = 0
            self.oView.alpha = 0
            self.doneSignup.alpha = 0
            
            self.view.bringSubview(toFront: self.oView)
            self.view.bringSubview(toFront: self.signupView)
            self.view.bringSubview(toFront: self.doneSignup)
            
            UIView.animate(withDuration: 0.5, delay: 0,
                           options: [.curveEaseInOut],
                           animations: {
                            self.signupView.alpha = 1
                            self.oView.alpha = 0.75
                            self.doneSignup.alpha = 1
                  
            },
                           completion: nil
            )
    }
    
    @IBAction func signUP(_ sender: Any) {
        
        if(usernameField.text == "" || nameField.text == ""){
            return;
        }
        
        let db = Firestore.firestore()

        // Create a reference to the cities collection
        let citiesRef = db.collection("users")
        
        // Create a query against the collection.
        let query = citiesRef.whereField("username", isEqualTo: self.usernameField.text).getDocuments(){ (querySnapshot, err) in
        if let err = err {
            print("Error getting documents: \(err)")
        } else {
            //add user
            if(querySnapshot?.count == 0){
                // handle user and error as necessary
                print("this just happened")
                
                let email = self.userEmail
                let name = self.nameField.text
                let username = self.usernameField.text
                
                // Add a new document with a generated id.
                db.collection("users").document(username!).setData([
                    "name": name,
                    "touched": ["Japan"],
                    "username": username,
                    "email": email
                    ])
                
                let defaults = UserDefaults.standard
                defaults.set(username, forKey: "username")
//                defaults.set(true, forKey: "UseTouchID")
//                defaults.set(CGFloat.pi, forKey: "Pi")
                
                UIView.animate(withDuration: 0.5, delay: 0,
                               options: [.curveEaseInOut],
                               animations: {
                                self.oView.alpha = 0
                                self.signupView.alpha = 0
                                self.doneSignup.alpha = 0
                                
                },
                               completion: {finished in self.disappear()}
                )

            }else{
                // username taken
                print("username taken")
                let alertController = UIAlertController(title: "Username Taken", message: "Great minds think alike. Sorry, that username is already taken 😔.", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                {
                    (result : UIAlertAction) -> Void in
                    print("You pressed OK")
                }
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
        }
        
        
    }
    
    func disappear(){
        self.signupView.isHidden = true;
        self.oView.isHidden = true;
        self.doneSignup.isHidden = true;
        
        self.view.sendSubview(toBack: self.oView)
        self.view.sendSubview(toBack: self.signupView)
        self.view.sendSubview(toBack: self.doneSignup)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let db = Firestore.firestore()
        //try! Auth.auth().signOut()

//        do {
//            try Auth.auth().signOut()
//        } catch let error {
//            // handle error here
//            print("Error trying to sign out of Firebase: \(error.localizedDescription)")
//        }
        
        if Auth.auth().currentUser != nil {
            //user is signed in

            self.userEmail = (Auth.auth().currentUser?.email)!
            let defaults = UserDefaults.standard
            let uName = defaults.string(forKey: "username")

            self.username = uName!
            let docRef = db.collection("users").document(uName!)
            
            docRef.getDocument { (document, error) in
                if let document = document, document.exists {
                    let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                    print("Document data: \(dataDescription)")
                    //self.username = document["username"] as! String
                    print("user signed in \(self.username)")

                } else {
                    print("Document does not exist")
                }
            }

        } else {
            // No user is signed in.
            // ...
            let authUI = FUIAuth.defaultAuthUI()
            // You need to adopt a FUIAuthDelegate protocol to receive callback
            authUI?.delegate = self as? FUIAuthDelegate
            let providers: [FUIAuthProvider] = [
                FUIGoogleAuth(),
                FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
                FUIFacebookAuth(),
                
                ]
            authUI?.providers = providers
            
            //let authViewController = BizzyAuthViewController(authUI: authUI!)

            let authViewController = authUI!.authViewController()
            
            self.present(authViewController, animated: true, completion: nil)
        }


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
        
        db.collection("restaurants").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    
                    var pls = Restaurant(dictionary: document.data())
                    if(pls != nil){
                        self.restaurants.append(pls!)
                    }else{
                        print("aiyah Database")
                    }
                    //print(pls!)
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

extension UITextField {
    func setBottomBorder() {
        self.borderStyle = .none
        self.layer.backgroundColor = UIColor.white.cgColor
        
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 0.0
    }
}

//this is to customize login picker

class BizzyAuthViewController: FUIAuthPickerViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
//
        let imageViewBackground = UIImageView(frame: CGRect(x: width/2, y: height/2, width: width/2, height: height/2))
        imageViewBackground.image = UIImage(named: "platter-256")
        
        // you can change the content mode:
        //imageViewBackground.contentMode = UIViewContentMode.scaleAspectFill
        
        view.insertSubview(imageViewBackground, at: 0)
    }}

