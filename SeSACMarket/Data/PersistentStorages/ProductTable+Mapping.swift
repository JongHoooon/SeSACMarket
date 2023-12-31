//
//  ProductTable+Mapping.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import Foundation

import RealmSwift

final class ProductTable: Object {
    @Persisted(primaryKey: true) var productID: String
    @Persisted var title: String
    @Persisted var imageURL: String
    @Persisted var mallName: String
    @Persisted var price: Int
    @Persisted var isLike: Bool
    @Persisted var enrolledDate: Date
    
    convenience init(
        productID: String,
        title: String,
        imageURL: String,
        mallName: String,
        price: Int,
        isLike: Bool
    ) {
        self.init()
        self.productID = productID
        self.title = title
        self.imageURL = imageURL
        self.mallName = mallName
        self.price = price
        self.isLike = isLike
        self.enrolledDate = Date()
    }
    
    func toDomain() -> Product {
        return Product(
            id: productID,
            title: title,
            imageURL: imageURL,
            mallName: mallName,
            price: price
        )
    }
}
