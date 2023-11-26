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
        sort: Product.SortValue,
        start: Int,
        display: Int
    ) async throws -> ProductsPage {
        do {
            let productPageDTO =  try await self.callRequest(
                of: ProductsPageDTO.self,
                api: ProductAPI.fetchQuery(
                    productQuery: ProductQuery(query: query, sortValue: sort),
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
        sort: Product.SortValue,
        start: Int,
        display: Int
    ) -> Single<ProductsPage> {
        return Single<ProductsPage>.create { single in
            Task {
                do {
                    let productPageDTO = try await self.callRequest(
                        of: ProductsPageDTO.self,
                        api: ProductAPI.fetchQuery(
                            productQuery: ProductQuery(query: query, sortValue: sort),
                            start: start,
                            display: display
                        )
                    )
                    single(.success(productPageDTO.toDomain()))
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
    
    func fetchProducts(
        productQuery: ProductQuery,
        start: Int,
        display: Int
    ) -> Single<ProductsPage> {
        return Single<ProductsPage>.create { single in
            Task {
                do {
                    let productPageDTO = try await self.callRequest(
                        of: ProductsPageDTO.self,
                        api: ProductAPI.fetchQuery(
                            productQuery: productQuery,
                            start: start,
                            display: display
                        )
                    )
                    single(.success(productPageDTO.toDomain()))
                } catch {
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
