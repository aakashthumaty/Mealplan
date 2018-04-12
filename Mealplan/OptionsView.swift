//
//  OptionsView.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 4/3/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import UIKit

class OptionsView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    var addon: Addon!
    var optionsArray: Array<String> = []
    var priceArray: Array<Float> = []

    var selection: String = ""
    var price: Float = 0
    
    @IBOutlet weak var optionsTable: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let oA = self.addon.options.components(separatedBy: ", ")
        var pA: Array<Float> = []
        for option in oA{
            pA.append(self.addon.price[option]!)
        }

        self.optionsArray = oA
        self.priceArray = pA
        print("this is mprinting shit")
        return optionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell",
                                                 for: indexPath) as! optionTableViewCell

        cell.optionLabel.text = optionsArray[indexPath.row]
        cell.optionPrice.text = "$\(priceArray[indexPath.row])"
        print("we are here \(cell.optionPrice.text)")
        if(self.selection == cell.optionLabel.text){
            cell.selectionIndicator.setImage(UIImage(named:"selectedBoxRed.png"), for: .normal)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1
        
        guard let cell = tableView.cellForRow(at: indexPath) as? optionTableViewCell else { return }
        
        if(self.selection == cell.optionLabel.text){
            cell.selectionIndicator.setImage(UIImage(named:"unselectedBox.png"), for: .normal)
            
            self.selection = ""
            self.price = 0.0
            return
        }else if(self.selection == ""){
        
            cell.selectionIndicator.setImage(UIImage(named:"selectedBoxRed.png"), for: .normal)

            self.selection = cell.optionLabel.text!
            self.price = priceArray[indexPath.row]
        }else{
            self.selection = cell.optionLabel.text!
            self.price = priceArray[indexPath.row]
            if let visibleIndexPaths = tableView.indexPathsForVisibleRows?.index(of: indexPath as IndexPath) {
                if visibleIndexPaths != NSNotFound {
                    tableView.reloadRows(at: [indexPath], with: .fade)
                }
            }
        }
        
        
    }
    
    

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

class optionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var selectionIndicator: UIButton!
    @IBOutlet weak var optionPrice: UILabel!
    
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        //self.selectionIndicator.backgroundColor = UIColor.red

    }
    
    func populate(item: String, selected: Bool) {
 
    }

    
}
