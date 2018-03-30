//
//  ItemDetailViewController.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 3/28/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var item: MenuItem!
    var addonList: Array<Addon> = []
    var catDict: Dictionary<String, [MenuItem]> = [:]
    var addonListCategories: Array<AddonListCategory> = []
    var addonDict: Dictionary<String, [Addon]> = [:]

    @IBOutlet weak var addonTableView: UITableView!
    @IBOutlet weak var addonName: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.tabBarController?.tabBar.isHidden = true;
        print("please be the item: \(item)")
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(self.addonList.count != 0){
            return self.addonListCategories.count
        }else{
            return 1
        }

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 100;//Choose your custom row height
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(self.addonListCategories.count != 0){
            print("addonlistcategories count \(addonListCategories) this is section value \(section)")
            let key = self.addonListCategories[section]
            print(addonDict[key.name]?.count)
            return (addonDict[key.name]?.count)!
        }else{
            return 1
        }
 

    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addonCell",
                                                 for: indexPath) as! addonTableViewCell

        if(item.addons.count > 0){
            
            print("index path is \(indexPath.row)")
            var keyForItemCat = self.item.addons["list"]
            
            let key = self.addonListCategories[indexPath.section].name
            cell.populate(item: addonDict[key]![indexPath.row])
            //cell.populate(item: self.catDict[keyForItemCat]![indexPath.row])
            //cell.populate(item: self.items[indexPath.row])
        }
        print("populating cell for item")
        
        return cell
    }
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? ItemDetailViewController{ //, let meal = sourceViewController.meal {
            
            // Add a new meal.
            //let newIndexPath = IndexPath(row: meals.count, section: 0)
            
            //meals.append(meal)
            //tableView.insertRows(at: [newIndexPath], with: .automatic)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
//        guard let restaurantDetailViewController = segue.destination as? RestaurantDetailViewController else {
//            fatalError("Unexpected destination: \(segue.destination)")
//        }
        //restaurantDetailViewController.restaurant = selectedRest
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addonTableView.dataSource = self;
        self.addonTableView.delegate = self;
        self.addonTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        //var sect = self.addonList[section]
        for cat in self.item.addons["list"]!{
            self.addonListCategories.append(AddonListCategory(dictionary: cat as! [String : Any])!)
            print(self.addonListCategories)
        }
        
        for item in self.addonListCategories{
            // number of times to loop: self.item.addons[item.name]?.count
            //var numOfTimesToLoop = self.item.addons[item.name]?.count
            print("got to this place\(item.name)")
            var i = 0
            while i < (self.item.addons[item.name]?.count)!{
                self.addonList.append(Addon(dictionary: self.item.addons[item.name]![i] as! [String : Any])!)
                
                var pls = Addon(dictionary: self.item.addons[item.name]![i] as! [String : Any])!
                if(self.addonDict.keys.contains(item.name)){
                    var tempArr = self.addonDict[item.name]
                    tempArr?.append(pls)
                    self.addonDict.updateValue(tempArr!, forKey: item.name)
                }else{
                    self.addonDict[item.name] = [pls]
                }
                

                print(i)
                print(self.addonList)
                i += 1
                print("got here \(i)")

            }
        }
//        self.addonList = item.addons["list"]! as! Array<Addon>
//
//        for thing in item.addons{
//            var pls = Addon(dictionary: thing as! [String : Any])
//            print("got here with the addon \(pls)")
//        }
        // Do any additional setup after loading the view.
        
        self.addonTableView.reloadData()
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

}

class addonTableViewCell: UITableViewCell {
    
    @IBOutlet weak var addonLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func populate(item: Addon) {
        print("where my cells at \(item)")
        self.addonLabel.text = item.name
//        titleLabel.text = item.name
//        cellView.layer.cornerRadius = 15
//        descriptionLabel.text = item.description
//        descriptionLabel.isScrollEnabled = false
        
    }

}
