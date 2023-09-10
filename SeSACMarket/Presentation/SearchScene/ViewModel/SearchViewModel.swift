//
//  SearchViewModel.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/09.
//

import Foundation

import Kingfisher
import RxSwift
import RxCocoa

struct SearchViewModelActions {
    
}

protocol SearchViewModelInput {
    func viewDidLoad()
    func searchButtonClicked()
    func prefetchItems(indexPaths: [IndexPath])
    var searchBarTextRelay: BehaviorRelay<String> { get }
    var selectedSortRelay: BehaviorRelay<SortEnum> { get }
}

protocol SearchViewModelOutput {
    var sortItemsRelay: BehaviorRelay<[SortEnum]> { get }
    var productsItemsRelay: BehaviorRelay<[ProductCollectionViewCellViewModel]>  { get }
    var scrollContentOffsetRelay: PublishRelay<CGPoint> { get }
}

protocol SearchViewModel: SearchViewModelInput, SearchViewModelOutput {}

final class DefaultSearchViewModel: SearchViewModel {

    private let productLocalRepository: ProductLocalRepository
    private let productRemoteUseCase: ProductRemoteUseCase
    private let actions: SearchViewModelActions
    private let disposeBag = DisposeBag()
    
    private var page = 1
    private var isEndPage = false
    
    init(
        productLocalRepository: ProductLocalRepository,
        productRemoteUseCase: ProductRemoteUseCase,
        actions: SearchViewModelActions
    ) {
        self.productLocalRepository = productLocalRepository
        self.productRemoteUseCase = productRemoteUseCase
        self.actions = actions
        bind()
    }
    
    // MARK: - Input
    func viewDidLoad() {
        
    }
    
    func searchButtonClicked() {
        page = 1
        isEndPage = false
        fetchProducts(isRefresh: true)
        scrollContentOffsetRelay.accept(.zero)
    }
    
    func prefetchItems(indexPaths: [IndexPath]) {
        let items = indexPaths.map { $0.item }
        
        var urls: [URL] = []
        items.forEach {
            if let url = URL(string: productsItemsRelay.value[$0].prodcut.imageURL) {
                urls.append(url)
            }
        }
        ImagePrefetcher(resources: urls).start()
        
        if items[0] > (productsItemsRelay.value.count - 5)
            && isEndPage == false {
            page += 1
            fetchProducts(isRefresh: false)
        }
    }
    
    var searchBarTextRelay: BehaviorRelay<String> = .init(value: "")
    var selectedSortRelay: BehaviorRelay<SortEnum> = .init(value: .similarity)
    
    // MARK: - Output
    var productsItemsRelay: BehaviorRelay<[ProductCollectionViewCellViewModel]> = .init(value: [])
    var sortItemsRelay: BehaviorRelay<[SortEnum]> = .init(value: SortEnum.allCases)
    var scrollContentOffsetRelay: PublishRelay<CGPoint> = .init()
}

private extension DefaultSearchViewModel {
    func fetchProducts(isRefresh: Bool) {
        Task {
            do {
                let productsPage = try await productRemoteUseCase
                    .fetchProducts(
                        query: searchBarTextRelay.value,
                        sort: selectedSortRelay.value,
                        start: page
                    )
                if isRefresh {
                    productsItemsRelay.accept(productsPage.items.map { ProductCollectionViewCellViewModel(
                        prodcut: $0,
                        productLocalRepository: productLocalRepository
                    )})
                } else {
                    let newItems = productsItemsRelay.value + productsPage.items.map { ProductCollectionViewCellViewModel(
                        prodcut: $0,
                        productLocalRepository: productLocalRepository
                    )}
                    productsItemsRelay.accept(newItems)
                }
                if productsPage.items.isEmpty {
                    isEndPage = true
                }
            } catch {
                print(error)
            }
        }
    }
}

private extension DefaultSearchViewModel {
    func bind() {
        selectedSortRelay
            .bind(
                with: self,
                onNext: { owner, _ in
                    guard !owner.searchBarTextRelay.value.trimmingCharacters(in: .whitespaces).isEmpty
                    else { return }
                    owner.fetchProducts(isRefresh: true)
                    owner.scrollContentOffsetRelay.accept(.zero)
            })
            .disposed(by: disposeBag)
    }
}
