//
//  LoginViewModel.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/12.
//

import Foundation

import RxSwift

struct LoginViewModelActions {
    let showTabBar: () -> Void
}

final class LoginViewModel: ViewModelProtocol {
    
    struct Input {
        let loginButtonTapped: Observable<Void>
    }
    
    struct Output {
        
    }
    
    // MARK: - Properties
    let actions: LoginViewModelActions
    
    // MARK: - Init
    init(actions: LoginViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.loginButtonTapped
            .asSignal(onErrorJustReturn: Void())
            .emit(
                with: self,
                onNext: { owner, _ in
                    owner.actions.showTabBar()
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
