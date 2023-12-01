//
//  UIFont+Extension.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import UIKit

extension UIFont {
    enum CustomFont {
        static let caption = systemFont(ofSize: Constants.FontSize.caption)
        static let title = systemFont(ofSize: Constants.FontSize.title)
        static let bold = systemFont(ofSize: Constants.FontSize.bold)
    }
}
