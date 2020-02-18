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
                    
                    downloadUserFromFirestore(userId: authDataResult!.user.uid, email: email)
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

//MARK: - DownloadUser
func downloadUserFromFirestore(userId : String, email : String){
    FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
        guard let snapshot = snapshot else {
            return
        }
        if snapshot.exists{
            print("download current user from firestore")
            saveUserLocally(mUserDictionary: snapshot.data()! as NSDictionary)
        } else {
            //There is no user, save new in firestore
            
            let user = MUser(_objectId: userId, _email: email, _firstName: "", _lastName: "")
            saveUserLocally(mUserDictionary: userDictionaryFrom(user: user))
            saveUserToFirestore(mUser: user)
        }
    }
}



//MARK: - Save user to firebase

func saveUserToFirestore(mUser: MUser) {
    
    FirebaseReference(.User).document(mUser.objectId).setData(userDictionaryFrom(user: mUser) as! [String : Any]) { (error) in
        if error != nil{
            print("error saving user \(error!.localizedDescription)")
        }
    }
}

func saveUserLocally(mUserDictionary: NSDictionary) {
    
    UserDefaults.standard.set(mUserDictionary, forKey: kCURRENTUSER)
    UserDefaults.standard.synchronize()
    
}


//MARK: - Helper function

func userDictionaryFrom(user: MUser) -> NSDictionary {
    return NSDictionary(objects: [user.objectId, user.email, user.firstName, user.lastName, user.fullName, user.fullAddress ?? "", user.onBoard, user.purchasedItemIds], forKeys: [kOBJECTID as NSCopying, kEMAIL as NSCopying, kFIRSTNAME as NSCopying, kLASTNAME as NSCopying, kFULLNAME as NSCopying, kFULLADDRESS as NSCopying, kONBOARD as NSCopying, kPURCHASEDITEMID as NSCopying])
}
