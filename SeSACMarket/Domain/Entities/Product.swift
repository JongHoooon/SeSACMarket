//
//  Product.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

struct Product {
    let id: String
    let title: String
    let imageURL: String
    let mallName: String
    let price: Int
    let isLike: Bool

    init(
        id: String,
        title: String,
        imageURL: String,
        mallName: String,
        price: Int,
        isLike: Bool = false
    ) {
        self.id = id
        self.title = title
        self.imageURL = imageURL
        self.mallName = mallName
        self.price = price
        self.isLike = isLike
    }
}

extension Product {
    enum SortValue: CaseIterable {
        case similarity
        case date
        case priceDescending
        case priceAscending
    }
}

struct ProductsPage {
    let start: Int
    let display: Int
    let items: [Product]
}
