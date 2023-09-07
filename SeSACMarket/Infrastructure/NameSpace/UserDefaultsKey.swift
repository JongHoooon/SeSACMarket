//
//  UserDefaultsKey.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

enum UserDefaultsKey {
    case isLoggedIn
    
    var key: String {
        switch self {
        case .isLoggedIn:       return "isLoggedIn"
        }
    }
}
