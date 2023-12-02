//
//  ProdcutDTO+Mapping.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import Foundation

struct ProdcutDTO: Decodable {
    let productID: String?
    let title: String?
    let imageURL: String?
    let mallName: String?
    let price: String?

    enum CodingKeys: String, CodingKey {
        case productID = "productId"
        case title
        case imageURL = "image"
        case mallName
        case price = "lprice"
    }
    
    func toDomain() -> Product {
        return Product(
            id: productID ?? UUID().uuidString,
            title: title?.htmlEscaped ?? "제목 없음",
            imageURL: imageURL ?? "",
            mallName: mallName ?? "이름 없음",
            price: Int(price ?? "0") ?? 0
        )
    }
}

struct ProductsPageDTO: Decodable {
    let start: Int
    let display: Int
    let items: [ProdcutDTO]
}

