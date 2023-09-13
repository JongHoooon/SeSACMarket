//
//  LogoutViewModel.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/12.
//

import Foundation

import RxSwift

struct LogoutViewModelActions {
    let showAuth: () -> Void
}

final class LogoutViewModel: ViewModelProtocol {
    
    struct Input {
        let logoutButtonTapped: Observable<Void>
    }
    
    struct Output {
        
    }
    
    // MARK: - Properties
    let actions: LogoutViewModelActions
    
    // MARK: - Init
    init(actions: LogoutViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.logoutButtonTapped
            .asSignal(onErrorJustReturn: Void())
            .emit(
                with: self,
                onNext: { owner, _ in
                    owner.actions.showAuth()
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
