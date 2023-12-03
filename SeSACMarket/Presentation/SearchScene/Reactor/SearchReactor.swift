//
//  SearchReactor.swift
//  SeSACMarket
//
//  Created by JongHoon on 11/26/23.
//

import Foundation

import ReactorKit

import Kingfisher
import RxSwift
import RxRelay

final class SearchReactor: Reactor {
    enum Action {
        case searchButtonClicked(query: String)
        case sortSelected(Product.SortValue)
        case prefetchItems([IndexPath])
        case productCollectionViewWillDisplayIndexPath(IndexPath)
        case productsCellSelected(Product)
    }
    
    enum Mutation {
        case setSearchQuery(String)
        case setIndicator(Bool)
        case setFirstPageProducts([Product])
        case setNextPageProducts([Product])
        case setIsFetchEnable(Bool)
        case setSelectedSortValue(Product.SortValue)
        case scrollToTop
    }
    
    struct State {
        @Pulse
        var scrollContentOffset: CGPoint = .zero
        var productsCellReactors: [ProductCollectionViewCellReactor] = []
        var isShowIndicator: Bool = false
        var searchQuery: String? = nil
        var selectedSortValue: Product.SortValue = .similarity
        var isFetchEnable: Bool = true
    }
    
    enum NetworkEvent {
        case setSearchQuery(query: String)
        case setSortValue(Product.SortValue)
        case error(Error)
    }
    
    let sorItems = Product.SortValue.allCases
    
    private let searchUseCase: SearchUseCase
    private let likeUseCase: LikeUseCase
    private weak var coordinator: SearchCoordinator?
    private let networkEventRelay: PublishRelay<NetworkEvent>
    private let productsCellEventRelay: PublishRelay<ProductsCellEvent>
    let initialState: State
    
    init(
        searchUseCase: SearchUseCase,
        likeUseCase: LikeUseCase,
        coordinator: SearchCoordinator
    ) {
        self.searchUseCase = searchUseCase
        self.likeUseCase = likeUseCase
        self.coordinator = coordinator
        self.networkEventRelay = PublishRelay()
        self.productsCellEventRelay = PublishRelay()
        self.initialState = State()
    }
    
    deinit {
        print("Deinit - \(String(describing: #fileID.components(separatedBy: "/").last ?? ""))")
    }
}

extension SearchReactor {
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let networkEventMutation = networkEventRelay
            .flatMap { [weak self] networkEvent -> Observable<Mutation> in
                self?.mutate(networkEvent: networkEvent) ?? .empty() 
            }
        
        let productsCellEventMutation = productsCellEventRelay
            .flatMap { [weak self] productsCellEvent in
                self?.muate(productsCellEvent: productsCellEvent) ?? .empty()
            }
        
        return Observable.merge(mutation, networkEventMutation, productsCellEventMutation)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {            
        case let .searchButtonClicked(query):
            return .concat(
                .just(.setIsFetchEnable(false)),
                .just(.setIndicator(true)),
                
                searchUseCase.fetchFirstPageProducts(productsQuery: ProductQuery(
                    query: query,
                    sortValue: currentState.selectedSortValue
                ))
                .asObservable()
                .do(onNext: { [weak self] _ in self?.networkEventRelay.accept(.setSearchQuery(query: query)) })
                .map { .setFirstPageProducts($0) },
                
                .just(.setIndicator(false)),
                .just(.scrollToTop),
                .just(.setIsFetchEnable(true))
            )
            .catch { [weak self] error in
                self?.networkEventRelay.accept(.error(error))
                return .concat(
                    .just(.setIndicator(false)),
                    .just(.setIsFetchEnable(true))
                )
            }
            
        case let .sortSelected(sortValue):
            guard let query = currentState.searchQuery else { return .empty() }
            return .concat(
                .just(.setIsFetchEnable(false)),
                .just(.setSelectedSortValue(sortValue)),
                .just(.setIndicator(true)),
                
                searchUseCase.fetchFirstPageProducts(productsQuery: ProductQuery(
                    query: query,
                    sortValue: sortValue
                ))
                .asObservable()
                .do(onNext: { [weak self] _ in self?.networkEventRelay.accept(.setSortValue(sortValue)) })
                .map { .setNextPageProducts($0) },
                
                .just(.setIndicator(false)),
                .just(.scrollToTop),
                .just(.setIsFetchEnable(true))
            )
            .catch { [weak self] error in
                self?.networkEventRelay.accept(.error(error))
                return .concat(
                    .just(.setIndicator(false)),
                    .just(.setIsFetchEnable(true))
                )
            }
            
        case let .prefetchItems(indexPathes):
            prefetchImages(indexPathes: indexPathes)
            return .empty()

        case let .productCollectionViewWillDisplayIndexPath(indexPath):
            guard self.isEnablePrefetch(indexPath: indexPath)
            else { return .empty() }
            
            return .concat(
                .just(.setIsFetchEnable(false)),
                
                searchUseCase.fetchNextPageProducts()
                    .asObservable()
                    .map { .setNextPageProducts($0) },
                
                .just(.setIsFetchEnable(true))
            )
            .catch { [weak self] error in
                self?.networkEventRelay.accept(.error(error))
                return .just(.setIsFetchEnable(true))
            }
            
        case let .productsCellSelected(product):
            coordinator?.pushToDetail(product: product)
            return .empty()
        }
    }
    
    func mutate(networkEvent: NetworkEvent) -> Observable<Mutation> {
        switch networkEvent {
        case let .setSearchQuery(query):
            return .just(.setSearchQuery(query))
            
        case let .error(error):
            print(error)
            coordinator?.presnetErrorMessageAlert(error: error)
            return .empty()
            
        case let .setSortValue(value):
            return .just(.setSelectedSortValue(value))
        }
    }
    
    func muate(productsCellEvent: ProductsCellEvent) -> Observable<Mutation> {
            switch productsCellEvent {
            case let .error(error):
                print(error.localizedDescription)
                coordinator?.presnetErrorMessageAlert(error: error)
                return .empty()
            default:
                return .empty()
            }
        }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setSearchQuery(query):
            newState.searchQuery = query
            
        case let .setIndicator(bool):
            newState.isShowIndicator = bool

        case .scrollToTop:
            newState.scrollContentOffset = .zero
            
        case let .setIsFetchEnable(bool):
            newState.isFetchEnable = bool
            
        case let .setSelectedSortValue(sortValue):
            newState.selectedSortValue = sortValue
            
        case let .setFirstPageProducts(products):
            newState.productsCellReactors = productsToReactors(products: products)
            
        case let .setNextPageProducts(products):
            newState.productsCellReactors.append(contentsOf: productsToReactors(products: products))
        }
        
        return newState
    }
    
}

private extension SearchReactor {
    func productsToReactors(products: [Product]) -> [ProductCollectionViewCellReactor] {
        return products.map {
            ProductCollectionViewCellReactor(
                product: $0,
                likeUseCase: likeUseCase,
                productsCellEventReplay: productsCellEventRelay
            )
        }
    }
    
    func prefetchImages(indexPathes: [IndexPath]) {
        let items = indexPathes.map { $0.item }
        var urls: [URL] = []
        items.forEach {
            if let url = URL(string: currentState.productsCellReactors[$0].initialState.product.imageURL) {
                urls.append(url)
            }
        }
        ImagePrefetcher(resources: urls).start()
    }
    
    func isEnablePrefetch(indexPath: IndexPath) -> Bool {
        let maxIndex = currentState.productsCellReactors.count
        if searchUseCase.isEndPage == false
            && currentState.isFetchEnable == true
            && maxIndex - 8 <= indexPath.item {
            return true
        } else {
            return false
        }
    }
}

