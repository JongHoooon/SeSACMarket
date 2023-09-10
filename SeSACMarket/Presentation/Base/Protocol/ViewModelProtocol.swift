//
//  ViewModelProtocol.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/11.
//

import RxSwift

protocol ViewModelProtocol {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input, disposeBag: DisposeBag) -> Output
}
