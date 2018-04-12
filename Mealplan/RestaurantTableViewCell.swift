//
//  RestaurantTableViewCell.swift
//  Mealplan
//
//  Created by Aakash Thumaty on 3/25/18.
//  Copyright © 2018 Aakash Thumaty. All rights reserved.
//

import Foundation
import UIKit
import Kingfisher

class RestaurantTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var rest: Restaurant!

    @IBOutlet weak var giftCount: UILabel!
    
    @IBOutlet weak var restCollectionView: UICollectionView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var discountLabel: UILabel!
    
    func populate(restaurant: Restaurant) {
        self.rest = restaurant
//        let flowLayout = UICollectionViewFlowLayout()
//        flowLayout.scrollDirection = UICollectionViewScrollDirection.horizontal
//        self.restCollectionView.collectionViewLayout = flowLayout
        titleLabel.text = restaurant.title
        cellView.layer.cornerRadius = 5
        let url = URL(string: restaurant.icon)
        //iconView.image = kf.setImage(with: url)
        iconView.kf.indicatorType = .activity
        iconView.kf.setImage(with: url)
        self.restCollectionView.reloadData()
        discountLabel.text = restaurant.discounts[0]
        discountLabel.textColor = UIColor(red: 0.18, green: 0.8, blue: 0.443, alpha:1.0)

        //rgb(46, 204, 113) green
     

       
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return rest.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "restCollectionCell", for: indexPath) as! restCollectionViewCell
        
        cell.displayContent(img: rest.images[indexPath.row] as! String)
        
        return cell
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

class restCollectionViewCell: UICollectionViewCell{
    @IBOutlet weak var cellImage: UIImageView!
    
    func displayContent(img: String){
        cellImage.kf.indicatorType = .activity
        let imgurl = URL(string: img)
        cellImage.kf.setImage(with: imgurl)
        
    }
    
}
