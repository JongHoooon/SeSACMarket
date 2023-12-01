//
//  ProductCollectionViewCellViewModel.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import Foundation

import ReactorKit
import RxRelay

final class ProductCollectionViewCellReactor: Reactor {
    
    typealias Action = NoAction
    
    let initialState: Product
    let likeUseCase: LikeUseCase?
    let errorHandler: ((_ error: Error) -> Void)?
    let productsCellEventReplay: PublishRelay<ProductsCellEvent>?
    
    init(
        prodcut: Product,
        likeUseCase: LikeUseCase,
        errorHandler: ((_ error: Error) -> Void)?,
        productsCellEventReplay: PublishRelay<ProductsCellEvent>? = nil
    ) {
        self.initialState = prodcut
        self.likeUseCase = likeUseCase
        self.errorHandler = errorHandler
        self.productsCellEventReplay = productsCellEventReplay
    }
}
