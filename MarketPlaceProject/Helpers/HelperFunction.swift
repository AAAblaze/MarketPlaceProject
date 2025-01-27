//
//  HelperFunction.swift
//  MarketPlaceProject
//
//  Created by RainMan on 1/28/20.
//  Copyright © 2020 RainMan. All rights reserved.
//

import Foundation

func convertToCurrency(_ number: Double) -> String{
    let currencyFormatter = NumberFormatter()
    currencyFormatter.usesGroupingSeparator = true;
    currencyFormatter.numberStyle = .currency
    currencyFormatter.locale = Locale.current
    return currencyFormatter.string(from: NSNumber(value: number))!

}
