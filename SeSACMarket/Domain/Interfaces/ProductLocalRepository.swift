//
//  ProductLocalRepository.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

protocol ProductLocalRepository {
    func saveLikeProduct(productID: Int) async throws
    func deleteLikeProduct(productID: Int) async throws
    func fetchAllLikeProducts() async throws -> [Product]
    func fetchQueryLikeProducts(query: String) async throws -> [Product]
}
