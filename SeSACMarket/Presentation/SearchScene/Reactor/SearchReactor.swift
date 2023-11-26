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
        case viewDidLoad
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
        var scrollContentOffset: CGPoint = .zero
        var productsCellViewModels: [ProductCollectionViewCellViewModel] = []
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
    
    private let productRemoteFetchUseCase: ProductRemoteFetchUseCase
    private let likeUseCase: LikeUseCase
    private weak var coordinator: SearchCoordinator?
    private let networkEventRelay: PublishRelay<NetworkEvent>
    let initialState: State
    
    init(
        productRemoteUseCase: ProductRemoteFetchUseCase,
        likeUseCase: LikeUseCase,
        coordinator: SearchCoordinator
    ) {
        self.productRemoteFetchUseCase = productRemoteUseCase
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
        case .viewDidLoad:
            print("viewdid load")
            return .empty()
            
        case let .searchButtonClicked(query):
            return .concat([
                .just(.setIndicator(true)),
                .just(.setIsFetchEnable(false)),
                
                searchProducts(
                    query: query,
                    sortValue: currentState.selectedSortValue,
                    start: 1,
                    display: 30
                )
                .map { page in .setFirstProductsPage(page) },
                
                .just(.setIndicator(false)),
                .just(.scrollToTop)
            ])
            
        case let .sortSelected(sortValue):
            guard let query = currentState.searchQuery else { return .empty() }
            return .concat([
                .just(.setSelectedSortValue(sortValue)),
                .just(.setIndicator(true)),
                .just(.setIsFetchEnable(false)),
                
                searchProducts(
                    query: query,
                    sortValue: sortValue,
                    start: 1,
                    display: 30
                )
                .map { page in .setFirstProductsPage(page) },
                
                .just(.setIndicator(false)),
                .just(.scrollToTop)
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
                .just(.setCurrentPage(currentState.currentPage + 1)),
                
                searchProducts(
                    query: query,
                    sortValue: currentState.selectedSortValue,
                    start: currentState.currentPage + 1,
                    display: 30
                )
                .map { .setProductsPage($0) }
            ])
            
        case .productsCellSelected(_):
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
            newState.productsCellViewModels = productsToViewModels(products: productsPage.items)
            
        case .scrollToTop:
            newState.scrollContentOffset = .zero
            
        case let .setProductsPage(productPage):
            newState.isEndPage = productPage.items.isEmpty
            let newViewModels = productsToViewModels(products: productPage.items)
            newState.productsCellViewModels.append(contentsOf: newViewModels)
            
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
    func productsToViewModels(products: [Product]) -> [ProductCollectionViewCellViewModel] {
        return products.map {
            ProductCollectionViewCellViewModel(
                prodcut: $0,
                likeUseCase: likeUseCase,
                errorHandler: nil
            )
        }
    }
    
    func searchProducts(
        query: String,
        sortValue: Product.SortValue,
        start: Int,
        display: Int
    ) -> Observable<ProductsPage> {
        return productRemoteFetchUseCase.fetchProducts(
            productsQuery: ProductQuery(
                query: query,
                sortValue: sortValue
            ),
            start: start,
            display: display
        )
        .do(
            onSuccess: { [weak self] page in
                self?.networkEventRelay.accept(.setSearchQuery(query: query))
            },
            onError: { [weak self] in
                self?.networkEventRelay.accept(.error($0))
            },
            onDispose: {
                self.networkEventRelay.accept(.endFetching)
            }
        )
        .catchAndReturn(ProductsPage(start: 1, display: 30, items: []))
        .asObservable()
    }
    
    func prefetchImages(indexPathes: [IndexPath]) {
        let items = indexPathes.map { $0.item }
        var urls: [URL] = []
        items.forEach {
            if let url = URL(string: currentState.productsCellViewModels[$0].prodcut.imageURL) {
                urls.append(url)
            }
        }
        ImagePrefetcher(resources: urls).start()
    }
    
    func isEnablePrefetch(indexPath: IndexPath) -> Bool {
        let maxIndex = currentState.productsCellViewModels.count
        if currentState.isEndPage == false
            && currentState.isFetchEnable == true
            && maxIndex - 8 <= indexPath.item {
            return true
        } else {
            return false
        }
    }
}
