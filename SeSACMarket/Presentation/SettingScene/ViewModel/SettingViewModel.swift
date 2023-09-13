//
//  SettingViewModel.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/12.
//

import Foundation

import RxSwift

struct SettingViewModelActions {
    let showLogout: () -> Void
}

final class SettingViewModel: ViewModelProtocol {
    
    struct Input {
        let goLogoutButtonTapped: Observable<Void>
    }
    
    struct Output {
        
    }
    
    // MARK: - Properties
    let actions: SettingViewModelActions
    
    // MARK: - Init
    init(actions: SettingViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.goLogoutButtonTapped
            .asSignal(onErrorJustReturn: Void())
            .emit(
                with: self,
                onNext: { owner, _ in
                    owner.actions.showLogout()
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
