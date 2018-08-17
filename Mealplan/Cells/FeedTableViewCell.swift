//
//  FeedTableViewCell.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 4/11/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase
import OneSignal

class FeedTableViewCell: UITableViewCell {
    
    
    var post: Post!
    
    @IBOutlet weak var lickIcon: UIImageView!
    @IBOutlet weak var rating: UIImageView!
    
    
    
    @IBOutlet weak var gagButt: UIButton!
    @IBOutlet weak var lickButt: UIButton!
    
    @IBOutlet weak var caption: UILabel!
    @IBOutlet weak var gagCount: UILabel!
    @IBOutlet weak var gagIcon: UIImageView!
    @IBOutlet weak var lickCount: UILabel!
    @IBOutlet weak var imageMain: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var atWithLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    
    @IBAction func lick(_ sender: Any) {
        self.lickButt.setImage(UIImage(named:"300coneColor.png"), for: .normal)
        self.lickButt.imageView?.image = UIImage(named:"500sad.png")
        var oldPopulation = 0
        let db = Firestore.firestore()
        let sfReference = db.collection("posts").document(self.post.id)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            let defaults = UserDefaults.standard
            var thisUser = ""
            if(defaults.string(forKey: "username") != nil){
                
                
                thisUser = defaults.string(forKey: "username")!
                //self.postsTable.reloadData()
            }
            
            oldPopulation = (sfDocument.data()?["licks"] as? Int)!
            var oldLickers = [""]
            oldLickers = (sfDocument.data()?["lickers"] as? Array)!
            
            
            transaction.updateData(["licks": oldPopulation + 1], forDocument: sfReference)
            transaction.updateData(["lickers": oldLickers.append(thisUser)], forDocument: sfReference)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
                //self.lickCount.text = ("\(oldPopulation + 1) licks")
                if((oldPopulation%15) == 0){
                    
                    let fReference = db.collection("users").document(self.post.user)
                    
                    var temp: OurUser!
                    fReference.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                            //print("Document data: \(dataDescription)")
                            temp = OurUser(dictionary: document.data()!)
                            
                            
                            let message = "Your post in the food feed has \(oldPopulation + 1) licks!"
                            let notificationContent = [
                                "include_player_ids": [temp.pushToken],
                                "contents": ["en": message], // Required unless "content_available": true or "template_id" is set
                                "headings": ["en": "Your Post Got Licked"],
                                //"subtitle": ["en": "An English Subtitle"],
                                // If want to open a url with in-app browser
                                //"url": "https://google.com",
                                // If you want to deep link and pass a URL to your webview, use "data" parameter and use the key in the AppDelegate's notificationOpenedBlock
                                //"data": ["OpenURL": "https://imgur.com"],
                                //"ios_attachments": ["id" : "https://cdn.pixabay.com/photo/2017/01/16/15/17/hot-air-balloons-1984308_1280.jpg"],
                                "ios_badgeType": "Increase",
                                "ios_badgeCount": 1
                                ] as [String : Any]
                            
                            OneSignal.postNotification(notificationContent)
                            
                        } else {
                            //print("Document does not exist")
                        }
                    }
                }
            }
        }
        
    }
    
    
    @IBAction func gag(_ sender: Any) {
        
        self.gagButt.setImage(UIImage(named:"300broccoliColor.png"), for: .normal)
        var oldPopulation = 0
        let db = Firestore.firestore()
        let sfReference = db.collection("posts").document(self.post.id)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let sfDocument: DocumentSnapshot
            do {
                try sfDocument = transaction.getDocument(sfReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            oldPopulation = (sfDocument.data()?["gags"] as? Int)!
            
            transaction.updateData(["gags": oldPopulation + 1], forDocument: sfReference)
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
                //self.lickCount.text = ("\(oldPopulation + 1) gags")
                
                if((oldPopulation%15) == 0){
                    
                    let fReference = db.collection("users").document(self.post.user)
                    
                    var temp: OurUser!
                    fReference.getDocument { (document, error) in
                        if let document = document, document.exists {
                            let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                            //print("Document data: \(dataDescription)")
                            temp = OurUser(dictionary: document.data()!)
                            
                            
                            let message = "Your post in the food feed has \(oldPopulation + 1) gags!"
                            let notificationContent = [
                                "include_player_ids": [temp.pushToken],
                                "contents": ["en": message], // Required unless "content_available": true or "template_id" is set
                                "headings": ["en": "Your post Got Gagged"],
                                //"subtitle": ["en": "An English Subtitle"],
                                // If want to open a url with in-app browser
                                //"url": "https://google.com",
                                // If you want to deep link and pass a URL to your webview, use "data" parameter and use the key in the AppDelegate's notificationOpenedBlock
                                //"data": ["OpenURL": "https://imgur.com"],
                                //"ios_attachments": ["id" : "https://cdn.pixabay.com/photo/2017/01/16/15/17/hot-air-balloons-1984308_1280.jpg"],
                                "ios_badgeType": "Increase",
                                "ios_badgeCount": 1
                                ] as [String : Any]
                            
                            OneSignal.postNotification(notificationContent)
                            
                        } else {
                            //print("Document does not exist")
                        }
                    }
                }
            }
        }
        
        
    }
    
    
    func populate(postGiven: Post) {
        self.lickButt.setImage(UIImage(named:"300coneBlue.png"), for: .normal)
        self.gagButt.setImage(UIImage(named:"300broccoliBlue.png"), for: .normal)

        self.post = postGiven
        caption.text = postGiven.caption
        gagCount.text = "\(postGiven.gags) gags"
        lickCount.text = "\(postGiven.licks) licks"
        username.text = postGiven.user
        if(postGiven.friends != ""){
            atWithLabel.text = "@ \(postGiven.restaurant) w \(postGiven.friends)"
        }else{
            atWithLabel.text = "@ \(postGiven.restaurant)"
        }
        caption.text = postGiven.caption
        
        imageMain.kf.indicatorType = .activity
        let imgurl = URL(string: postGiven.image)
        imageMain.kf.setImage(with: imgurl)
        
//        let url = URL(string: postGiven.image)
//        let data = try? Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
//        imageMain.image = UIImage(data: data!)
        
        if(postGiven.rating == "aight"){
            rating.image = UIImage(named:"500eh.png")
        }
        else if(postGiven.rating == "bad"){
            rating.image = UIImage(named:"500sad.png")
        }else{
            rating.image = UIImage(named:"500heart.png")
        }
        

    }

}

//extension UIImageView {
//    public func imageFromUrl(urlString: String) {
//        if let url = NSURL(string: urlString) {
//            let request = NSURLRequest(url: url as URL)
//            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.mainQueue) {
//                (response: URLResponse?, data: NSData?, error: NSError?) -> Void in
//                if let imageData = data as NSData? {
//                    self.image = UIImage(data: imageData)
//                }
//            }
//        }
//    }
//}

