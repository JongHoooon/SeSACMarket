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
    
    func saveLikeProduct(product: Product) async throws {
        try await productLocalRepository.saveLikeProduct(product: product)
    }
    
    func deleteLikeProduct(productID: Int) async throws {
        try await productLocalRepository.deleteLikeProduct(productID: productID)
    }
    
    func fetchAllLikeProducts() async throws -> [Product] {
        await productLocalRepository.fetchAllLikeProducts()
    }
    
    func fetchQueryLikeProducts(query: String) async throws -> [Product] {
        await productLocalRepository.fetchQueryLikeProducts(query: query)
    }
    
    func isLikeProduct(productID: Int) async throws -> Bool {
        await productLocalRepository.isLikeProduct(productID: productID)
    }
}
