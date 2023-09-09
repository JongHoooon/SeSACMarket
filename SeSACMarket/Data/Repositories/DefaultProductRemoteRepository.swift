//
//  DefaultProductRemoteRepository.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import Foundation

final class DefaultProductRemoteRepository: ProductRemoteRepository {
    
    private let apiDataTransferManager: APIDataTransferService
    
    init(apiDataTransferManager: APIDataTransferService) {
        self.apiDataTransferManager = apiDataTransferManager
    }
    
    func fetchProducts(
        query: String,
        sort: SortEnum,
        start: Int,
        display: Int
    ) async throws -> ProductsPage {
        do {
            return try await apiDataTransferManager.callRequest(
                of: ProductsPage.self,
                api: ProductAPI.fetchQuery(
                    query: query,
                    sort: sort,
                    start: start,
                    display: display
                )
            )
        } catch {
            throw error
        }
    }
}
