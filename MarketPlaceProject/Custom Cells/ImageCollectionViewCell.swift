//
//  ImageCollectionViewCell.swift
//  MarketPlaceProject
//
//  Created by RainMan on 1/30/20.
//  Copyright © 2020 RainMan. All rights reserved.
//

import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    func setupImageWith(itemImage: UIImage) {
        imageView.image = itemImage
    }
}
