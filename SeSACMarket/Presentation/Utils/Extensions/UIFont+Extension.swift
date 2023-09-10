//
//  UIFont+Extension.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import UIKit

extension UIFont {
    enum CustomFont {
        static let caption = systemFont(ofSize: Constant.FontSize.caption)
        static let title = systemFont(ofSize: Constant.FontSize.title)
        static let bold = systemFont(ofSize: Constant.FontSize.bold)
    }
}
