//
//  ProductRemoteUseCase.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

protocol ProductRemoteUseCase {
    func fetchProducts(query: String, sort: SortEnum, start: Int, display: Int) async throws -> ProductsPage
}

extension ProductRemoteUseCase {
    /// - start: 검색 시작 페이지 위치(1이상 1000이하)
    /// - display: 한 번에 표시할 검색 결과 개수(default: 30개)
    func fetchProducts(query: String, sort: SortEnum, start: Int, display: Int = 30) async throws -> ProductsPage {
        try await fetchProducts(query: query, sort: sort, start: start, display: display)
    }
}

final class DefaultProductRemoteUseCase: ProductRemoteUseCase {
    
    private let productRemoteRepository: ProductRemoteRepository
    
    init(productRemoteRepository: ProductRemoteRepository) {
        self.productRemoteRepository = productRemoteRepository
    }
    
    /// - start: 검색 시작 페이지 위치(1이상 1000이하)
    /// - display: 한 번에 표시할 검색 결과 개수(default: 30개)
    func fetchProducts(
        query: String,
        sort: SortEnum,
        start: Int,
        display: Int = 30
    ) async throws -> ProductsPage {
        return try await productRemoteRepository.fetchProducts(
            query: query,
            sort: sort,
            start: start,
            display: display
        )
    }
}
