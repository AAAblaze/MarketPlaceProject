//
//  CategoryCollectionViewController.swift
//  MarketPlaceProject
//
//  Created by RainMan on 1/20/20.
//  Copyright © 2020 RainMan. All rights reserved.
//

import UIKit


class CategoryCollectionViewController: UICollectionViewController {
    
    
    //MARK: Vars
    var categoryArray: [Category] = []
    
    private let sectionInSets = UIEdgeInsets(top: 20.0, left: 10.0, bottom: 20.0, right: 10.0)
    private let itemsPerRow : CGFloat = 3
    
    //MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //createCategorySet()
        //the function above is used once to create databse in Firebase
        
    }

    override func viewDidAppear(_ animated: Bool){
        super.viewDidAppear(animated)

        loadCategories()
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return categoryArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        // Configure the cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CategoryCollectionViewCell
        cell.generateCell(categoryArray[indexPath.row])
        return cell
    }
    //MARK:UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "CategoryToItemsSeg", sender: categoryArray[indexPath.row])
    }

    //MARK: Download categories
    private func loadCategories(){
        downloadCategoriesFromFirebase { (allCategories) in
            self.categoryArray = allCategories
            self.collectionView.reloadData()
        }

    }
    
    //MARK:Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CategoryToItemsSeg"{
            let vc = segue.destination as! ItemsTableViewController
            vc.category = sender as! Category
        }
    }

}


extension CategoryCollectionViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeFromItemAt indexPath: IndexPath) -> CGSize{
        let paddingSpace = sectionInSets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInSets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return sectionInSets.left
    }
}

