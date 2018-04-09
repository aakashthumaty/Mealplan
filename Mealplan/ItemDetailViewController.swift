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
    var addonListCategories: Array<AddonListCategory> = []
    var addonDict: Dictionary<String, [Addon]> = [:]
    
    var selections: Array<String> = []
    var nonOrderSelections: Array<String> = []
    
    var selectionPrice: Array<Float> = []
    var selectionName: String = ""
    var isFullItem: Bool = false
    
    @IBOutlet weak var commentsBox: UITextField!
    @IBOutlet weak var addonTableView: UITableView!
    @IBOutlet weak var addToCartButt: UIButton!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var itemDescription: UITextView!
    
    @IBOutlet weak var optionsView: OptionsView!
    @IBOutlet weak var opacityView: UIView!
    @IBOutlet weak var doneWOptions: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        
        self.itemLabel.text = self.item.name
        self.itemDescription.text = self.item.description
        
        self.optionsView.isHidden = true;
        self.opacityView.isHidden = true;
        self.doneWOptions.isHidden = true;
        
        self.doneWOptions.clipsToBounds = true
        self.doneWOptions.layer.cornerRadius = 15
        
        //self.optionsView.isFocused false;
        //print("please be the item: \(item)")
    }
    
    @IBAction func addToCart(_ sender: Any) {
        //print("please tell me you got here")
        self.selectionName = self.item.name
        self.isFullItem = true
        // add the "any extra notes text to the end of the selections array"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if(!item.hasaddons){
            return 0
        }
        if(self.addonList.count != 0){
            return self.addonListCategories.count
        }else{
            return 1
        }

    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
//    {
//        if(indexPath.row == 0){
//            return 200
//        }else{
//            return 0.0
//        }
//    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(!item.hasaddons){
            return 0
        }
        
        if(self.addonListCategories.count != 0){
            //print("addonlistcategories count \(addonListCategories) this is section value \(section)")
            let key = self.addonListCategories[section]
            //print(addonDict[key.name]?.count)
            return (addonDict[key.name]?.count)!
        }else{
            return 1
        }
 

    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "addonCell",
                                                 for: indexPath) as! addonTableViewCell

        if(item.addons.count > 0){
            
            //print("index path is \(indexPath.row)")
            var keyForItemCat = self.item.addons["list"]
            
            let key = self.addonListCategories[indexPath.section].name
            
            var addonOfChoice = addonDict[key]![indexPath.row]
            if(nonOrderSelections.contains(addonOfChoice.name)){
                cell.populate(item: addonOfChoice, selected:true)

            }else{
                cell.populate(item: addonOfChoice, selected:false)
            }

        }
        //print("populating cell for item")
        
        return cell
    }
    
//    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
//        if let sourceViewController = sender.source as? ItemDetailViewController{
//            
//            //, let meal = sourceViewController.meal {
//            
//            // Add a new meal.
//            //let newIndexPath = IndexPath(row: meals.count, section: 0)
//            
//            //meals.append(meal)
//            //tableView.insertRows(at: [newIndexPath], with: .automatic)
//        }
//    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1
        
        guard let cell = tableView.cellForRow(at: indexPath) as? addonTableViewCell else { return }
        
        let key = self.addonListCategories[indexPath.section].name
        var addonChosen = addonDict[key]![indexPath.row]

        //tableView.scrollToRow(at: indexPath, at: .top, animated: true)
        if(self.nonOrderSelections.contains(addonChosen.name)){
            
            var place = nonOrderSelections.index(of: addonChosen.name)
            if(addonChosen.multOptions){
                self.selections.remove(at: place!)
                
                self.nonOrderSelections.remove(at: place!)
                //self.selections.remove(at: place!)
                self.selectionPrice.remove(at: place!)
            }else{
                self.selections.remove(at: place!)
                self.selectionPrice.remove(at: place!)
                self.nonOrderSelections.remove(at: place!)


            }
            self.addonTableView.reloadData()
            return;
        }
        
        if(addonChosen.multOptions == true){
            
            print("lets do this")
            showAddonOptions(for: addonChosen, iPath: indexPath)
            
        }else{
            selections.append(addonChosen.name)
            nonOrderSelections.append(addonChosen.name)
            selectionPrice.append(addonChosen.price[addonChosen.options]!)
            
            if let visibleIndexPaths = tableView.indexPathsForVisibleRows?.index(of: indexPath as IndexPath) {
                if visibleIndexPaths != NSNotFound {
                    tableView.reloadRows(at: [indexPath], with: .fade)
                }
            }

        }
    }
    
    func showAddonOptions(for addonChosen: Addon, iPath: IndexPath){
        //in this method instantiate the options view
        self.optionsView.addon = addonChosen
        self.optionsView.optionsTable.delegate = self.optionsView
        self.optionsView.optionsTable.dataSource = self.optionsView
        
        self.optionsView.optionsTable.rowHeight = UITableViewAutomaticDimension
        self.optionsView.optionsTable.estimatedRowHeight = 60
        
        self.optionsView.clipsToBounds = true
        self.optionsView.layer.cornerRadius = 30
        self.optionsView.isHidden = false;
        self.opacityView.isHidden = false;
        self.doneWOptions.isHidden = false;
        
        self.optionsView.alpha = 0
        self.opacityView.alpha = 0
        self.doneWOptions.alpha = 0
        
        self.view.bringSubview(toFront: self.opacityView)
        self.view.bringSubview(toFront: self.optionsView)
        self.view.bringSubview(toFront: self.doneWOptions)

        UIView.animate(withDuration: 0.5, delay: 0,
                       options: [.curveEaseInOut],
                       animations: {
            self.optionsView.alpha = 1
            self.opacityView.alpha = 0.75
            self.doneWOptions.alpha = 1
            self.optionsView.optionsTable.reloadData()

        },
                       completion: nil
        )
        
        //self.optionsView.isFocused = true;

        // here you have to append addon name plus their options and add the total to the price
        selections.append(addonChosen.name)
        nonOrderSelections.append(addonChosen.name)
        //this reloads the addons cell
        if let visibleIndexPaths = self.addonTableView.indexPathsForVisibleRows?.index(of: iPath as IndexPath) {
            if visibleIndexPaths != NSNotFound {
                self.addonTableView.reloadRows(at: [iPath], with: .fade)
            }
        }
        
    }
    
    
    @IBAction func clearOptions(_ sender: Any) {
        
        //get the option selected here

        if(self.optionsView.selection == ""){
            //if they dont choose anything remove the addon because the addon was added to the selections array
            selections.removeLast()
            nonOrderSelections.removeLast()
            print(selections)
            print("poopin0")
            self.addonTableView.reloadData()
        }else{
            selections[selections.count-1].append(":\(self.optionsView.selection)")
            selectionPrice.append(self.optionsView.price)
            print(selections)
            print("poopin1")
        }
        self.optionsView.selection = ""
        UIView.animate(withDuration: 0.5, delay: 0,
                       options: [.curveEaseInOut],
                       animations: {
                        self.optionsView.alpha = 0
                        self.opacityView.alpha = 0
                        self.doneWOptions.alpha = 0
                        
        },
                       completion: {finished in self.disappear()}
        )
        
    }
    
    func disappear(){
        self.optionsView.isHidden = true;
        self.opacityView.isHidden = true;
        self.doneWOptions.isHidden = true;
        
        self.view.sendSubview(toBack: self.opacityView)
        self.view.sendSubview(toBack: self.optionsView)
        self.view.sendSubview(toBack: self.doneWOptions)
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
        self.addonTableView.tableFooterView = self.footerView
        
        self.addonTableView.estimatedRowHeight = 60
        self.addonTableView.rowHeight = UITableViewAutomaticDimension
        //var sect = self.addonList[section]
        
        if(self.item.hasaddons){
            for cat in self.item.addons["list"]!{
               
                 self.addonListCategories.append(AddonListCategory(dictionary: cat as! [String : Any])!)
                
                //print(self.addonListCategories)
            }
            
            for item in self.addonListCategories{
                // number of times to loop: self.item.addons[item.name]?.count
                //var numOfTimesToLoop = self.item.addons[item.name]?.count
                //print("got to this place\(item.name)")
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
                    i += 1

                    //print(i)
                    //print(self.addonList)
                    //print("got here \(i)")

                }
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
    @IBOutlet weak var selectionIndicator: UIButton!
    @IBOutlet weak var addonPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //self.selectionIndicator.backgroundColor = UIColor.green

        // Configure the view for the selected state
    }
    
    func populate(item: Addon, selected: Bool) {
        //print("where my cells at \(item)")
        self.addonLabel.text = item.name
        //item.options[]
        var p = item.options.components(separatedBy: ", ")[0]
        //print("we are on  \(p) the edge \(item.price[p])")
        var pr = item.price[p]
        if let pri = pr {
            // a is an Int
            self.addonPrice.text = "$ \(pri)"

        }
        
        if(selected){
            self.selectionIndicator.backgroundColor = UIColor.green
        }else{
            self.selectionIndicator.backgroundColor = UIColor.red
        }
        
//        titleLabel.text = item.name
//        cellView.layer.cornerRadius = 15
//        descriptionLabel.text = item.description
//        descriptionLabel.isScrollEnabled = false
        
    }

}
