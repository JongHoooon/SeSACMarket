//
//  AppDIContainer.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import Foundation

final class AppDIContainer {
    
    func makeAuthSceneDIContainer() -> AuthSceneDIContainer {
        return AuthSceneDIContainer()
    }
    
}
