//
//  EditProfileViewController.swift
//  MarketPlaceProject
//
//  Created by RainMan on 2/19/20.
//  Copyright © 2020 RainMan. All rights reserved.
//

import UIKit
import JGProgressHUD

class EditProfileViewController: UIViewController {

    //MARK: - IBOutlets
    

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    
    //MARK: - Vars
    let hud = JGProgressHUD(style: .dark)
    
    //MAR: - View Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserInfo()
        
    }
    
    //MARK: - IBActions
    
    @IBAction func saveBarButtonPressed(_ sender: Any) {
        dismissKeyboard()
        if textFieldsHaveText() {
            
            let withValues = [kFIRSTNAME : nameTextField.text!, kLASTNAME : surnameTextField.text!, kFULLNAME : (nameTextField.text! + " " + surnameTextField.text!), kFULLADDRESS : addressTextField.text!]
            updateCurrentUserInFirestore(withValues: withValues) { (error) in
                if error != nil {
                    print("error updating user ", error!.localizedDescription)
                    self.hud.textLabel.text = error!.localizedDescription
                    self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                    
                } else {
                    self.hud.textLabel.text = "updated!"
                    self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    self.hud.show(in: self.view)
                    self.hud.dismiss(afterDelay: 2.0)
                }
            }
            
        } else {
            
            self.hud.textLabel.text = "All fields are required!"
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.show(in: self.view)
            self.hud.dismiss(afterDelay: 2.0)
            
        }
        
        
    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        logOutUser();
    }
    
    //MARK: - Update UI
    
    private func loadUserInfo() {
        if MUser.currentUser() != nil {
            let currentUser = MUser.currentUser()!
            
            nameTextField.text = currentUser.firstName
            surnameTextField.text = currentUser.lastName
            addressTextField.text = currentUser.fullAddress
        }
    }
    
    //MARK: - Helper funcs
    
    private func dismissKeyboard() {
        self.view.endEditing(false)
    }
    
    private func textFieldsHaveText() -> Bool {
        return (nameTextField.text != "" && surnameTextField.text != "" && addressTextField.text != "")
    }
    
    private func logOutUser(){
        MUser.logOutCurrentUser { (error) in
            
            if error == nil {
                print("logged out")
                self.navigationController?.popViewController(animated: true)
            } else {
                print("error login out", error!.localizedDescription)
            }
        }
    }
    
}
