//
//  LoginViewModel.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/12.
//

import Foundation

import RxSwift

final class LoginViewModel: ViewModelProtocol {
    
    struct Input {
        let loginButtonTapped: Observable<Void>
    }
    
    struct Output {
        
    }
    
    // MARK: - Properties
    private weak var coordinator: AuthCoordinator?
    
    // MARK: - Init
    init(coordinator: AuthCoordinator) {
        self.coordinator = coordinator
    }
    
    deinit {
        print("Deinit - \(String(describing: #fileID.components(separatedBy: "/").last ?? ""))")
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.loginButtonTapped
            .asSignal(onErrorJustReturn: Void())
            .emit(
                with: self,
                onNext: { owner, _ in
                    UserDefaults.standard.set(
                        true,
                        forKey: UserDefaultsKey.isLoggedIn.key
                    )
                    owner.coordinator?.showTabBar()
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
