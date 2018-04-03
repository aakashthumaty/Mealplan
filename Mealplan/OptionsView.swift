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
    
    var selection: String = ""
    
    @IBOutlet weak var optionsTable: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let oA = self.addon.options.components(separatedBy: ", ")

        self.optionsArray = oA
        print("this is mprinting shit")
        return optionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "optionCell",
                                                 for: indexPath) as! optionTableViewCell

        cell.optionLabel.text = optionsArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 1
        
        guard let cell = tableView.cellForRow(at: indexPath) as? optionTableViewCell else { return }
        
        cell.selectionIndicator.backgroundColor = UIColor.green
        
        self.selection = cell.optionLabel.text!
        
        
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
    
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.selectionIndicator.backgroundColor = UIColor.red

    }
    
    func populate(item: String, selected: Bool) {
 
    }

    
}
