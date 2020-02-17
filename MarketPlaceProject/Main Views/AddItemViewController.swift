//
//  AddItemViewController.swift
//  MarketPlaceProject
//
//  Created by RainMan on 1/26/20.
//  Copyright © 2020 RainMan. All rights reserved.
//

import UIKit
import Gallery
import JGProgressHUD
import NVActivityIndicatorView


class AddItemViewController: UIViewController {
    
    //MARK: Vars
    var category : Category!
    var gallery : GalleryController!
    let hud = JGProgressHUD(style: .dark)
    var activityIndicator : NVActivityIndicatorView?
    var itemImages : [UIImage?] = []

    //MARK: IBOutlets

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!

    //MARK: View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityIndicator = NVActivityIndicatorView(frame: CGRect(x: self.view.frame.width / 2 - 30, y : self.view.frame.height / 2 - 30, width: 60, height: 60), type: .ballPulse, color: #colorLiteral(red: 0.9998469949, green: 0.4941213727, blue: 0.4734867811, alpha: 1), padding: nil)
    }
    
    //#colorLiteral(red: 0.9998469949, green: 0.4941213727, blue: 0.4734867811, alpha: 1)

    //MARK: IBActions

    @IBAction func doneButtonPressed(_ sender: Any) {
        dismissKeyboard()
        if fieldsAreCompleted(){
            saveToFirebase()
        }
        else{
            print("Error all fields are required")
            self.hud.textLabel.text = "All fields are required!"
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.0)
        }
    }
    @IBAction func cameraButtonPressed(_ sender: Any) {
        itemImages = []
        showImageGallery()
    }
    
    @IBAction func backgroundTapped(_ sender: Any) {
        dismissKeyboard()
    }
    

    //MARK: Helper functions
    
    private func fieldsAreCompleted() -> Bool{
        
        return (titleTextField.text != "" && priceTextField.text != "" && descriptionTextField.text != "")
    }
    
    private func dismissKeyboard(){
        self.view.endEditing(false)
    }
    
    private func popTheView(){
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: Save Item
    private func saveToFirebase(){
        
        showLoadingIndicator()
        
        let item = Item()
        item.id = UUID().uuidString
        item.name = titleTextField.text!
        item.categoryId = category.id
        item.description = descriptionTextField.text
        item.price = Double(priceTextField.text!)
        if itemImages.count > 0{
            uploadImages(images: itemImages, itemId: item.id) { (imageLinkArray) in
                item.imageLinks = imageLinkArray
                saveItemToFirestore(item)
                self.hideLoadingIndicator()
                self.popTheView()
            }
        } else{
            saveItemToFirestore(item)
            popTheView()
        }
    }
    
    //MARK: Activity Indicator
    
    private func showLoadingIndicator(){
        if activityIndicator != nil {
            self.view.addSubview(activityIndicator!)
            activityIndicator!.startAnimating()
        }
        
    }
    
    private func hideLoadingIndicator(){
        
        if activityIndicator != nil {
            activityIndicator!.removeFromSuperview()
            activityIndicator!.stopAnimating()
        }
    }

    //MARK: show Gallery
    private func showImageGallery() {
        self.gallery = GalleryController()
        self.gallery.delegate = self
        
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 6
        
        self.present(self.gallery, animated: true, completion: nil)
    }
}

extension AddItemViewController : GalleryControllerDelegate{
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        
        if images.count > 0{
            Image.resolve(images: images) {(resolevedImages) in
                self.itemImages = resolevedImages
            }
        }
        
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
