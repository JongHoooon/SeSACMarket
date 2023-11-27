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
    let likeUseCase: LikeUseCase?
    let errorHandler: ((_ error: Error) -> Void)?
    let productsCellEventReplay: PublishRelay<ProductsCellEvent>?
    
    init(
        prodcut: Product,
        likeUseCase: LikeUseCase,
        errorHandler: ((_ error: Error) -> Void)?,
        productsCellEventReplay: PublishRelay<ProductsCellEvent>? = nil
    ) {
        self.prodcut = prodcut
        self.likeUseCase = likeUseCase
        self.errorHandler = errorHandler
        self.productsCellEventReplay = productsCellEventReplay
    }
}
