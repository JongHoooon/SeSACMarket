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
    
    enum Action {
        case likeButtonTapped
        case checkIsLike
    }
    
    enum Mutation {
        case setIsLike(Bool)
        case setLikeButtonIsEnable(Bool)
        case setProduct(Product)
    }
    
    struct State {
        var product: Product
        var likeButtonIsEnable: Bool
        var isLike: Bool?
    }
    
    let initialState: State
    let likeUseCase: LikeUseCase
    let errorHandler: ((_ error: Error) -> Void)?
    let productsCellEventReplay: PublishRelay<ProductsCellEvent>?
    
    init(
        product: Product,
        likeUseCase: LikeUseCase,
        errorHandler: ((_ error: Error) -> Void)?,
        productsCellEventReplay: PublishRelay<ProductsCellEvent>? = nil
    ) {
        self.likeUseCase = likeUseCase
        self.errorHandler = errorHandler
        self.productsCellEventReplay = productsCellEventReplay
        self.initialState = State(
            product: product, 
            likeButtonIsEnable: true
        )
    }
}

extension ProductCollectionViewCellReactor {
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .likeButtonTapped:
            guard let isLike = currentState.isLike else { return .empty() }
            return .concat([
                .just(.setLikeButtonIsEnable(false)),
                
                likeUseCase.toggleProductLike(product: currentState.product, current: isLike)
                    .asObservable()
                    .do(onError: { [weak self] in self?.productsCellEventReplay?.accept(.error($0)) })
                    .map { .setIsLike($0) },
                    
                .just(.setLikeButtonIsEnable(true))
            ])
            
        case .checkIsLike:
            return likeUseCase.isLikeProduct(id: currentState.product.id)
                .asObservable()
                .do(onError: { [weak self] in self?.productsCellEventReplay?.accept(.error($0)) })
                .map { .setIsLike($0) }
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setIsLike(bool):
            newState.isLike = bool
            
        case let .setLikeButtonIsEnable(isEnable):
            newState.likeButtonIsEnable = isEnable
            
        case let .setProduct(product):
            newState.product = product
        }
        
        return newState
    }
}
