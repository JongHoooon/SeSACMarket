//
//  SearchReactor.swift
//  SeSACMarket
//
//  Created by JongHoon on 11/26/23.
//

import Foundation

import ReactorKit

import RxSwift
import RxRelay

final class SearchReactor: Reactor {
    enum Action {
        case viewDidLoad
        case searchButtonClicked(query: String)
        case sortSelected(Product.SortValue)
        case prefetchItems(IndexPath)
        case productCollectionViewWillDisplayIndexPath(IndexPath)
        case cancelButtonClicked
        case productsCellSelected(Product)
    }
    
    enum Mutation {
        case setSearchQuery(String)
        case setIndicator(Bool)
        case setFirstProductsPage(ProductsPage)
        case setProductsPage(ProductsPage)
        case scrollToTop
    }
    
    struct State {
        var productsCellViewModels: [ProductCollectionViewCellViewModel] = []
        var scrollContentOffset: CGPoint = .zero
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
                
                searchProducts(
                    query: query,
                    sortValue: currentState.selectedSortValue,
                    start: 1,
                    display: 30
                )
                .observe(on: MainScheduler.asyncInstance)
                .map { page in .setFirstProductsPage(page) },
                
                .just(.setIndicator(false)),

                .just(.scrollToTop)
            ])

        default:
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
            newState.isEndPage = false
            newState.productsCellViewModels = productsPage.items.map {
                ProductCollectionViewCellViewModel(
                    prodcut: $0,
                    likeUseCase: likeUseCase,
                    errorHandler: nil
                )
            }
            
        case .scrollToTop:
            newState.scrollContentOffset = .zero
            
        case .setProductsPage(_):
            break
        }
        
        return newState
    }
    
}

private extension SearchReactor {
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
            }
        )
        .asObservable()
    }
}
