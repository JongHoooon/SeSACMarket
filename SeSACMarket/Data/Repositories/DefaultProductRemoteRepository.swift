//
//  DefaultProductRemoteRepository.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import Foundation

final class DefaultProductRemoteRepository: ProductRemoteRepository, APIDataTransferService {
    
    func fetchProducts(
        query: String,
        sort: SortEnum,
        start: Int,
        display: Int
    ) async throws -> ProductsPage {
        do {
            let productPageDTO =  try await self.callRequest(
                of: ProductsPageDTO.self,
                api: ProductAPI.fetchQuery(
                    query: query,
                    sort: sort,
                    start: start,
                    display: display
                )
            )
            return productPageDTO.toDomain()
        } catch {
            throw error
        }
    }
}
