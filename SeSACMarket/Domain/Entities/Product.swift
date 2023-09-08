//
//  Product.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

struct Product {
    let productID: Int
    let title: String
    let imageURL: String
    let malName: String
    let price: Int
    let isLike: Bool
    
    init(
        productID: Int,
        title: String,
        imageURL: String,
        malName: String,
        price: Int,
        isLike: Bool = false
    ) {
        self.productID = productID
        self.title = title
        self.imageURL = imageURL
        self.malName = malName
        self.price = price
        self.isLike = isLike
    }
}

struct ProductPage {
    let start: Int
    let display: Int
    let items: [Product]
}
