//
//  TabBarEnum.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

enum TabBarEnum {
    case search
    case favorite
    
    private var title: String {
        switch self {
        case .search:       return "검색"
        case .favorite:     return "좋아요"
        }
    }
    
    private var image: UIImage? {
        switch self {
        case .search:       return ImageEnum.Icon.magninfyGlass
        case .favorite:     return ImageEnum.Icon.heart
        }
    }
    
    func configureTabBarItem(navigationController: UINavigationController) -> UINavigationController {
        navigationController.tabBarItem.title = self.title
        navigationController.tabBarItem.image = self.image
        return navigationController
    }
}
