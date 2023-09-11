//
//  FavoriteViewModel.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/10.
//

import Foundation

import RxSwift
import RxRelay

final class FavoriteViewModel: ViewModelProtocol {
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let searchTextInput: Observable<String>
        let cancelButtonClicked: Observable<Void>
    }
    
    struct Output {
        let productsCellViewModelsRelay = BehaviorRelay<[ProductCollectionViewCellViewModel]>(value: [])
        let scrollContentOffsetRelay = PublishRelay<CGPoint>()
        let searchBarEndEditting = PublishRelay<Void>()
    }
    
    private let needReload = PublishRelay<Void>()
    private var currentQuery: String = ""
    
    let productLocalUseCase: ProductLocalUseCase
    
    init(productLocalUseCase: ProductLocalUseCase) {
        self.productLocalUseCase = productLocalUseCase
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
                            productLocalUseCase: productLocalUseCase,
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
                            productLocalUseCase: productLocalUseCase,
                            needReload: needReload
                        )
                    }
                    output.productsCellViewModelsRelay.accept(viewModels)
                }
            }
        }
    }
}
 
