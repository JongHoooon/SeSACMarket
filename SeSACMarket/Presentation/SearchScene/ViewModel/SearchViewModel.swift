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

final class SearchViewModel: ViewModelProtocol {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let searchButtonClicked: Observable<Void>
        let searchBarText: Observable<String>
        let sortSelected: Observable<Product.SortValue>
        let prefetchItems: Observable<[IndexPath]>
        let productCollectionViewWillDisplayIndexPath: Observable<IndexPath>
        let cancelButtonClicked: Observable<Void>
        let produtsCellSelected: Observable<Product>
    }
    
    struct Output {
        let sortItemsRelay = BehaviorRelay<[Product.SortValue]>(value: Product.SortValue.allCases)
        let productsCellViewModelsRelay = BehaviorRelay<[ProductCollectionViewCellViewModel]>(value: [])
        let scrollContentOffsetRelay = PublishRelay<CGPoint>()
        let searchBarEndEditting = PublishRelay<Void>()
        let isShowIndicator = PublishRelay<Bool>()
    }
    
    // MARK: - States
    private var currentPageRelay = BehaviorRelay<Int>(value: 1)
    private var isEndPageRelay = BehaviorRelay<Bool>(value: true)
    private var currentQueryRelay = BehaviorRelay<String>(value: "")
    private var selectedSortRelay = BehaviorRelay<Product.SortValue>(value: .similarity)
    private var isFetchEnable = true
    
    // MARK: - Properties
    private let productRemoteFetchUseCase: ProductRemoteFetchUseCase
    private let likeUseCase: LikeUseCase
    private weak var coordinator: SearchCoordinator?
    
    init(
        productRemoteUseCase: ProductRemoteFetchUseCase,
        likeUseCase: LikeUseCase,
        coordinator: SearchCoordinator
    ) {
        self.productRemoteFetchUseCase = productRemoteUseCase
        self.likeUseCase = likeUseCase
        self.coordinator = coordinator
    }
    
    deinit {
        print("Deinit - \(String(describing: #fileID.components(separatedBy: "/").last ?? ""))")
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewDidLoad
            .subscribe(onNext: {
                
            })
            .disposed(by: disposeBag)
        
//        input.searchButtonClicked
//            .withLatestFrom(input.searchBarText)
//            .bind(
//                with: self,
//                onNext: { owner, query in
//                    output.isShowIndicator.accept(true)
//                    owner.currentQueryRelay.accept(query)
//                    owner.currentPageRelay.accept(1)
//                    owner.productRemoteFetchUseCase.fetchProducts(
//                        query: query,
//                        sort: owner.selectedSortRelay.value,
//                        start: 1,
//                        display: 30
//                    )
//            })
//            .disposed(by: disposeBag)
        
        input.sortSelected
            .distinctUntilChanged()
            .filter { [weak self] _ in self?.currentQueryRelay.value.isEmpty == false }
            .bind(
                with: self,
                onNext: { owner, sort in
                    output.isShowIndicator.accept(true)
                    owner.selectedSortRelay.accept(sort)
                    owner.currentPageRelay.accept(1)
                    owner.productRemoteFetchUseCase.fetchProducts(
                        query: owner.currentQueryRelay.value,
                        sort: sort,
                        start: 1,
                        display: 30
                    )
            })
            .disposed(by: disposeBag)
        
        input.prefetchItems
            .bind(
                with: self,
                onNext: { owner, indexPathes in
                    let items = indexPathes.map { $0.item }
                    
                    var urls: [URL] = []
                    items.forEach {
                        if let url = URL(string: output.productsCellViewModelsRelay.value[$0].prodcut.imageURL) {
                            urls.append(url)
                        }
                    }
                    ImagePrefetcher(resources: urls).start()
            })
            .disposed(by: disposeBag)
        
        input.productCollectionViewWillDisplayIndexPath
            .filter(isEnablePrefetch(indexPath:))
            .bind(
                with: self,
                onNext: { owner, indexPath in
                    owner.isFetchEnable = false
                    let currentPage = owner.currentPageRelay.value
                    owner.currentPageRelay.accept(currentPage + 1)
                    owner.productRemoteFetchUseCase.fetchProducts(
                        query: owner.currentQueryRelay.value,
                        sort: owner.selectedSortRelay.value,
                        start: currentPage+1,
                        display: 30
                    )
            })
            .disposed(by: disposeBag)
        
        input.cancelButtonClicked
            .bind(onNext: {
                output.searchBarEndEditting.accept(Void())
            })
            .disposed(by: disposeBag)
        
        input.produtsCellSelected
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(
                with: self,
                onNext: { owner, product in
                    owner.coordinator?.pushToDetail(product: product)
            })
            .disposed(by: disposeBag)
        
        let fetchProducts = productRemoteFetchUseCase.fetchProducts
            .share()
        
        fetchProducts
            .filter { isEndPage(prodctus: $0) == false }
            .map(productsToCellViewModels(newProducts:))
            .subscribe(
                with: self,
                onNext: { owner, viewModels in
                    output.productsCellViewModelsRelay.accept(viewModels)
                    output.isShowIndicator.accept(false)
                    owner.isFetchEnable = true
                    output.searchBarEndEditting.accept(Void())
                },
                onError: { owner, error in
                    owner.coordinator?.presnetErrorMessageAlert(error: error)
                    output.isShowIndicator.accept(false)
                    owner.isFetchEnable = true
                    output.searchBarEndEditting.accept(Void())
            })
            .disposed(by: disposeBag)
        
        fetchProducts
            .withLatestFrom(currentPageRelay.asObservable())
            .filter { $0 == 1 }
            .subscribe(
                with: self,
                onNext: { owner, _ in
                    owner.isEndPageRelay.accept(false)
                    output.scrollContentOffsetRelay.accept(.zero)
            })
            .disposed(by: disposeBag)
        
        return output
        
        func isEnablePrefetch(indexPath: IndexPath) -> Bool {
            let maxIndex = output.productsCellViewModelsRelay.value.count
            switch isEndPageRelay.value == false &&
                   isFetchEnable == true &&
                   maxIndex - 8 <= indexPath.item {
            case true:
                return true
            case false:
                return false
            }
        }
                
        func isEndPage(prodctus: [Product]) -> Bool {
            switch prodctus.isEmpty {
            case true:
                isEndPageRelay.accept(true)
                output.isShowIndicator.accept(false)
                return true
            case false:
                return false
            }
        }
        func productsToCellViewModels(
            newProducts: [Product]
        ) -> [ProductCollectionViewCellViewModel] {
            guard let errorHandler = coordinator?.presnetErrorMessageAlert(error:) else { return [] }
            let newViewModels = newProducts.map {
                return ProductCollectionViewCellViewModel(
                    prodcut: $0,
                    likeUseCase: likeUseCase,
                    errorHandler: errorHandler
                )}
            if currentPageRelay.value == 1 {
                return newViewModels
            } else {
                let currentViewModels = output.productsCellViewModelsRelay.value
                return currentViewModels + newViewModels
            }
        }
    }
}

