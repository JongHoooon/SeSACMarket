//
//  ProductRemoteRepository.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import RxSwift

protocol ProductRemoteRepository {
    func fetchProducts(query: String, sort: Product.SortValue, start: Int, display: Int) async throws -> ProductsPage
    func fetchProducts(query: String, sort: Product.SortValue, start: Int, display: Int) -> Single<ProductsPage>
    func fetchProducts(productQuery: ProductQuery, start: Int, display: Int) -> Single<ProductsPage>
}
