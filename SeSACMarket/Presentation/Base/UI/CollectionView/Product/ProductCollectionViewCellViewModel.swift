//
//  ProductCollectionViewCellViewModel.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import Foundation

import RxRelay

final class ProductCollectionViewCellViewModel {
    
    let prodcut: Product
    let likeUseCase: LikeUseCase
    let errorHandler: PublishRelay<Error>
    let needReload: PublishRelay<Void>?
    
    init(
        prodcut: Product,
        likeUseCase: LikeUseCase,
        errorHandler: PublishRelay<Error>,
        needReload: PublishRelay<Void>? = nil
    ) {
        self.prodcut = prodcut
        self.likeUseCase = likeUseCase
        self.errorHandler = errorHandler
        self.needReload = needReload
    }
}
