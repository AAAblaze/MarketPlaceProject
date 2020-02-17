//
//  WeclomeViewController.swift
//  MarketPlaceProject
//
//  Created by RainMan on 2/14/20.
//  Copyright © 2020 RainMan. All rights reserved.
//

import UIKit

class WeclomeViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var resendButtonOutlet: UIButton!
    
    
    //MARKL - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    //MARK: - IBActions
    
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        print("cancel")
    }
    @IBAction func loginButtonPressed(_ sender: Any) {
        print("login")
    }
    @IBAction func registerButtonPressed(_ sender: Any) {
        print("register")
    }
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        print("forgot pass")
    }
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        print("resend email")
    }
}
