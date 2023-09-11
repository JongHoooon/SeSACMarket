//
//  DetailViewModel.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/11.
//

import Foundation

import RxSwift
import RxRelay

final class DetailViewModel: ViewModelProtocol {
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let webViewDidFinish: Observable<Void>
        let webViewDidFail: Observable<Error>
        let likeButtonTapped: Observable<Bool>
    }
    
    struct Output {
        let title = BehaviorRelay(value: "")
        let webViewRequest = BehaviorRelay<URLRequest>(value: URLRequest(url: URL(string: "sesac.com")!))
        let isIndicatorAnimating = BehaviorRelay<Bool>(value: false)
        let likeButtonIsSelected = BehaviorRelay<Bool>(value: false)
        let likeButtonIsSelectWithAnimation = PublishRelay<Bool>()
        let errorHandlerRelay = PublishRelay<Error>()
    }
    
    private let product: Product
    private let productLocalUseCase: ProductLocalUseCase
    
    init(
        product: Product,
        productLocalUseCase: ProductLocalUseCase
    ) {
        self.product = product
        self.productLocalUseCase = productLocalUseCase
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        
        let output = Output()
        
        input.viewDidLoad
            .observe(on: ConcurrentDispatchQueueScheduler(queue: .global()))
            .bind(
                with: self,
                onNext: { owner, _ in
                    output.title.accept(owner.product.title)
                    
                    Task {
                        let result = await owner.productLocalUseCase.isLikeProduct(productID: owner.product.productID)
                        output.likeButtonIsSelected.accept(result)
                    }
                    
                    if let url = URL(string: "https://msearch.shopping.naver.com/product/\(owner.product.productID)") {
                        let request = URLRequest(url: url)
                        output.webViewRequest.accept(request)
                    }
                    
                    output.isIndicatorAnimating.accept(true)
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(.likeProduct)
            .bind(with: self, onNext: { owner, notification in
                let userInfo = notification.userInfo
                guard let id = userInfo?["id"] as? Int,
                      let isSelected = userInfo?["isSelected"] as? Bool
                else { return }
                
                if owner.product.productID == id {
                    output.likeButtonIsSelected.accept(isSelected)
                }
            })
            .disposed(by: disposeBag)
        
        input.webViewDidFinish
            .bind(onNext: { _ in
                output.isIndicatorAnimating.accept(false)
            })
            .disposed(by: disposeBag)
        
        input.webViewDidFail
            .bind(onNext: { error in
                output.isIndicatorAnimating.accept(false)
                output.errorHandlerRelay.accept(error)
            })
            .disposed(by: disposeBag)
        
        input.likeButtonTapped
            .bind(
                with: self,
                onNext: { owner, currentSelected in
                    switch currentSelected {
                    case true: // 삭제
                        Task {
                            do {
                                try await owner.productLocalUseCase.deleteLikeProduct(productID: owner.product.productID)
                                
                            } catch {
                                output.errorHandlerRelay.accept(error)
                                return
                            }
                        }
                    case false: // 저장
                        Task {
                            do {
                                try await owner.productLocalUseCase.saveLikeProduct(product: owner.product)
                            } catch {
                                output.errorHandlerRelay.accept(error)
                                return
                            }
                        }
                    }
                    output.likeButtonIsSelectWithAnimation.accept(!currentSelected)
                    NotificationCenter.default.post(
                        name: .likeProduct,
                        object: nil,
                        userInfo: [
                            "id": owner.product.productID,
                            "isSelected": !currentSelected
                        ]
                    )
            })
            .disposed(by: disposeBag)
            
        return output
    }
}
