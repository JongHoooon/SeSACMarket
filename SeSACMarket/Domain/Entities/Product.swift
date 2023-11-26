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
    let mallName: String
    let price: Int
    let isLike: Bool?

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

extension Product {
    enum SortValue: CaseIterable {
        case similarity
        case date
        case priceDescending
        case priceAscending
        
        var parameter: String {
            switch self {
            case .similarity:               return "sim"
            case .date:                     return "date"
            case .priceDescending:          return "dsc"
            case .priceAscending:           return "asc"
            }
        }
        
        var title: String {
            switch self {
            case .similarity:               return "정확도"
            case .date:                     return "날짜순"
            case .priceDescending:          return "가격높은순"
            case .priceAscending:           return "가격낮은순"
            }
        }
    }
}

struct ProductsPage {
    let start: Int
    let display: Int
    let items: [Product]
}
