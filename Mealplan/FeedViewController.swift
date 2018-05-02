//
//  FeedViewController.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 4/10/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit
import Fusuma
import Firebase
//import Sharaku



class FeedViewController: UIViewController, FusumaDelegate, FilterImageViewControllerDelegate, UITableViewDataSource, UITableViewDelegate  {
    
    
    @IBOutlet weak var postsTable: UITableView!
    
    var username: String = ""
    var throwUpFilters: Bool = false
    var throwUpPost: Bool = false
    var image = UIImage()
    var imgURL: String = ""
    var posts: [Post] = []
    
    
    var postIDS: [String] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(throwUpFilters == true){
            throwUpFilters = false
            
                            let imgViewController = FilterImageViewController(image:image)
                            imgViewController.delegate = self
                            self.present(imgViewController, animated: false, completion: nil)
                        imgViewController.navigationController?.setNavigationBarHidden(false, animated: false)
        }else if (throwUpPost == true){
            throwUpPost = false
            
            let makePost : NewPostViewController = self.storyboard?.instantiateViewController(withIdentifier: "npvc") as! NewPostViewController
            //makePost.navigationController?.setNavigationBarHidden(true, animated: false)
            makePost.img = image
//            sendFriend.rest = self.restaurant
//            sendFriend.userEmail = self.userEmail
//            sendFriend.username = self.username
            
            
            self.present(makePost, animated: true, completion: nil)
        }
        
    }
    
    func filterImageViewControllerImageDidFilter(image: UIImage) {
        //print("Img")
        throwUpPost = true
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("feed")
        // Data in memory
        //let imageData: NSData = UIImagePNGRepresentation(myImage)
        self.image = image
        let data: Data = UIImagePNGRepresentation(image)!
        let imageData: Data = UIImageJPEGRepresentation(image, 0.5)!

        // Create a reference to the file you want to upload
        let db = Firestore.firestore()

        let riversRef = storageRef.child("feed/\(self.username)\(FieldValue.serverTimestamp().description)")
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = riversRef.putData(imageData, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type, and download URL.
            let downloadURL = metadata.downloadURL
            self.imgURL = (metadata.downloadURL()?.absoluteString)!
            //print(self.imgURL)
        }
        

    }
    
    func filterImageViewControllerDidCancel() {
        //print("Img")

    }
    
    func fusumaImageSelected(_ image: UIImage, source: FusumaMode) {
        //print("Img")
        self.image = image
        throwUpFilters = true


    }
    
    func fusumaMultipleImageSelected(_ images: [UIImage], source: FusumaMode) {
        //print("multImg")

    }
    
    func fusumaVideoCompleted(withFileURL fileURL: URL) {
        //print("yuh")

    }
    
    func fusumaCameraRollUnauthorized() {
        //print("yuh")

    }
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        
        //print("gotback")
        let ts = FieldValue.serverTimestamp()
        let sourceViewController = sender.source as? NewPostViewController
        
        let db = Firestore.firestore()

        // Create a reference to the cities collection
        if(self.username != ""){
            
        
        let userPostsRef = db.collection("users").document(self.username).collection("posts")
        let postsRef = db.collection("posts")

        let caption = sourceViewController?.caption
        let friendsTagged = sourceViewController?.friendSelected.joined(separator: ", ")
        let restaurant = sourceViewController?.restaurantSelected
        let rating = sourceViewController?.rating
        let finalImage = self.imgURL
        // Add a new document with a generated id.
        userPostsRef.document().setData([
            "caption": caption,
            "friends": friendsTagged,
            "restaurant": restaurant,
            "rating": rating,
            "image": finalImage,
            "time": FieldValue.serverTimestamp()
            ])

        postsRef.document().setData([
            "user": username,
            "caption": caption,
            "friends": friendsTagged,
            "restaurant": restaurant,
            "rating": rating,
            "image": finalImage,
            "licks": 0,
            "gags": 0,
            "time": FieldValue.serverTimestamp()

            
            
            ])
//        let defaults = UserDefaults.standard
//        defaults.set(username, forKey: "username")

        }
    }
    

    @objc func maFoosMethod(){
        let fusuma = FusumaViewController()
        fusuma.delegate = self
        //fusuma.hasVideo = true //To allow for video capturing with .library and .camera available by default
        fusuma.cropHeightRatio = 0.7 // Height-to-width ratio. The default value is 1, which means a squared-size photo.
        fusuma.allowMultipleSelection = false // You can select multiple photos from the camera roll. The default value is false.
        fusumaCameraRollTitle = "Camera Roll"
        fusumaCameraTitle = "Photo" // Camera Title
        fusumaTintColor = UIColor.blue // tint color
        self.present(fusuma, animated: true, completion: nil)
        
    
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.postsTable.delegate = self
        self.postsTable.dataSource = self
        
        self.postsTable.rowHeight = UITableViewAutomaticDimension
        self.postsTable.estimatedRowHeight = 400
        
        let db = Firestore.firestore()
        
        db.collection("posts").order(by: "time").addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot else {
                    //print("Error fetching documents: \(error!)")
                    return
                }
            print("there was a change")
//                let cities = documents.map { $0["name"]! }
//                //print("Current cities in CA: \(cities)")
//            for document in querySnapshot!.documents {
//                //print("\(document.documentID) => \(document.data())")
//                
//                var pls = Post(dictionary: document.data())
//                if(!self.postIDS.contains(document.documentID)){
//                    if(pls != nil ){
//                        pls?.id = document.documentID
//                        self.posts.insert(pls!, at: 0)
//                        self.postIDS.append(document.documentID)
//                    }else{
//                        //print("aiyah Database")
//                    }
//                }
//                
//                //print("got here")
//            }
            
            documents.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    print("New city: \(diff.document.data())")
                    var pls = Post(dictionary: diff.document.data())
                    pls?.id = diff.document.documentID
                    if(pls != nil){
                    self.posts.insert(pls!, at: 0)
                    }

                }
                if (diff.type == .modified) {
                    print("Modified city: \(diff.document.data())")
                    
                    var pls = Post(dictionary: diff.document.data())
                    pls?.id = diff.document.documentID
                    
                    
                    if self.posts.contains(where: { p in p.id == diff.document.documentID }) {
                        print("1 exists in the array")
                    } else {
                        print("1 does not exists in the array")
                        if(pls != nil){
                            self.posts.insert(pls!, at: 0)
                        }
                    }
                    
                    
                    for p in self.posts{
                        if(p.id == diff.document.documentID){
                            var ind = self.posts.index(where: { (pos) -> Bool in
                                pos.id == diff.document.documentID
                            })
                            self.posts[ind!] = pls!
                        }
                    }
                    self.postsTable.reloadData()

                }
                if (diff.type == .removed) {
                    print("Removed city: \(diff.document.data())")
                    self.postsTable.reloadData()

                }
            }
            
            self.postsTable.reloadData()
        }

//        db.collection("posts").getDocuments() { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//                    //print("\(document.documentID) => \(document.data())")
//
//                    var pls = Post(dictionary: document.data())
//                    if(pls != nil){
//                        self.posts.append(pls!)
//
//                    }else{
//                        print("aiyah Database")
//                    }
//
//                    print("got here")
//                }
//                self.postsTable.reloadData()
//
//            }
//        }
//
        
//    self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        let defaults = UserDefaults.standard
        if(defaults.string(forKey: "username") != nil){
            
        
            self.username = defaults.string(forKey: "username")!
            self.postsTable.reloadData()
        }
        // Do any additional setup after loading the view.
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        return 430.0;//Choose your custom row height
//    }

    @IBAction func postButt(_ sender: Any) {
        maFoosMethod()

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(self.posts.count > 0){
            return self.posts.count
        }else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell",
                                                 for: indexPath) as! FeedTableViewCell
        
        let p = posts[indexPath.row]
        //print(p)

        cell.populate(postGiven: p)
        //print(cell.frame.height)
        //print("populating cell")
        return cell
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
