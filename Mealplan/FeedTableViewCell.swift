//
//  FeedTableViewCell.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 4/11/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit
import Kingfisher

class FeedTableViewCell: UITableViewCell {
    
    
    var post: Post!
    
    @IBOutlet weak var lickIcon: UIImageView!
    @IBOutlet weak var rating: UIImageView!
    
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
    
    func populate(postGiven: Post) {
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

