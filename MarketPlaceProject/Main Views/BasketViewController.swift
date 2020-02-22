//
//  BasketViewController.swift
//  MarketPlaceProject
//
//  Created by RainMan on 2/13/20.
//  Copyright © 2020 RainMan. All rights reserved.
//

import UIKit
import JGProgressHUD
class BasketViewController: UIViewController {

    //MARK: - IBOutlets
    
    @IBOutlet weak var basketTotalPriceLabel: UILabel!
    @IBOutlet weak var footerView: UIView!
    @IBOutlet weak var totalItemsLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var checkOutButtonOutlet: UIButton!
    
    //MARK: - Vars
    var basket: Basket?
    var allItems: [Item] = []
    var purchasedItemIds : [String] = []
    
    let hud = JGProgressHUD(style: .dark)
    
    var environment : String = PayPalEnvironmentNoNetwork{
        willSet (newEnvironment) {
            if (newEnvironment != environment) {
                PayPalMobile.preconnect(withEnvironment : newEnvironment)
            }
        }
    }
    
    var payPalConfig = PayPalConfiguration()
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = footerView
        
        setupPayPal()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if MUser.currentUser() != nil {
            loadBasketFromFirestore()
        } else {
            self.updateTotalLabel(true)
        }
    }
    
    //MARK: - IBActions
    
    @IBAction func checkOutButtonPressed(_ sender: Any) {
        
        if MUser.currentUser()!.onBoard{
            
            payButtonPressed()
            
            
            
        } else {
            self.hud.textLabel.text = "Please complete your profile!"
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.0)
        }
    }
    
    //MARK: - Download basket
    private func loadBasketFromFirestore(){
        downloadBasketFromFirestore(MUser.currentId()){ (basket) in
            self.basket = basket
            self.getBasketItems()
        }
    }
    
    private func getBasketItems(){
        if basket != nil {
            downloadItems(basket!.itemIds) { (allItems) in
                self.allItems = allItems
                self.updateTotalLabel(false)
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Helper functions
    
    
    
    private func updateTotalLabel(_ isEmpty : Bool) {
        if isEmpty {
            totalItemsLabel.text = "0"
            basketTotalPriceLabel.text = returnBasketTotalPrice()
        } else {
            totalItemsLabel.text = "\(allItems.count)"
            basketTotalPriceLabel.text = returnBasketTotalPrice()
        }
        
        checkoutButtonStatusUpdate()
    }
    
    private func returnBasketTotalPrice() -> String {
        var totalPrice = 0.0
        
        for item in allItems {
            totalPrice += item.price
        }
        
        return "Total price: " + convertToCurrency(totalPrice)
    }
    
    private func emptyTheBasket() {
        purchasedItemIds.removeAll()
        allItems.removeAll()
        tableView.reloadData()
        
        basket!.itemIds = []
        
        updateBasketInFirestore(basket!, withValues: [kITEMIDS : basket!.itemIds]) { (error) in
            
            if error != nil {
                print("Error updating basket", error!.localizedDescription)
            } else {
                self.getBasketItems()
            }
        }
    }
    
    private func addItemsToPurchaseHistory(_ itemIds : [String]){
        if MUser.currentUser() != nil {
            let newItemIds = MUser.currentUser()!.purchasedItemIds + itemIds
            updateCurrentUserInFirestore(withValues: [kPURCHASEDITEMID : newItemIds]) { (error) in
                if error != nil {
                    print("Error adding purchased items", error!.localizedDescription)
                }
            }
        }
    }
    
    //MARK: - Navigation
    
    private func showItemView(withItem: Item) {
        let itemVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "itemView") as! ItemViewController
        itemVC.item = withItem
        self.navigationController?.pushViewController(itemVC, animated: true)
    }
    
    //MARK: - Control checkoutButton
    
    private func checkoutButtonStatusUpdate() {
        checkOutButtonOutlet.isEnabled = allItems.count > 0
        
        if checkOutButtonOutlet.isEnabled{
            checkOutButtonOutlet.backgroundColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        } else {
            disableCheckoutButton()
        }
    }
    
    private func disableCheckoutButton() {
        checkOutButtonOutlet.isEnabled = false
        checkOutButtonOutlet.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
    }
    
    private func removeItemFromBasket(itemId : String) {
        
        for i in 0..<basket!.itemIds.count {
            if itemId == basket!.itemIds[i] {
                basket!.itemIds.remove(at: i)
                
                return
            }
        }
    }
    
    //MARK: - Paypal
    
    private func setupPayPal() {
        payPalConfig.acceptCreditCards = false
        
        payPalConfig.merchantName = "MarketPlace"
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        payPalConfig.payPalShippingAddressOption = .both
    }
    
    private func payButtonPressed() {
        
        var itemsToBuy : [PayPalItem] = []
        for item in allItems {
            let tempItem = PayPalItem(name: item.name, withQuantity: 1, withPrice: NSDecimalNumber(value: item.price), withCurrency: "USD", withSku: nil)
            purchasedItemIds.append(item.id)
            itemsToBuy.append(tempItem)
        }
        
        let subTotal = PayPalItem.totalPrice(forItems: itemsToBuy)
        
        //optional
        let shippingCost = NSDecimalNumber(string: "50.0")
        let tax = NSDecimalNumber(string: "5.00")
        
        let paymentDetails = PayPalPaymentDetails(subtotal: subTotal, withShipping: shippingCost, withTax: tax)
        
        let total = subTotal.adding(shippingCost).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Payment to xxx", intent: .sale)
        
        payment.items = itemsToBuy
        payment.paymentDetails = paymentDetails
        
        if payment.processable {
            
            let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
            
            present(paymentViewController!, animated: true, completion: nil)
            
            
        } else {
            print("Payment not processing")
        }
        
        
        
    }
    
}

extension BasketViewController : UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for:indexPath) as! ItemTableViewCell
        
        cell.generateCell(allItems[indexPath.row])
        
        return cell
    }
    
    //MARK: - UITableview Delegate
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let itemToDelete = allItems[indexPath.row]
            
            allItems.remove(at: indexPath.row)
            tableView.reloadData()
            
            removeItemFromBasket(itemId: itemToDelete.id)
            
            updateBasketInFirestore(basket!, withValues: [kITEMIDS : basket!.itemIds]) { (error) in
                if error != nil {
                    print("error updating the basket", error!.localizedDescription)
                }
                
                self.getBasketItems()
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        showItemView(withItem: allItems[indexPath.row])
    }
    
    
}

extension BasketViewController : PayPalPaymentDelegate {
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        print("paypal payment cancelled")
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        
        
        
        paymentViewController.dismiss(animated: true) {
            //send a email to the users to thank for choosing the marketplace
            
            
            self.addItemsToPurchaseHistory(self.purchasedItemIds)
            self.emptyTheBasket()
        }
    }
    
    
}
