//
//  ProductLocalUseCase.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

final class ProductLocalUseCase {
    
    private let productLocalRepository: ProductLocalRepository
    
    init(productLocalRepository: ProductLocalRepository) {
        self.productLocalRepository = productLocalRepository
    }
    
    func saveLikeProduct(productID: Int) async throws {
        try await productLocalRepository.saveLikeProduct(productID: productID)
    }
    
    func deleteLikeProduct(productID: Int) async throws {
        try await productLocalRepository.deleteLikeProduct(productID: productID)
    }
    
    func fetchAllLikeProducts() async throws -> [Product] {
        try await productLocalRepository.fetchAllLikeProducts()
    }
    
    func fetchQueryLikeProducts(query: String) async throws -> [Product] {
        try await productLocalRepository.fetchQueryLikeProducts(query: query)
    }
}
