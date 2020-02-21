//
//  FinishRegistrationViewController.swift
//  MarketPlaceProject
//
//  Created by RainMan on 2/19/20.
//  Copyright © 2020 RainMan. All rights reserved.
//

import UIKit
import JGProgressHUD


class FinishRegistrationViewController: UIViewController {

    //MARK: - IBOutlets
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surnameTextField: UITextField!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var doneButtonOutlet: UIButton!
    
    //MARK: - Vars
    let hud = JGProgressHUD(style : .dark)
    
    //MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        surnameTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        addressTextField.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        // Do any additional setup after loading the view.
    }
    
    
    
    //MARK: - IBActions
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        finishOnBoarding()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField){
        updateDoneButtonStatus()
    }
    
    //MARK: -Helpers
    private func updateDoneButtonStatus() {
        
        if nameTextField.text != "" && surnameTextField.text != "" &&
            addressTextField.text != "" {
            doneButtonOutlet.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
            doneButtonOutlet.isEnabled = true
        } else {
            doneButtonOutlet.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            doneButtonOutlet.isEnabled = false
        }
    }
    
    private func finishOnBoarding() {
        let withValues = [kFIRSTNAME : nameTextField.text!, kLASTNAME : surnameTextField.text!, kONBOARD : true, kFULLADDRESS : addressTextField.text!, kFULLNAME : (nameTextField.text! + " " + surnameTextField.text!)] as [String : Any]
        
        updateCurrentUserInFirestore(withValues: withValues) { (error) in
            if error == nil {
                self.hud.textLabel.text = "Updated!"
                self.hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
                
                self.dismiss(animated: true, completion: nil)
            } else {
                print("error updating user \(error!.localizedDescription)")
                
                self.hud.textLabel.text = error?.localizedDescription
                self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
                self.hud.show(in: self.view)
                self.hud.dismiss(afterDelay: 2.0)
                
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
}
