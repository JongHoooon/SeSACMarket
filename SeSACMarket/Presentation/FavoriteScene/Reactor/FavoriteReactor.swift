//
//  FavoriteReactor.swift
//  SeSACMarket
//
//  Created by JongHoon on 11/27/23.
//

import Foundation

import ReactorKit

import Kingfisher
import RxSwift
import RxRelay

final class FavoriteReactor: Reactor {
    
    enum Action {
        case viewWillAppear
        case searchTextInput(String)
        case productCellSelected(Product)
        case settingButtonTapped
    }
    
    enum Mutation {
        case setQuery(String)
        case scrollToTop
        case setProductsCellViewModels([ProductCollectionViewCellReactor])
        case deleteProducts(id: String)
    }
    
    struct State {
        @Pulse
        var scrollContentOffset: CGPoint?
        var query: String?
        var productsCellReactors: [ProductCollectionViewCellReactor]?
    }
    
    enum SideEffectEvent {
        case error(Error)
        case setQuery(String)
    }
        
    private let favoriteUseCase: FavoriteUseCase
    private let likeUseCase: LikeUseCase
    private weak var coordinator: FavoriteCoordinator?
    let initialState: State
    
    private let productsCellEventRelay: PublishRelay<ProductsCellEvent>
    private let sideEffectEventRelay: PublishRelay<SideEffectEvent>
    
    init(
        favoriteUseCase: FavoriteUseCase,
        likeUseCase: LikeUseCase,
        coordinator: FavoriteCoordinator
    ) {
        self.favoriteUseCase = favoriteUseCase
        self.likeUseCase = likeUseCase
        self.coordinator = coordinator
        self.productsCellEventRelay = PublishRelay()
        self.sideEffectEventRelay = PublishRelay()
        self.initialState = State()
    }
}

extension FavoriteReactor {
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let productsCellEventMutation = productsCellEventRelay
            .flatMap { [weak self] productsCellEvent in
                self?.muate(productsCellEvent: productsCellEvent) ?? .empty()
            }
        
        let sideEffectEventMutation = sideEffectEventRelay
            .flatMap { [weak self] sideEffectEvent in
                self?.mutate(sideEffectEvent: sideEffectEvent) ?? .empty()
            }
        
        return .merge(mutation, productsCellEventMutation, sideEffectEventMutation)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return favoriteUseCase.fetchAllLikeProducts()
                .asObservable()
                .compactMap { [weak self] in self?.productsToReactors(products: $0)}
                .map { .setProductsCellViewModels($0) }
                .do(onError: { [weak self] in self?.sideEffectEventRelay.accept(.error($0)) })
            
        case let .searchTextInput(query):
            return .concat(
                fetchItem(query: query)
                    .map { .setProductsCellViewModels($0) },
                .just(.scrollToTop)
            )
            
        case let .productCellSelected(product):
            coordinator?.pushToDetail(product: product)
            return .empty()
            
        case .settingButtonTapped:
            coordinator?.presentToSetting()
            return .empty()
        }
    }
    
    func muate(productsCellEvent: ProductsCellEvent) -> Observable<Mutation> {
        switch productsCellEvent {
        case let .needDelete(id):
            return .just(.deleteProducts(id: id))
            
        case let .error(error):
            print(error.localizedDescription)
            coordinator?.presnetErrorMessageAlert(error: error)
            return .empty()
        }
    }
    
    func mutate(sideEffectEvent: SideEffectEvent) -> Observable<Mutation> {
        switch sideEffectEvent {
        case .error(let error):
            print(error.localizedDescription)
            coordinator?.presnetErrorMessageAlert(error: error)
            return .empty()
        case let .setQuery(query):
            return .just(.setQuery(query))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .scrollToTop:
            newState.scrollContentOffset = .zero
            
        case let .setProductsCellViewModels(viewModels):
            newState.productsCellReactors = viewModels
            
        case let .setQuery(query):
            newState.query = query
            
        case let .deleteProducts(id):
            let newReactors = newState.productsCellReactors?.filter { $0.currentState.product.id != id }
            newState.productsCellReactors = newReactors
        }
        
        return newState
    }
}

private extension FavoriteReactor {
    func productsToReactors(products: [Product]) -> [ProductCollectionViewCellReactor] {
        return products.map {
            ProductCollectionViewCellReactor(
                product: $0,
                likeUseCase: likeUseCase,
                productsCellEventReplay: productsCellEventRelay
            )
        }
    }
    
    func fetchItem(query: String) -> Observable<[ProductCollectionViewCellReactor]> {
        let products = if query.isEmpty {
            favoriteUseCase.fetchAllLikeProducts()
        } else {
            favoriteUseCase.fetchQueryLikeProducts(query: query)
        }
        
        return products
            .asObservable()
            .compactMap { [weak self] in self?.productsToReactors(products: $0)}
            .do(
                onNext: { [weak self] _ in self?.sideEffectEventRelay.accept(.setQuery(query)) },
                onError: { [weak self] in self?.sideEffectEventRelay.accept(.error($0)) }
            )
    }
}
    
