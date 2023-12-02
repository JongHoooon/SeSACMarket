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
        case setFirstProductsPage(ProductsPage)
        case setProductsPage(ProductsPage)
        case setIsFetchEnable(Bool)
        case setCurrentPage(Int)
        case setSelectedSortValue(Product.SortValue)
        case setEndpage(Bool)
        case scrollToTop
    }
    
    struct State {
        @Pulse
        var scrollContentOffset: CGPoint = .zero
        var productsCellReactors: [ProductCollectionViewCellReactor] = []
        var searchBarEndEditting: Void = Void()
        var isShowIndicator: Bool = false
        var currentPage: Int = 1
        var isEndPage: Bool = false
        var searchQuery: String? = nil
        var selectedSortValue: Product.SortValue = .similarity
        var isFetchEnable: Bool = true
    }
    
    enum NetworkEvent {
        case setSearchQuery(query: String)
        case setCurrentPage(Int)
        case endFetching
        case error(Error)
    }
    
    let sorItems = Product.SortValue.allCases
    
    private let searchUseCase: SearchUseCase
    private let likeUseCase: LikeUseCase
    private weak var coordinator: SearchCoordinator?
    private let networkEventRelay: PublishRelay<NetworkEvent>
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
        
        return Observable.merge(mutation, networkEventMutation)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {            
        case let .searchButtonClicked(query):
            return .concat([
                .just(.setIsFetchEnable(false)),
                .just(.setIndicator(true)),
                
                searchUseCase.fetchProducts(
                    productsQuery: ProductQuery(query: query, sortValue: currentState.selectedSortValue),
                    start: 1
                )
                .asObservable()
                .do(
                    onNext: { [weak self] _ in
                        self?.networkEventRelay.accept(.setSearchQuery(query: query))
                    },
                    onError: { [weak self] in self?.networkEventRelay.accept(.error($0)) }
                )
                .map { page in .setFirstProductsPage(page) },
                
                .just(.setIndicator(false)),
                .just(.scrollToTop),
                .just(.setIsFetchEnable(true))
            ])
            
        case let .sortSelected(sortValue):
            guard let query = currentState.searchQuery else { return .empty() }
            return .concat([
                .just(.setIsFetchEnable(false)),
                .just(.setSelectedSortValue(sortValue)),
                .just(.setIndicator(true)),
                
                searchUseCase.fetchProducts(
                    productsQuery: ProductQuery(query: query, sortValue: sortValue),
                    start: 1
                )
                .asObservable()
                .do(
                    onNext: { [weak self] _ in
                        self?.networkEventRelay.accept(.setSearchQuery(query: query))
                    },
                    onError: { [weak self] in self?.networkEventRelay.accept(.error($0)) }
                )
                .map { page in .setFirstProductsPage(page) },
                
                .just(.setIndicator(false)),
                .just(.scrollToTop),
                .just(.setIsFetchEnable(true))
            ])
            
        case let .prefetchItems(indexPathes):
            prefetchImages(indexPathes: indexPathes)
            return .empty()

        case let .productCollectionViewWillDisplayIndexPath(indexPath):
            guard self.isEnablePrefetch(indexPath: indexPath)
                  , let query = currentState.searchQuery
            else { return .empty() }
            
            return .concat([
                .just(.setIsFetchEnable(false)),
                
                searchUseCase.fetchProducts(
                    productsQuery: ProductQuery(query: query, sortValue: currentState.selectedSortValue),
                    start: currentState.currentPage + 1
                )
                .asObservable()
                .do(
                    onNext: { [weak self] _ in
                        guard let self else { return }
                        self.networkEventRelay.accept(.setCurrentPage(self.currentState.currentPage + 1))
                    },
                    onError: { [weak self] in self?.networkEventRelay.accept(.error($0)) }
                )
                .map { .setProductsPage($0) },
                
                .just(.setIsFetchEnable(true)),
            ])
            
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
            coordinator?.presnetErrorMessageAlert(error: error)
            return .empty()
            
        case .endFetching:
            return .just(.setIsFetchEnable(true))
            
        case let .setCurrentPage(page):
            return .just(.setCurrentPage(page))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setSearchQuery(query):
            newState.searchQuery = query
            
        case let .setIndicator(bool):
            newState.isShowIndicator = bool
            
        case let .setFirstProductsPage(productsPage):
            newState.currentPage = 1
            newState.isEndPage = productsPage.items.isEmpty
            newState.productsCellReactors = productsToReactors(products: productsPage.items)
            
        case .scrollToTop:
            newState.scrollContentOffset = .zero
            
        case let .setProductsPage(productPage):
            newState.isEndPage = productPage.items.isEmpty
            let newReactors = productsToReactors(products: productPage.items)
            newState.productsCellReactors.append(contentsOf: newReactors)
            
        case let .setIsFetchEnable(bool):
            newState.isFetchEnable = bool
            
        case let .setCurrentPage(page):
            newState.currentPage = page
            
        case let .setSelectedSortValue(sortValue):
            newState.selectedSortValue = sortValue
            
        case let .setEndpage(bool):
            newState.isEndPage = bool
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
                errorHandler: nil
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
        if currentState.isEndPage == false
            && currentState.isFetchEnable == true
            && maxIndex - 8 <= indexPath.item {
            return true
        } else {
            return false
        }
    }
}
