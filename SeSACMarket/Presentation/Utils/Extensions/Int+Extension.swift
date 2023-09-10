//
//  Int+Extension.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import Foundation

extension Int {
    var priceFormat: String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = numberFormatter.string(from: NSNumber(value: self))
        return result ?? "0"
    }
}
