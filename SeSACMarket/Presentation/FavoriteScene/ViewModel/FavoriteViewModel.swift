//
//  FavoriteViewModel.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import Foundation

import RxSwift
import RxCocoa

struct FavoriteViewModelActions {
    let showDetail: (_ product: Product) -> Void
    let showSetting: () -> Void
}

final class FavoriteViewModel: ViewModelProtocol {
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let searchTextInput: Observable<String>
        let cancelButtonClicked: Observable<Void>
        let produtsCellSelected: Observable<Product>
        let settingButtonTapped: Observable<Void>
    }
    
    struct Output {
        let productsCellViewModelsRelay = BehaviorRelay<[ProductCollectionViewCellViewModel]>(value: [])
        let scrollContentOffsetRelay = PublishRelay<CGPoint>()
        let searchBarEndEditting = PublishRelay<Void>()
        let errorHandlerRelay = PublishRelay<Error>()
    }
    
    // MARK: - States
    private let needReload = PublishRelay<Void>()
    private var currentQuery: String = ""
    
    // MARK: - Properties
    private let productLocalUseCase: ProductLocalFetchUseCase
    private let likeUseCase: LikeUseCase
    private weak var coordinator: FavoriteCoordinator?
    
    init(
        productLocalUseCase: ProductLocalFetchUseCase,
        likeUseCase: LikeUseCase,
        coordinator: FavoriteCoordinator
    ) {
        self.productLocalUseCase = productLocalUseCase
        self.likeUseCase = likeUseCase
        self.coordinator = coordinator
    }
    
    deinit {
        print("Deinit - \(String(describing: #fileID.components(separatedBy: "/").last ?? ""))")
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.viewWillAppear
            .bind(onNext: { _ in
                fetchProduct()
            })
            .disposed(by: disposeBag)
        
        input.searchTextInput
            .bind(
                with: self,
                onNext: { owner, query in
                    owner.currentQuery = query
                    fetchProduct()
                    output.scrollContentOffsetRelay.accept(.zero)
            })
            .disposed(by: disposeBag)
        
        input.cancelButtonClicked
            .bind(onNext: { _ in
                output.searchBarEndEditting.accept(Void())
            })
            .disposed(by: disposeBag)
        
        input.produtsCellSelected
            .bind(
                with: self,
                onNext: { owner, product in
                    owner.coordinator?.showDetail(product: product)
            })
            .disposed(by: disposeBag)
        
        input.settingButtonTapped
            .asDriver(onErrorJustReturn: Void())
            .drive(
                with: self,
                onNext: { owner, _ in
                    owner.coordinator?.showSetting()
            })
            .disposed(by: disposeBag)
            
        
        needReload
            .bind(onNext: { _ in
                 fetchProduct()
            })
            .disposed(by: disposeBag)
        
        return output
        
        func fetchProduct() {
            if currentQuery.isEmpty {
                Task {
                    let products = await productLocalUseCase.fetchAllLikeProducts()
                    let viewModels = products.map {
                        ProductCollectionViewCellViewModel(
                            prodcut: $0,
                            likeUseCase: likeUseCase,
                            errorHandler: output.errorHandlerRelay,
                            needReload: needReload
                        )
                    }
                    output.productsCellViewModelsRelay.accept(viewModels)
                }
            } else {
                Task {
                    let products = await productLocalUseCase.fetchQueryLikeProducts(query: currentQuery)
                    let viewModels = products.map {
                        ProductCollectionViewCellViewModel(
                            prodcut: $0,
                            likeUseCase: likeUseCase,
                            errorHandler: output.errorHandlerRelay,
                            needReload: needReload
                        )
                    }
                    output.productsCellViewModelsRelay.accept(viewModels)
                }
            }
        }
    }
}
 
