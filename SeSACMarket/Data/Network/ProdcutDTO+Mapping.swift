//
//  ProdcutDTO+Mapping.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import Foundation

struct ProdcutDTO: Decodable {
    let productID: String
    let title: String
    let imageURL: String
    let mallName: String
    let price: String

    enum CodingKeys: String, CodingKey {
        case productID = "productId"
        case title
        case imageURL = "image"
        case mallName
        case price = "lprice"
    }
    
    func toDomain() -> Product {
        return Product(
            productID: Int(productID) ?? 0,
            title: title,
            imageURL: imageURL,
            mallName: mallName,
            price: Int(price) ?? 0
        )
    }
}

struct ProductsPageDTO: Decodable {
    let start: Int
    let display: Int
    let items: [ProdcutDTO]
    
    func toDomain() -> ProductsPage {
        return ProductsPage(
            start: start,
            display: display,
            items: items.map { $0.toDomain() }
        )
    }
}

