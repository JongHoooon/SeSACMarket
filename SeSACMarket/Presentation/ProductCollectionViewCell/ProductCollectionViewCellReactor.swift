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
        case checkIsLike
        case likeButtonTapped
    }
    
    enum Mutation {
        case toggleLike
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
        case .checkIsLike:
            return .empty()
            
        case .likeButtonTapped:
            guard let isLike = currentState.isLike else { return .empty() }
            return .concat([
                .just(.setLikeButtonIsEnable(false)),
                
                likeUseCase.toggleProductLike(product: currentState.product, current: isLike)
                    .asObservable()
                    .map { .setLikeButtonIsEnable($0) },
                    
                .just(.setLikeButtonIsEnable(true))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .toggleLike:
            newState.isLike?.toggle()
            
        case let .setLikeButtonIsEnable(isEnable):
            print(isEnable)
            newState.likeButtonIsEnable = isEnable
            
        case let .setProduct(product):
            newState.product = product
        }
        
        return state
    }
}
