//
//  ProductLocalUseCase.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import Foundation

final class ProductLocalUseCase {
    
    private let productLocalRepository: ProductLocalRepository
    
    init(productLocalRepository: ProductLocalRepository) {
        self.productLocalRepository = productLocalRepository
    }
    
    func saveLikeProduct(product: Product) async throws {
        try await productLocalRepository.saveLikeProduct(product: product)
        NotificationCenter.default.post(
            name: .likeProduct,
            object: nil,
            userInfo: [
                "id": product.productID,
                "isSelected": true
            ]
        )
    }
    
    func deleteLikeProduct(productID: Int) async throws {
        try await productLocalRepository.deleteLikeProduct(productID: productID)
        NotificationCenter.default.post(
            name: .likeProduct,
            object: nil,
            userInfo: [
                "id": productID,
                "isSelected": false
            ]
        )
    }
    
    func fetchAllLikeProducts() async -> [Product] {
        await productLocalRepository.fetchAllLikeProducts()
    }
    
    func fetchQueryLikeProducts(query: String) async -> [Product] {
        await productLocalRepository.fetchQueryLikeProducts(query: query)
    }
    
    func isLikeProduct(productID: Int) async -> Bool {
        await productLocalRepository.isLikeProduct(productID: productID)
    }
}
