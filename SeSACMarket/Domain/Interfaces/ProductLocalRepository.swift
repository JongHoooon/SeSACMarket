//
//  ProductLocalRepository.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

protocol ProductLocalRepository {
    func saveLikeProduct(product: Product) async throws
    func deleteLikeProduct(productID: Int) async throws
    func fetchAllLikeProducts() async -> [Product]
    func fetchQueryLikeProducts(query: String) async -> [Product]
    func isLikeProduct(productID: Int) async -> Bool
}
