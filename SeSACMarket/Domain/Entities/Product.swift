//
//  Product.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

struct Product: Decodable {
    let productID: Int
    let title: String
    let imageURL: String
    let mallName: String
    let price: Int
    let isLike: Bool?
    
    enum CodingKeys: String, CodingKey {
        case productID
        case title
        case imageURL = "image"
        case mallName
        case price = "lprice"
        case isLike
    }
    
    init(
        productID: Int,
        title: String,
        imageURL: String,
        mallName: String,
        price: Int,
        isLike: Bool = false
    ) {
        self.productID = productID
        self.title = title
        self.imageURL = imageURL
        self.mallName = mallName
        self.price = price
        self.isLike = isLike
    }
}

struct ProductsPage: Decodable {
    let start: Int
    let display: Int
    let items: [Product]
}
