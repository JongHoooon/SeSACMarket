//
//  Constant.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/09.
//

import Foundation

enum Constants {}

// MARK: - Font Size
extension Constants {
    enum FontSize {
        static let caption: CGFloat = 13.0
        static let title: CGFloat = 15.0
        static let bold: CGFloat = 18.0
    }
    
    enum Inset {
        static let defaultInset: CGFloat = 16.0
        static let large: CGFloat = 24.0
        static let medium: CGFloat = 8.0
        static let small: CGFloat = 4.0
    }
    
    enum CornerRadius {
        static let `default`: CGFloat = 8.0
    }
    
    enum SortCell {
        static let height: CGFloat = 32.0
    }
    
    enum NotificationCenterUserInfoKey {
        static let id = "id"
        static let isSelected = "isSelected"
    }
}
