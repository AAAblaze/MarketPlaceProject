//
//  MUser.swift
//  MarketPlaceProject
//
//  Created by RainMan on 2/15/20.
//  Copyright © 2020 RainMan. All rights reserved.
//

import Foundation
import FirebaseAuth

class MUser {
    
    let objectId: String
    var email: String
    var firstName: String
    var lastName : String
    var fullName: String
    var purchasedItemIds: [String]
    
    var fullAddress : String?
    var onBoard: Bool
    
    //MARK: - Initializetion
    
    init(_objectId: String, _email: String, _firstName: String, _lastName: String){
        objectId = _objectId
        email = _email
        firstName = _firstName
        lastName = _lastName
        fullName = _firstName + " " + _lastName
        fullAddress = ""
        onBoard = false
        purchasedItemIds = []
    }
    
    init (_dictionary : NSDictionary){
        
        objectId = _dictionary[kOBJECTID] as! String
        
        if let mail = _dictionary[kEMAIL]{
            email = mail as! String
        } else {
            email = ""
        }
        
        if let fname = _dictionary[kFIRSTNAME]{
            firstName = fname as! String
        } else {
            firstName = ""
        }
        
        if let lname = _dictionary[kLASTNAME]{
            lastName = lname as! String
        } else {
            lastName = ""
        }
        
        fullName = firstName + " " + lastName
        
        if let faddress = _dictionary[kFULLADDRESS]{
            fullAddress = faddress as! String
        } else {
            fullAddress = ""
        }
        
        if let onB = _dictionary[kONBOARD]{
            onBoard = onB as! Bool
        } else {
            onBoard = false
        }
        
        if let purchaseIds = _dictionary[kPURCHASEDITEMID]{
            purchasedItemIds = purchaseIds as! [String]
        } else {
            purchasedItemIds = []
        }
    }
    
    //MARK: - Return current user
    
    class func currentId() -> String {
        return Auth.auth().currentUser!.uid
    }
    
    class func currentUser() -> MUser? {
        
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
                return MUser.init(_dictionary: dictionary as! NSDictionary)
            }
        }
        
        return nil
    }
    
    //MARK: - Login func
    
    class func loginUserWith(email: String, password: String, completion: @escaping
        (_ error : Error?, _ isEmailVerified: Bool) -> Void){
        Auth.auth().signIn(withEmail: email, password : password) { (authDataResult, error) in
            if error == nil {
                if authDataResult!.user.isEmailVerified {
                    
                    //TODO: to download user from firestore
                    completion(error, true)
                } else {
                    print("email is not verified")
                    completion(error, false)
                }
            } else {
                completion(error, false)
            }
        }
    }
    
    //MARK: - Register user
    class func registerUserWith(email: String, password : String, completion: @escaping
        (_ error : Error?) -> Void){
        Auth.auth().createUser(withEmail: email, password: password) { (AuthDataResult, error) in
            
            completion(error)
            
            if error == nil {
                
                //TODO: send email verification
                AuthDataResult!.user.sendEmailVerification { (error) in
                    print("auth email verification error : ", error?.localizedDescription)
                }
                
            }
        }
    }
    
}
