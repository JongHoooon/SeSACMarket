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
    }
    
    struct State {
        @Pulse
        var scrollContentOffset: CGPoint?
        var query: String?
        var productsCellViewModels: [ProductCollectionViewCellReactor]?
    }
        
    private let productLocalUseCase: ProductLocalFetchUseCase
    private let likeUseCase: LikeUseCase
    private weak var coordinator: FavoriteCoordinator?
    private let productsCellEventRelay: PublishRelay<ProductsCellEvent>
    let initialState: State
    
    init(
        productLocalUseCase: ProductLocalFetchUseCase,
        likeUseCase: LikeUseCase,
        coordinator: FavoriteCoordinator
    ) {
        self.productLocalUseCase = productLocalUseCase
        self.likeUseCase = likeUseCase
        self.coordinator = coordinator
        self.productsCellEventRelay = PublishRelay()
        self.initialState = State()
    }
}

extension FavoriteReactor {
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let productsCellEventMutation = productsCellEventRelay
            .flatMap { [weak self] productsCellEvent in
                self?.muate(productsCellEvent: productsCellEvent) ?? .empty()
            }
        
        return .merge(mutation, productsCellEventMutation)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return fetchProduct().map { .setProductsCellViewModels($0) }
            
        case let .searchTextInput(query):
            return .concat([
                .just(.setQuery(query)),
                fetchProduct().map { .setProductsCellViewModels($0) },
                .just(.scrollToTop)
            ])
            
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
        case .needReload:
            return fetchProduct().map { .setProductsCellViewModels($0) }
        case let .error(error):
            print(error.localizedDescription)
            coordinator?.presnetErrorMessageAlert(error: error)
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .scrollToTop:
            newState.scrollContentOffset = .zero
            
        case let .setProductsCellViewModels(viewModels):
            newState.productsCellViewModels = viewModels
            
        case let .setQuery(query):
            newState.query = query
        }
        
        return newState
    }
}

private extension FavoriteReactor {
    func fetchProduct() -> Observable<[ProductCollectionViewCellReactor]> {
        return Observable.create { [weak self] observer in
            guard let self,
                  let errorHandler = coordinator?.presnetErrorMessageAlert(error:),
                  let query = currentState.query
            else {
                return Disposables.create()
            }
            
            if query.isEmpty {
                Task {
                    let products = await self.productLocalUseCase.fetchAllLikeProducts()
//                    let reactors = try? await products.asyncMap {
//
//                        let isLike = await self.likeUseCase.isLikeProduct(productID: $0.id)
//                        
//                        ProductCollectionViewCellReactor(
//                            product: $0, 
//                            isLike: isLike,
//                            likeUseCase: self.likeUseCase,
//                            errorHandler: errorHandler,
//                            productsCellEventReplay: self.productsCellEventRelay
//                        )
//                    }
                    observer.onNext([])
                }
            } else {
//                Task {
//                    let products = await self.productLocalUseCase.fetchQueryLikeProducts(query: query)
//                    let viewModels = products.map {
//                        ProductCollectionViewCellReactor(
//                            product: $0, 
//                            isLike: <#Bool#>,
//                            likeUseCase: self.likeUseCase,
//                            errorHandler: errorHandler,
//                            productsCellEventReplay: self.productsCellEventRelay
//                        )
//                    }
//                    observer.onNext(viewModels)
//                }
                observer.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
