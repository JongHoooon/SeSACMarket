//
//  ProductCellEvent.swift
//  SeSACMarket
//
//  Created by JongHoon on 11/27/23.
//

import Foundation

enum ProductsCellEvent {
    case needDelete(id: String)
    case error(Error)
}
