//
//  LogoutViewModel.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/12.
//

import Foundation

import RxSwift

final class LogoutViewModel: ViewModelProtocol {
    
    struct Input {
        let logoutButtonTapped: Observable<Void>
        let dismissButtonTapped: Observable<Void>
        let viewDidDismiss: Observable<Void>
    }
    
    struct Output {
        
    }
    
    // MARK: - Properties
    private weak var coordinator: SettingCoordinator?
    
    // MARK: - Init
    init(coordinator: SettingCoordinator) {
        self.coordinator = coordinator
    }
    
    deinit {
        print("Deinit - \(String(describing: #fileID.components(separatedBy: "/").last ?? ""))")
    }
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output {
        let output = Output()
        
        input.logoutButtonTapped
            .asSignal(onErrorJustReturn: Void())
            .emit(
                with: self,
                onNext: { owner, _ in
                    UserDefaults.standard.set(
                        false,
                        forKey: UserDefaultsKey.isLoggedIn.key
                    )
                    owner.coordinator?.showAuth()
            })
            .disposed(by: disposeBag)
        
        input.dismissButtonTapped
            .asDriver(onErrorJustReturn: Void())
            .drive(
                with: self,
                onNext: { owner, _ in
                    owner.coordinator?.dismiss()
            })
            .disposed(by: disposeBag)
        
        input.viewDidDismiss
            .bind(
                with: self,
                onNext: { owner, _ in
                    owner.coordinator?.finish()
            })
            .disposed(by: disposeBag)
            
        return output
    }
}
