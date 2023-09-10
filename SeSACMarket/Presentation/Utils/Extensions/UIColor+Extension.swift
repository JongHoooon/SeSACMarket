//
//  UIColor+Extension.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

extension UIColor {
    enum Custom {
        static let mainTintColor = UIColor.label
        static let mainBackgroundColor = UIColor.systemBackground
        static let grayBackground = UIColor.systemGray
        
        enum Text {
            /// label
            static let main = UIColor.label
            /// systemGray5
            static let caption = UIColor.systemGray
        }
    }
}
