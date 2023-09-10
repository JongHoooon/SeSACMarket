//
//  Product.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

struct Product: Decodable {
    let productID: String
    let title: String
    let imageURL: String
    let mallName: String
    let price: String
    let isLike: Bool?

    enum CodingKeys: String, CodingKey {
        case productID = "productId"
        case title
        case imageURL = "image"
        case mallName
        case price = "lprice"
        case isLike
    }

    init(
        productID: String,
        title: String,
        imageURL: String,
        mallName: String,
        price: String,
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
