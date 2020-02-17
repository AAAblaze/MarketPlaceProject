//
//  FirebaseCollectionReference.swift
//  MarketPlaceProject
//
//  Created by RainMan on 1/20/20.
//  Copyright © 2020 RainMan. All rights reserved.
//

import Foundation
import FirebaseFirestore

enum FCollectionReference : String{
    case User
    case Category
    case Items
    case Basket
}

func FirebaseReference(_ collectionReference:FCollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}
