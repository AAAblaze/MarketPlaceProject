//
//  CategroyCollectionViewCell.swift
//  MarketPlaceProject
//
//  Created by RainMan on 1/20/20.
//  Copyright © 2020 RainMan. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    
    func generateCell(_ category : Category){
        nameLabel.text = category.name
        imageView.image = category.image
    }
    
    
}
