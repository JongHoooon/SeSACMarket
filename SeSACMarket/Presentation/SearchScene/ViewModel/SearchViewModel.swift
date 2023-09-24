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
        let sortSelected: Observable<SortEnum>
        let prefetchItems: Observable<[IndexPath]>
        let productCollectionViewWillDisplayIndexPath: Observable<IndexPath>
        let cancelButtonClicked: Observable<Void>
        let produtsCellSelected: Observable<Product>
    }
    
    struct Output {
        let sortItemsRelay = BehaviorRelay<[SortEnum]>(value: SortEnum.allCases)
        let productsCellViewModelsRelay = BehaviorRelay<[ProductCollectionViewCellViewModel]>(value: [])
        let scrollContentOffsetRelay = PublishRelay<CGPoint>()
        let searchBarEndEditting = PublishRelay<Void>()
        let isShowIndicator = PublishRelay<Bool>()
    }
    
    // MARK: - States
    private var page = 1
    private var isEndPage = false
    private var searchBarTextRelay: BehaviorRelay<String> = .init(value: "")
    private var selectedSortRelay: BehaviorRelay<SortEnum> = .init(value: .similarity)
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
        
        input.searchButtonClicked
            .withLatestFrom(input.searchBarText)
            .bind(
                with: self,
                onNext: { owner, text in
                    output.isShowIndicator.accept(true)
                    owner.searchBarTextRelay.accept(text)
                    fetchProducts(start: 1)
            })
            .disposed(by: disposeBag)
        
        input.sortSelected
            .bind(
                with: self,
                onNext: { owner, sort in
                    owner.selectedSortRelay.accept(sort)
                    
                    guard !owner.searchBarTextRelay.value.isEmpty
                    else { return }
                    output.isShowIndicator.accept(true)
                    fetchProducts(start: 1)
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
            .filter { [weak self] _ in
                self?.isEndPage == false && self?.isFetchEnable == true
            }
            .bind(
                with: self,
                onNext: { owner, indexPath in
                let maxIndex = output.productsCellViewModelsRelay.value.count
                if maxIndex - 5 == indexPath.item {
                    owner.isFetchEnable = false
                    owner.page += 1
                    fetchProducts(start: owner.page)
                }
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
        
        return output
        
        func fetchProducts(start: Int) {
            guard let errorHander = coordinator?.presnetErrorMessageAlert(error:) else { return }
            Task {
                do {
                    let productsPage = try await productRemoteFetchUseCase.fetchProducts(
                        query: searchBarTextRelay.value,
                        sort: selectedSortRelay.value,
                        start: start,
                        display: 30
                    )
                    let viewModels = productsPage.items.map {
                        
                        return ProductCollectionViewCellViewModel(
                            prodcut: $0,
                            likeUseCase: likeUseCase,
                            errorHandler: errorHander
                        )
                    }
                    if start == 1 {
                        isEndPage = false
                        output.productsCellViewModelsRelay.accept(viewModels)
                        output.scrollContentOffsetRelay.accept(.zero)
                    } else {
                        let currentViewModels = output.productsCellViewModelsRelay.value
                        output.productsCellViewModelsRelay.accept(currentViewModels+viewModels)
                    }
                    if productsPage.items.isEmpty {
                        isEndPage = true
                    }
                    output.isShowIndicator.accept(false)
                } catch {
                    output.isShowIndicator.accept(false)
                    coordinator?.presnetErrorMessageAlert(error: error)
                }
            }
            isFetchEnable = true
            output.searchBarEndEditting.accept(Void())
        }
    }
}
