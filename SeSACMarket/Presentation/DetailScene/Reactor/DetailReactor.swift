//
//  DetailReactor.swift
//  SeSACMarket
//
//  Created by JongHoon on 11/27/23.
//

import Foundation

import ReactorKit
import RxSwift
import RxRelay

final class DetailReactor: Reactor {
    enum Action {
        case viewDidLoad
        case webViewDidFinish
        case webViewDidFail(Error)
        case likeButtonTapped(Bool)
    }
    
    enum Mutation {
        case setIsLike(Bool)
        case setIsLikeWithAnimation(Bool)
        case setURLRequest(URLRequest?)
        case setIndicator(Bool)
    }
    
    struct State {
        var webViewRequest: URLRequest?
        var isIndicatorAnimating: Bool
        var likeButtonIsSelected: Bool
        var lkieButtonIsSelectedAnimation: Bool
    }
    
    enum ErrorEvent {
        case error(Error)
    }
    
    private let product: Product
    private let likeUseCase: LikeUseCase
    private weak var coordinator: DetailCoordinator?
    let title: String
    let initialState: State
    private let errorEventRelay: PublishRelay<ErrorEvent>
    private let notificationEventRelay: PublishRelay<NotificationEvent>
    private let disposeBag: DisposeBag
    
    init(
        product: Product,
        likeUseCase: LikeUseCase,
        coordinator: DetailCoordinator
    ) {
        self.product = product
        self.likeUseCase = likeUseCase
        self.coordinator = coordinator
        self.title = product.title
        self.errorEventRelay = PublishRelay()
        self.notificationEventRelay = PublishRelay()
        self.disposeBag = DisposeBag()
        self.initialState = State(
            isIndicatorAnimating: false,
            likeButtonIsSelected: false,
            lkieButtonIsSelectedAnimation: false
        )
        registerNotification()
    }
    
    deinit {
        coordinator?.finish()
        print("Deinit - \(String(describing: #fileID.components(separatedBy: "/").last ?? ""))")
    }
}

extension DetailReactor {
    
    func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let errorEventMutation = errorEventRelay
            .flatMap { [weak self] errorEvent in
                self?.mutate(errorEvent: errorEvent) ?? .empty()
            }
        
        let notificationEventMutation = notificationEventRelay
            .flatMap { [weak self] notificationEvent in
                self?.mutate(notificationEvent: notificationEvent) ?? .empty()
            }
        
        return .merge(mutation, errorEventMutation, notificationEventMutation)
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return .concat([
                .just(.setIndicator(true)),
                productURLRequest().map { .setURLRequest($0) },
                isLike().map { .setIsLike($0) },
            ])
            
        case .webViewDidFinish:
            return .just(.setIndicator(false))
            
        case let .webViewDidFail(error):
            errorEventRelay.accept(.error(error))
            return .empty()
            
        case let .likeButtonTapped(bool):
            return toggleLike(currentSelected: bool)
                .map { .setIsLikeWithAnimation($0) }
            
        }
    }
    
    func mutate(errorEvent: ErrorEvent) -> Observable<Mutation> {
        switch errorEvent {
        case let .error(error):
            print(error)
            coordinator?.presnetErrorMessageAlert(error: error)
            return .just(.setIndicator(false))
        }
    }
    
    func mutate(notificationEvent: NotificationEvent) -> Observable<Mutation> {
        switch notificationEvent {
        case let .likeButtonTapped(bool):
            return .just(.setIsLike(bool))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setIsLike(bool):
            newState.likeButtonIsSelected = bool
            
        case let .setIsLikeWithAnimation(bool):
            newState.lkieButtonIsSelectedAnimation = bool
            
        case let .setURLRequest(request):
            newState.webViewRequest = request
            
        case let .setIndicator(bool):
            newState.isIndicatorAnimating = bool
        }
        
        return newState
    }
}

private extension DetailReactor {
    
    func registerNotification() {
        NotificationCenter.default.rx.notification(.likeProduct)
            .bind(with: self, onNext: { owner, notification in
                let userInfo = notification.userInfo
                guard let id = userInfo?["id"] as? String,
                      let isSelected = userInfo?["isSelected"] as? Bool
                else { return }
                
                if owner.product.id == id {
                    self.notificationEventRelay.accept(.likeButtonTapped(isSelected))
                }
            })
            .disposed(by: disposeBag)
    }
    
    func productURLRequest() -> Observable<URLRequest?> {
        if let url = URL(string: "https://msearch.shopping.naver.com/product/\(product.id)") {
            let request = URLRequest(url: url)
            return .just(request)
        } else {
            return .just(nil)
        }
    }
    
    func isLike() -> Observable<Bool> {
//        return Observable.create { [weak self] observer in
//            guard let self else { return Disposables.create() }
//            Task {
//                let result = await self.likeUseCase.isLikeProduct(productID: self.product.id)
//                observer.onNext(result)
//            }
//            return Disposables.create()
//        }
        return .just(false)
    }
    
    func toggleLike(currentSelected: Bool) -> Observable<Bool> {
        return .just(false)
//        return Observable.create { [weak self] observer in
//            guard let self else { return Disposables.create() }
//            
//            switch currentSelected {
//            case true: // 삭제
//                Task {
//                    do {
//                        try await self.likeUseCase.deleteLikeProduct(productID: self.product.id)
//                        observer.onNext(false)
//                    } catch {
//                        self.errorEventRelay.accept(.error(error))
//                    }
//                }
//            case false: // 저장
//                Task {
//                    do {
//                        try await self.likeUseCase.saveLikeProduct(product: self.product)
//                        observer.onNext(true)
//                    } catch {
//                        self.errorEventRelay.accept(.error(error))
//                    }
//                }
//            }
//            
//            return Disposables.create()
//        }
    }
}
