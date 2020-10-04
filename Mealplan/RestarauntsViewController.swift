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
import FirebaseFirestore
import FirebaseAuth
import FirebaseUI
//import FirebaseFacebookAuthUI
import OneSignal
import FBSDKLoginKit
import PopupDialog
import Kingfisher

class RestarauntsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,UITextFieldDelegate, FUIAuthDelegate, UITabBarControllerDelegate {
    
    private var restaurants: [Restaurant] = []
    private var documents: [DocumentSnapshot] = []
    var userEmail: String!
    var username: String = ""
    var restIDs: [String] = []
    var name: String = ""
    
    var architectView = UIView()
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var FSUButton: UIView!
    
    @IBOutlet weak var restTable: UITableView!
    @IBOutlet weak var restHeaderView: UIView!
    @IBOutlet weak var oView: UIView!
    @IBOutlet weak var signupView: UIView!
    @IBOutlet weak var doneSignup: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    @IBOutlet weak var tos: UIButton!
    
    var pointDict: Dictionary<String,Int> = [:]
    
    @IBAction func signUp(_ sender: Any) {
        bigBang()
    }
    @IBOutlet weak var signUpTapped: UIButton!
    override func viewWillAppear(_ animated: Bool) {
        signUpTapped.isHidden = true
        let defaults = UserDefaults.standard
        let uName = defaults.string(forKey: "username")
        if(uName == nil){
            signUpTapped.isHidden = false
        }
        super.viewWillAppear(animated)
        
        if(self.username != nil && self.username != " " && self.username != ""){
            self.loadThemPoints()
        }
        //self.loadThemPoints()
        //self.loadThemRests()
        
        
        self.title = "Restaurants"
        
        restTable.tableHeaderView = headerView
        // Hide the navigation bar on the this view controller
        //self.view.sendSubview(toBack: self.restHeaderView)
        
        self.signupView.isHidden = true;
        self.oView.isHidden = true;
        self.doneSignup.isHidden = true;
        self.tos.isHidden = true
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
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? OrdersViewController{
            return;
        }
        
        if let sourceViewController = sender.source as? FSUViewController{
            return;
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("got here pleae")
        //print(restaurants.count)
        return restaurants.count 
    }
    
    @objc func tabTap(tapGesture: UITapGestureRecognizer) {
        //        let imgView = tapGesture.view as! UIImageView
        //        let idToMove = imgView.tag
        let tapLocation = tapGesture.location(in: self.view)
        print("this happened")
        bigBang()
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 245.0;//Choose your custom row height
    }
    
    @objc func imgTap(tapGesture: UITapGestureRecognizer) {
//        let imgView = tapGesture.view as! UIImageView
//        let idToMove = imgView.tag
        let tapLocation = tapGesture.location(in: self.restTable)
        if let tapIndexPath = self.restTable.indexPathForRow(at: tapLocation) {
            if let tappedCell = self.restTable.cellForRow(at: tapIndexPath) as? RestaurantTableViewCell {
                //do what you want to cell here
                self.restTable.selectRow(at: tapIndexPath, animated: false, scrollPosition: .none)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) { // change 2 to desired number of seconds
                    self.performSegue(withIdentifier: "showRestDetail", sender: self.restTable.cellForRow(at: tapIndexPath))
                }
                
            }
        //print("pls say you got tapped")
        
        //Do further execution where you need idToMove
        
        }
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantTableViewCell",
                                                 for: indexPath) as! RestaurantTableViewCell

        //cell.restCollectionView.
        //_ = UITapGestureRecognizer (target: cell.restCollectionView, action: #selector(imgTap(tapGesture:)))
        cell.restCollectionView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imgTap(tapGesture:))))

        
        cell.majorIndexPath = indexPath
        let rest = restaurants[indexPath.row]

        
        if(self.pointDict[rest.id] != nil){
            cell.populate(restaurant: rest, points: self.pointDict[rest.id]!)
            //print("they are open \(rest.open)")
            if(rest.open == false){
                cell.closedLabel.isHidden = false
                cell.isUserInteractionEnabled = false

            }
        }else{
            cell.populate(restaurant: rest, points: 0)
            if(rest.open == false){
                cell.isUserInteractionEnabled = false
                cell.closedLabel.isHidden = false
            }

        }
        
        //print("populating cell")
        return cell
        
    }
    
    
   
     
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("shit a bird out")
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
        
        switch segue.identifier {
            
        case "ordersSegue"?:
            if(self.username != ""){
                
                print("should go to orders")
            }
            
        default:
            
            guard let selectdRestCell = sender as? RestaurantTableViewCell else {
                //guard let restVC = sender as? self else {
                    fatalError("Unexpected sender: \(sender)")
                //}
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

            if(self.username != ""){
                
            
                let db = Firestore.firestore()
                let meReference = db.collection("users").document(self.username)
                
                meReference.addSnapshotListener { (document, error) in
                    if let document = document, document.exists {
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        //print("Document data: \(dataDescription)")
                        
                        if(document.data()![selectedRest.id] != nil){
                            var obj: Dictionary<String, Any> = [:]
                            //obj.append(document.data()!["tru0000001"] as! [String : Any])
                            
                            obj = document.data()![selectedRest.id] as! Dictionary<String, Any>
                            //print(obj["points"])
                            print(document.data()![selectedRest.id])
                            var tString = obj["points"]!
                            //if((tString as! Int) != nil){
                                restaurantDetailViewController.userPoints = (tString as! Int)
    //                        }else{
    //                            restaurantDetailViewController.userPoints = 0
    //                        }
                            //totalData = (jsonDict["totalfup"] as! NSString).doubleValue
                            
                        }
                        
                    } else {
                        //print("Document does not exist")
                    }
                }
                
            }
            
        }
            
            
        
//        restaurantDetailViewController.catDict = catDict
//        restaurantDetailViewController.items = items

//        switch(segue.identifier ?? "") {
//
//        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    @IBAction func facebookLogin(sender: UIButton) {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
            if let error = error {
                //print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
               // print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            
            // Perform login by calling Firebase APIs
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    //print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                // Present the main view
                if let viewController = self.storyboard?.instantiateViewController(withIdentifier: "MainView") {
                    UIApplication.shared.keyWindow?.rootViewController = viewController
                    self.dismiss(animated: true, completion: nil)
                }
                
            })
            
        }
    }
    
    
    func authUI(_ authUI: FUIAuth, didSignInWith user: User?, error: Error?) {
        /////this is where I check if the email exists and if so dont do the username flow
        if let user = user {
            // The user's ID, unique to the Firebase project.
            // Do NOT use this value to authenticate with your backend server,
            // if you have one. Use getTokenWithCompletion:completion: instead.
            self.userEmail = user.email!


        }
        
        let db = Firestore.firestore()
        
        // Create a reference to the cities collection
        let citiesRef = db.collection("users")
        
        // Create a query against the collection.
        let query = citiesRef.whereField("email", isEqualTo: self.userEmail).getDocuments(){ (querySnapshot, err) in
            if let err = err {
                //print("Error getting documents: \(err)")
            } else {
                //add user
                if((querySnapshot?.count)! == 1){
                    
                    //this is a user who deleted app and is relogging in
                    
                    for document in querySnapshot!.documents {
                        
                        print(document.data())
                        var pls = OurUser(dictionary: document.data())
                        
                        if(pls != nil){
                            
                            //ask for notif stuff
                            
                            let defaults = UserDefaults.standard
                            defaults.set(pls?.username, forKey: "username")
                            //                defaults.set(true, forKey: "UseTouchID")
                            //                defaults.set(CGFloat.pi, forKey: "Pi")
                            
                            let title = "ACCEPT NOTIFICATION FOR REWARDS"
                            let message = "Please accept push notifications to receive  free points, new info and special discounts!"
                            
                            let popup = PopupDialog(title: title, message: message)//, image: image)
                            
                            let buttonTwo = DefaultButton(title: "OK", dismissOnTap: true) {
                                //print("You canceled the car dialog.")
                                
                                OneSignal.promptForPushNotifications(userResponse: { accepted in
                                    // print("User accepted notifications: \(accepted)")
                                    
                                    let name = pls?.name
                                    let username = pls?.username //username
                                    
                                    self.username = username!
                                    
                                    OneSignal.setEmail(self.userEmail);
                                    let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                                    
                                    let hasPrompted = status.permissionStatus.hasPrompted
                                    //print("hasPrompted = \(hasPrompted)")
                                    let userStatus = status.permissionStatus.status
                                    //print("userStatus = \(userStatus)")
                                    
                                    let isSubscribed = status.subscriptionStatus.subscribed
                                    //print("isSubscribed = \(isSubscribed)")
                                    let userSubscriptionSetting = status.subscriptionStatus.userSubscriptionSetting
                                    //print("userSubscriptionSetting = \(userSubscriptionSetting)")
                                    let userID = status.subscriptionStatus.userId
                                    //print("userID = \(userID)")
                                    var pushToken = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId
                                    //print("pushToken = \(pushToken)")
                                    
                                    
                                    if(OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId == nil){
                                        pushToken = " "
                                    }
                                    
                                    db.collection("users").document(self.username).updateData([
                                        "pushToken": OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId
                                        ])
                                    
                                })
                            }
                            popup.addButtons([buttonTwo])
                            self.present(popup, animated: true, completion: nil)
                            //ask for notif stuff
         
                            UIView.animate(withDuration: 0.5, delay: 0,
                                           options: [.curveEaseInOut],
                                           animations: {
                                            self.oView.alpha = 0
                                            self.signupView.alpha = 0
                                            self.doneSignup.alpha = 0
                                            self.tos.alpha = 0
                                            
                            },
                                           completion: {finished in self.disappear()}
                            )

                        }
                    }
                }else if((querySnapshot?.count)! == 3){
                    
                    var listOfUNames: Array<String> = []
                    
                    for document in querySnapshot!.documents {
                        
                        print(document.data())
                        var pls = OurUser(dictionary: document.data())
                        
                        if(pls != nil){
                            listOfUNames.append((pls?.username)!)
                        }
                    }
                            //ask for notif stuff

                    //default popup view setup
                    let title = "You Have Multiple Accounts"
                    let message = "Please choose the username of the account you'd like to sign in with. Please choose a username with only alphabetic characters. I'm sorry :( If you do not see the correct username in this list please contact us from the help button in the main tab."
                    
                    let popup = PopupDialog(title: title, message: message)//, image: image)
                    
                    let buttonFirstUsername = DefaultButton(title: listOfUNames[0], dismissOnTap: true) {
                        //print("You canceled the car dialog.")
                        let defaults = UserDefaults.standard
                        defaults.set(listOfUNames[0], forKey: "username")
                        self.username = listOfUNames[0]
                        self.signinUserWithExistingUsername()
                    }
                    
                    let buttonSecondUsername = DefaultButton(title: listOfUNames[1], dismissOnTap: true) {
                        //print("You canceled the car dialog.")
                        let defaults = UserDefaults.standard
                        defaults.set(listOfUNames[1], forKey: "username")
                        self.username = listOfUNames[1]
                        self.signinUserWithExistingUsername()
                    }
                    
                    let buttonThirdUsername = DefaultButton(title: listOfUNames[2], dismissOnTap: true) {
                        //print("You canceled the car dialog.")
                        let defaults = UserDefaults.standard
                        defaults.set(listOfUNames[2], forKey: "username")
                        self.username = listOfUNames[2]
                        self.signinUserWithExistingUsername()
                    }
                    
                    popup.addButtons([buttonFirstUsername, buttonSecondUsername, buttonThirdUsername])
                    self.present(popup, animated: true, completion: nil)
                    

                    
                    
                }else if((querySnapshot?.count)! == 2){
                    
                    var listOfUNames: Array<String> = []
                    
                    for document in querySnapshot!.documents {
                        
                        print(document.data())
                        var pls = OurUser(dictionary: document.data())
                        
                        if(pls != nil){
                            listOfUNames.append((pls?.username)!)
                        }
                    }
                    //ask for notif stuff
                    
                    //default popup view setup
                    let title = "You Have Multiple Accounts"
                    let message = "Please choose the username of the account you'd like to sign in with. Please choose a username with only alphabetic characters. I'm sorry :( If you do not see the correct username in this list please contact us from the help button in the main tab."
                    
                    let popup = PopupDialog(title: title, message: message)//, image: image)
                    
                    let buttonFirstUsername = DefaultButton(title: listOfUNames[0], dismissOnTap: true) {
                        //print("You canceled the car dialog.")
                        let defaults = UserDefaults.standard
                        defaults.set(listOfUNames[0], forKey: "username")
                        self.username = listOfUNames[0]
                        self.signinUserWithExistingUsername()
                    }
                    
                    let buttonSecondUsername = DefaultButton(title: listOfUNames[1], dismissOnTap: true) {
                        //print("You canceled the car dialog.")
                        let defaults = UserDefaults.standard
                        defaults.set(listOfUNames[1], forKey: "username")
                        self.username = listOfUNames[1]
                        self.signinUserWithExistingUsername()
                    }

                    
                    popup.addButtons([buttonFirstUsername, buttonSecondUsername])
                    self.present(popup, animated: true, completion: nil)
                    
                    
                    
                    
                }else{
                    //if no user with this email = this is a brand new user making an account
                    
                    self.usernameField.setBottomBorder()
                    self.nameField.setBottomBorder()
                    
                    self.signupView.clipsToBounds = true
                    self.signupView.layer.cornerRadius = 30
                    self.signupView.isHidden = false;
                    self.oView.isHidden = false;
                    self.doneSignup.isHidden = false;
                    self.tos.isHidden = false
                    
                    self.signupView.alpha = 0
                    self.oView.alpha = 0
                    self.doneSignup.alpha = 0
                    self.tos.alpha = 0
                    
                    self.view.bringSubview(toFront: self.oView)
                    self.view.bringSubview(toFront: self.signupView)
                    self.view.bringSubview(toFront: self.doneSignup)
                    self.view.bringSubview(toFront: self.tos)
                    
                    let title = "ACCEPT NOTIFICATION FOR REWARDS"
                    let message = "Please accept push notifications to receive  free points, new info and special discounts!"
                    
                    let popup = PopupDialog(title: title, message: message)//, image: image)
                    
                    let buttonTwo = DefaultButton(title: "OK", dismissOnTap: true) {
                        //print("You canceled the car dialog.")
                        
                        OneSignal.promptForPushNotifications(userResponse: { accepted in
                            // print("User accepted notifications: \(accepted)")
                        })
                    }
                    
                    popup.addButtons([buttonTwo])
                    self.present(popup, animated: true, completion: nil)
                    
                    
                    
                    UIView.animate(withDuration: 0.5, delay: 0,
                                   options: [.curveEaseInOut],
                                   animations: {
                                    self.signupView.alpha = 1
                                    self.oView.alpha = 0.75
                                    self.doneSignup.alpha = 1
                                    self.tos.alpha = 1
                    },
                                   completion: nil
                    )
                }
            }
        }
            
        
    }
    
    func signinUserWithExistingUsername(){
        
        let db = Firestore.firestore()
        
        let title = "ACCEPT NOTIFICATION FOR REWARDS"
        let message = "Please accept push notifications to receive  free points, new info and special discounts!"
        
        let popup = PopupDialog(title: title, message: message)//, image: image)
        
        let buttonTwo = DefaultButton(title: "OK", dismissOnTap: true) {
            //print("You canceled the car dialog.")
            
            OneSignal.promptForPushNotifications(userResponse: { accepted in
                // print("User accepted notifications: \(accepted)")
                
                //let name = pls?.name
                let username = self.username //username
                
                //self.username = username!
                
                OneSignal.setEmail(self.userEmail);
                let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
  
                var pushToken = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId
                //print("pushToken = \(pushToken)")
                
                
                if(OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId == nil){
                    pushToken = " "
                }else{
                    pushToken = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId
                }
                
                db.collection("users").document(self.username).updateData([
                    "pushToken": pushToken
                    ])
                
                UIView.animate(withDuration: 0.5, delay: 0,
                               options: [.curveEaseInOut],
                               animations: {
                                self.oView.alpha = 0
                                self.signupView.alpha = 0
                                self.doneSignup.alpha = 0
                                self.tos.alpha = 0
                                
                },
                               completion: {finished in self.disappear()}
                )
                
            })
        }
        popup.addButtons([buttonTwo])
        self.present(popup, animated: true, completion: nil)
    }
    
    @IBAction func signUP(_ sender: Any) {
        
        if(usernameField.text == "" || nameField.text == ""){
            return;
        }
        //let usernameEntered = usernameField.text!
        var usernameEntered = usernameField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        
        let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        if usernameEntered.rangeOfCharacter(from: characterset.inverted) != nil {
            print("string contains special characters")
            let alertController = UIAlertController(title: "Username Invalid", message: "Please choose a username with only alphabetic characters. I'm sorry :(", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
            {
                (result : UIAlertAction) -> Void in
                //print("You pressed OK")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            //print ("has whitespace")
            return;
        }
        
//        if usernameEntered.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
//
//            print("string contains special characters")
//
//        }
//
        let whiteSpace = " "
        if (usernameEntered.contains(" ") == true) {
            let alertController = UIAlertController(title: "Username Invalid", message: "Please choose a username without spaces.", preferredStyle: UIAlertControllerStyle.alert)
            
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
            {
                (result : UIAlertAction) -> Void in
                //print("You pressed OK")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            //print ("has whitespace")
            return;
        } else {
            //print("no whitespace")
        }
        
        let db = Firestore.firestore()

        // Create a reference to the cities collection
        let citiesRef = db.collection("users")
        
        // Create a query against the collection.
        let query = citiesRef.whereField("username", isEqualTo: self.usernameField.text).getDocuments(){ (querySnapshot, err) in
        if let err = err {
            //print("Error getting documents: \(err)")
        } else {
            //add user
            if(querySnapshot?.count == 0){
                // handle user and error as necessary
                //print("this just happened")
                
                let email = self.userEmail
                let name = self.nameField.text
                let username = usernameEntered //username
                
                self.username = username
                
                OneSignal.setEmail(self.userEmail);
                let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                
                let hasPrompted = status.permissionStatus.hasPrompted
                //print("hasPrompted = \(hasPrompted)")
                let userStatus = status.permissionStatus.status
                //print("userStatus = \(userStatus)")
                
                let isSubscribed = status.subscriptionStatus.subscribed
                //print("isSubscribed = \(isSubscribed)")
                let userSubscriptionSetting = status.subscriptionStatus.userSubscriptionSetting
                //print("userSubscriptionSetting = \(userSubscriptionSetting)")
                let userID = status.subscriptionStatus.userId
                //print("userID = \(userID)")
                var pushToken = OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId
                //print("pushToken = \(pushToken)")
                
                if(OneSignal.getPermissionSubscriptionState().subscriptionStatus.userId == nil){
                    pushToken = " "
                }
                // Add a new document with a generated id.
                db.collection("users").document(username).setData([
                    "name": name,
                    "touched": ["Japan"],
                    "username": username,
                    "email": email,
                    "pushToken": pushToken
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
                                self.tos.alpha = 0
                                
                },
                               completion: {finished in self.disappear()}
                )

            }else{
                // username taken
                //print("username taken")
                let alertController = UIAlertController(title: "Username Taken", message: "Great minds think alike. Sorry, that username is already taken 😔.", preferredStyle: UIAlertControllerStyle.alert)
                
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
                {
                    (result : UIAlertAction) -> Void in
                    //print("You pressed OK")
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
        self.tos.isHidden = true
        self.signUpTapped.isHidden = true;
        
        self.nameField.resignFirstResponder()
        self.usernameField.resignFirstResponder()
        
        self.view.sendSubview(toBack: self.signUpTapped)
        self.view.sendSubview(toBack: self.oView)
        self.view.sendSubview(toBack: self.signupView)
        self.view.sendSubview(toBack: self.doneSignup)
        self.view.sendSubview(toBack: self.tos)
        
        UIApplication.shared.keyWindow!.sendSubview(toBack: self.architectView)
        self.view.sendSubview(toBack: self.architectView)
    }
    
    
    func loadThemRests(){
        //self.restaurants = []
        let db = Firestore.firestore()

        db.collection("restaurants").addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                //print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //print("\(document.documentID) => \(document.data())")
                    print(document.data())
                    var pls = Restaurant(dictionary: document.data())
                    if(pls != nil){
//                        if objarray.contains(where: { name in name.id == 1 }) {
//                            print("1 exists in the array")
//                        } else {
//                            print("1 does not exists in the array")
//                        }
                        //if(!(self.restIDs.contains((pls?.id)!))){
                            
                            //self.restaurants.remove(at: <#T##Int#>)
                            self.restaurants = self.restaurants.filter {$0.id != pls?.id}
                            self.restaurants.append(pls!)
                            print(pls!)
                            self.restIDs.append((pls?.id)!)
                        //}
                        DispatchQueue.main.async {
                            self.restTable.reloadData()
                        }

                    }else{
                        //print("aiyah Database")
                    }
                    ////print(pls!)
                    //print("Current data: \(document.data())")
                    
                    //print(self.restaurants)
                    
                    //#warning - make sure the listener is being removed correctly here
                    //print("got here")
                }
                
            }
        }
    }
    
    
    @IBAction func seeOrders(_ sender: Any) {
        
        
    }
    
    @IBAction func contact(_ sender: Any) {
        UIApplication.shared.openURL(NSURL(string: "http://www.getonmealplan.com/contact.html")! as URL)
        
    }
    @IBAction func tos(_ sender: Any) {
        
        
        UIApplication.shared.openURL(NSURL(string: "http://www.getonmealplan.com/about.html")! as URL)

        //link to website here
    }
    
    func loadThemPoints(){
        let db = Firestore.firestore()
        let meReference = db.collection("users").document(self.username)
        
        meReference.addSnapshotListener { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                //print("Document data: \(dataDescription)")
                
                
                for r in self.restaurants{
                    if(document.data()![r.id] != nil){
                        var obj: Dictionary<String, Any> = [:]
                        //obj.append(document.data()!["tru0000001"] as! [String : Any])
                        
                        obj = document.data()![r.id] as! Dictionary<String, Any>
                        //print(obj["points"])
                        //print(document.data()![r.id])
                        var tString = obj["points"]!
                        self.pointDict[r.id] = (tString as! Int)
                        //totalData = (jsonDict["totalfup"] as! NSString).doubleValue
                        DispatchQueue.main.async(execute: {() -> Void in
                            
                            self.restTable.reloadData();
                            
                        })

                    }
                }
                
            } else {
                //print("Document does not exist")
            }
        }
        
        
    }
    
    //this is where i am doing the tab shit
    
//    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
//        let defaults = UserDefaults.standard
//
//        let uName = defaults.string(forKey: "username")
//        if(uName == nil){
//            return false
//        }
//        return true;
//    }
//
//    // UITabBarControllerDelegate
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        print("Selected view controller")
//    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.delegate = self
        
        let betterTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        self.FSUButton.addGestureRecognizer(betterTap)
        
        loadThemRests()

        let defaults = UserDefaults.standard
        let uName = defaults.string(forKey: "username")
        if(uName == nil){
            
            
            self.architectView.frame = CGRect(x: 0, y: self.view.bounds.size.height - 49, width: self.view.frame.size.width, height: 49)
            self.view.addSubview(self.architectView)
            //architectView.backgroundColor = UIColor.cyan
            UIApplication.shared.keyWindow!.addSubview(self.architectView)

            UIApplication.shared.keyWindow!.bringSubview(toFront: self.architectView)
            self.view.bringSubview(toFront: self.architectView)

            architectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tabTap(tapGesture:))))
        }
        //try! Auth.auth().signOut()
        ImageCache.default.maxCachePeriodInSecond = 60 * 60 * 24 * 3
        ImageCache.default.maxDiskCacheSize = 1000 * 1024 * 1024
        
        self.restTable.dataSource = self;
        self.restTable.delegate = self;
        self.restTable.tableFooterView = UIView(frame: CGRect.zero)
        
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if launchedBefore  {
            //print("Not first launch.")

//            bigBang()
            
            //print("git here")
            
        } else {
            //print("First launch, setting UserDefault.")
            try! Auth.auth().signOut()
            let intro : OnBoardingPager = self.storyboard?.instantiateViewController(withIdentifier: "obp") as! OnBoardingPager
            self.present(intro, animated: false, completion: nil)
            
            
        }
        
        
        
        if Auth.auth().currentUser != nil {
            //user is signed in
            
            self.userEmail = (Auth.auth().currentUser?.email)!
            let defaults = UserDefaults.standard
            let uName = defaults.string(forKey: "username")
            
//            let betterTap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
//            self.FSUButton.addGestureRecognizer(betterTap)

            if(uName != nil){
                self.username = uName!
                loadThemPoints()
                //let tap = UITapGestureRecognizer(target: self, action: Selector("FSU"))
                
            }else{
                // nothing happens and signup button is still visible BUT user is authenticated

            }
            
            
        }

       // print(launchedBefore)

    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        let defaults = UserDefaults.standard
        let uName = defaults.string(forKey: "username")
        
        if(self.username != nil && self.username != ""){

            print("bigButtonTapped")
            let fsuView : FSUViewController = self.storyboard?.instantiateViewController(withIdentifier: "fsuVC") as! FSUViewController
            fsuView.navigationController?.setNavigationBarHidden(true, animated: false)

            
            self.present(fsuView, animated: true, completion: nil)
        }
    }
    
    func bigBang(){
        let db = Firestore.firestore()
        
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
            
            if(uName != nil){
                self.username = uName!
                let docRef = db.collection("users").document(uName!)
                
                docRef.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                        //print("Document data: \(dataDescription)")
                        //self.username = document["username"] as! String
                        //print("user signed in \(self.username)")
                        
                    } else {
                        //print("Document does not exist")
                    }
                }
                
                loadThemPoints()
            }else{
                usernameField.setBottomBorder()
                nameField.setBottomBorder()
                
                self.signupView.clipsToBounds = true
                self.signupView.layer.cornerRadius = 30
                self.signupView.isHidden = false;
                self.oView.isHidden = false;
                self.doneSignup.isHidden = false;
                self.tos.isHidden = false
                
                self.signupView.alpha = 0
                self.oView.alpha = 0
                self.doneSignup.alpha = 0
                self.tos.alpha = 0
                
                self.view.bringSubview(toFront: self.oView)
                self.view.bringSubview(toFront: self.signupView)
                self.view.bringSubview(toFront: self.doneSignup)
                self.view.bringSubview(toFront: self.tos)
                
                let title = "ACCEPT NOTIFICATION FOR REWARDS"
                let message = "Please accept push notifications to receive  free points, new info and special discounts!"
                
                let popup = PopupDialog(title: title, message: message)//, image: image)
                
                let buttonTwo = DefaultButton(title: "OK", dismissOnTap: true) {
                    //print("You canceled the car dialog.")
                    
                    OneSignal.promptForPushNotifications(userResponse: { accepted in
                        // print("User accepted notifications: \(accepted)")
                    })
                }
                
                popup.addButtons([buttonTwo])
                self.present(popup, animated: true, completion: nil)
                
                
                
                UIView.animate(withDuration: 0.5, delay: 0,
                               options: [.curveEaseInOut],
                               animations: {
                                self.signupView.alpha = 1
                                self.oView.alpha = 0.75
                                self.doneSignup.alpha = 1
                                self.tos.alpha = 1
                },
                               completion: nil
                )
            
            }
            
        } else {
            // No user is signed in.
            // ...
            let authUI = FUIAuth.defaultAuthUI()
            // You need to adopt a FUIAuthDelegate protocol to receive callback
            authUI?.delegate = self as? FUIAuthDelegate
            let providers: [FUIAuthProvider] = [
                FUIGoogleAuth(),
                //FUIPhoneAuth(authUI:FUIAuth.defaultAuthUI()!),
                //FUIFacebookAuth(),
                
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
        
        
    }
    
}

extension FUIAuthBaseViewController{
    open override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.leftBarButtonItem = nil
    }
}


extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
