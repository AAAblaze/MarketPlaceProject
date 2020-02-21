//
//  purchaseHistoryTableViewController.swift
//  MarketPlaceProject
//
//  Created by RainMan on 2/20/20.
//  Copyright © 2020 RainMan. All rights reserved.
//

import UIKit

class purchaseHistoryTableViewController: UITableViewController {

    //MARK: - Vars
    var itemArray : [Item] = []
    
    
    //MARK: - View Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        loadItems()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ItemTableViewCell

        cell.generateCell(itemArray[indexPath.row])

        return cell
    }
    
    //MARK: - Load Items
    private func loadItems() {
        
        downloadItems(MUser.currentUser()!.purchasedItemIds) { (allItems) in
            self.itemArray = allItems
            self.tableView.reloadData()
        }
        
        
    }
    
}
