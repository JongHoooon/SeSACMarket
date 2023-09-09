//
//  ReusableProtocol.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import UIKit

protocol ReusableProtocol {}

extension ReusableProtocol {
    static var identifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell: ReusableProtocol {}
