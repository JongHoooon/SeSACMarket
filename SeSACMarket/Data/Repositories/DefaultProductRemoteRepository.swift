//
//  DefaultProductRemoteRepository.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/08.
//

import Foundation

import RxSwift

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
    
    func fetchProducts(
        query: String,
        sort: SortEnum,
        start: Int,
        display: Int
    ) -> Observable<ProductsPage> {
        return Observable<ProductsPage>.create { observer in
            Task {
                do {
                    let productPageDTO = try await self.callRequest(
                        of: ProductsPageDTO.self,
                        api: ProductAPI.fetchQuery(
                            query: query,
                            sort: sort,
                            start: start,
                            display: display
                        )
                    )
                    observer.onNext(productPageDTO.toDomain())
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
