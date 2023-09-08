//
//  ProductRemoteRepository.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

protocol ProductRemoteRepository {
    func fetchProducts(query: String, start: Int, display: Int) async throws -> ProductPage
}
