//
//  LikeUseCase.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/14.
//

import Foundation

protocol LikeUseCase {
    func saveLikeProduct(product: Product) async throws
    func deleteLikeProduct(productID: String) async throws
    func isLikeProduct(productID: String) async -> Bool
}

final class DefaultLikeUseCase: LikeUseCase {
    
    // MARK: - Repository
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
                "id": product.id,
                "isSelected": true
            ]
        )
    }
    
    func deleteLikeProduct(productID: String) async throws {
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
    
    func isLikeProduct(productID: String) async -> Bool {
        await productLocalRepository.isLikeProduct(productID: productID)
    }
}
