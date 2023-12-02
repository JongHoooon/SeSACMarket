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
    private let likeUseCase: LikeUseCase
    private let errorHandler: ((_ error: Error) -> Void)?
    private let productsCellEventReplay: PublishRelay<ProductsCellEvent>
    private let notificationEventRelay: PublishRelay<NotificationEvent>
    private let disposeBag: DisposeBag
    
    init(
        product: Product,
        likeUseCase: LikeUseCase,
        errorHandler: ((_ error: Error) -> Void)?,
        productsCellEventReplay: PublishRelay<ProductsCellEvent>
    ) {
        self.likeUseCase = likeUseCase
        self.errorHandler = errorHandler
        self.productsCellEventReplay = productsCellEventReplay
        self.notificationEventRelay = PublishRelay()
        self.disposeBag = DisposeBag()
        self.initialState = State(
            product: product, 
            likeButtonIsEnable: true
        )
        registerNotification()
    }
}

extension ProductCollectionViewCellReactor {
    
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let notificationEventMutation = notificationEventRelay
            .flatMap { [weak self] notificationEvent in
                self?.mutate(notificationEvent: notificationEvent) ?? .empty()
            }
        
        return .merge(mutation, notificationEventMutation)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .likeButtonTapped:
            guard let isLike = currentState.isLike else { return .empty() }
            return .concat([
                .just(.setLikeButtonIsEnable(false)),
                
                likeUseCase.toggleProductLike(product: currentState.product, current: isLike)
                    .asObservable()
                    .do(onError: { [weak self] in self?.productsCellEventReplay.accept(.error($0)) })
                    .map { .setIsLike($0) },
                    
                .just(.setLikeButtonIsEnable(true))
            ])
            
        case .checkIsLike:
            return likeUseCase.isLikeProduct(id: currentState.product.id)
                .asObservable()
                .do(onError: { [weak self] in self?.productsCellEventReplay.accept(.error($0)) })
                .map { .setIsLike($0) }
        }
    }
    
    func mutate(notificationEvent: NotificationEvent) -> Observable<Mutation> {
        switch notificationEvent {
        case let .likeButtonTapped(bool):
            return .just(.setIsLike(bool))
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

private extension ProductCollectionViewCellReactor {
    func registerNotification() {
        NotificationCenter.default.rx.notification(.likeProduct)
            .bind(with: self, onNext: { owner, notification in
                let userInfo = notification.userInfo
                guard let id = userInfo?[Constants.NotificationCenterUserInfoKey.id] as? String,
                      let isSelected = userInfo?[Constants.NotificationCenterUserInfoKey.isSelected] as? Bool
                else { return }
                
                if self.currentState.product.id == id {
                    self.notificationEventRelay.accept(.likeButtonTapped(isSelected))
                }
            })
            .disposed(by: disposeBag)
    }
}
