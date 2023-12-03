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
        case likeButtonTapped
    }
    
    enum Mutation {
        case setIsLike(Bool)
        case setURLRequest(URLRequest?)
        case setIndicator(Bool)
    }
    
    struct State {
        var webViewRequest: URLRequest?
        var isIndicatorAnimating: Bool
        var likeButtonIsSelected: Bool?
    }
    
    enum ErrorEvent {
        case error(Error)
    }
    
    private let product: Product
    private let likeUseCase: LikeUseCase
    private weak var coordinator: DetailCoordinator?
    let title: String
    let initialState: State
    private let disposeBag: DisposeBag
    
    private let errorEventRelay: PublishRelay<ErrorEvent>
    private let notificationEventRelay: PublishRelay<NotificationEvent>
    
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
            isIndicatorAnimating: false
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
            return .concat(
                .just(.setIndicator(true)),
                
                productURLRequest()
                    .map { .setURLRequest($0) },
                
                likeUseCase.isLikeProduct(id: product.id)
                    .asObservable()
                    .do(onError: { [weak self] in self?.errorEventRelay.accept(.error($0)) })
                    .map { .setIsLike($0) }
            )
            
        case .webViewDidFinish:
            return .just(.setIndicator(false))
            
        case let .webViewDidFail(error):
            errorEventRelay.accept(.error(error))
            return .empty()
            
        case .likeButtonTapped:
            guard let isSelected = currentState.likeButtonIsSelected else { return .empty() }
            return likeUseCase.toggleProductLike(product: product, current: isSelected)
                .asObservable()
                .do(onError: { [weak self] in self?.errorEventRelay.accept(.error($0)) })
                .map { .setIsLike($0) }
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
}
