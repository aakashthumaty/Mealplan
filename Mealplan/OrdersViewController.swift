//
//  OrdersViewController.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 5/2/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import MessageUI

class OrdersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MFMessageComposeViewControllerDelegate {
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
        
    }
    var orders: [Order] = []
    var username = ""
    var orderIDs: [String] = []

    @IBOutlet weak var ordersTableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return orders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       //
        let cell = tableView.dequeueReusableCell(withIdentifier: "oldOrderCell",
                                                 for: indexPath) as! OrdersTableViewCell
        
        let o = self.orders[indexPath.row]
        //print(p)
        
        cell.populate(orderGiven: o)
        //print(cell.frame.height)
        //print("populating cell")
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        self.username = defaults.string(forKey: "username")!
        
        self.ordersTableView.delegate = self
        self.ordersTableView.dataSource = self
        
        let db = Firestore.firestore()
//        let userPostsRef = db.collection("users").document(self.username).collection("posts")

        db.collection("users").document(self.username).collection("orders").order(by: "time").addSnapshotListener { querySnapshot, error in
            guard let documents = querySnapshot else {
                //print("Error fetching documents: \(error!)")
                return
            }
            
            //                let cities = documents.map { $0["name"]! }
            //                print("Current cities in CA: \(cities)")
            for document in querySnapshot!.documents {
                //print("\(document.documentID) => \(document.data())")
                
                var pls = Order(dictionary: document.data())
                if(!self.orderIDs.contains(document.documentID)){
                    if(pls != nil ){
                        self.orders.insert(pls!, at: 0)
                        self.orderIDs.append(document.documentID)
                    }else{
                        //print("aiyah Database")
                    }
                }
                
                //print("got here")
            }
            self.ordersTableView.reloadData()
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    @IBAction func textUs(_ sender: Any) {
        
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController()
            controller.body = ""
            controller.recipients = ["9195900536"]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
    }
}

class OrdersTableViewCell: UITableViewCell {
    
    @IBOutlet weak var orderItemTitle: UILabel!
    @IBOutlet weak var orderItemDescription: UILabel!
    @IBOutlet weak var orderItemCost: UILabel!
    
    var order: Order!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func populate(orderGiven: Order) {
        
        self.order = orderGiven
        orderItemTitle.text = orderGiven.restaurant
        orderItemCost.text = "$" + String(describing: orderGiven.fullPrice.rounded(toPlaces: 2)) //(orderGiven.fullPrice as! String)
        var wholeOrder: String = ""
        
        for i in orderGiven.orderItems{
            wholeOrder.append(i["name"] as! String)
            wholeOrder.append(":\n")
            for (index, addon) in (i["addons"] as! [String]).enumerated() {
                wholeOrder += addon
                if(index < (i["addons"] as! [String]).count - 1) {
                    wholeOrder += "\n"
                }
            }
        }
        orderItemDescription.text = wholeOrder

        
    }
    
}
