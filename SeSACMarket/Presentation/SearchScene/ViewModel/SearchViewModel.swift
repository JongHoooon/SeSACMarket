//
//  SearchViewModel.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/09.
//

import Foundation

struct SearchViewModelActions {
    
}

protocol SearchViewModelInput {
    func viewDidLoad()
}

protocol SearchViewModelOutput {
    
}

protocol SearchViewModel: SearchViewModelInput, SearchViewModelOutput {}

final class DefaultSearchViewModel: SearchViewModel {

    private let productRemoteRepositoryUseCase: ProductRemoteUseCase
    private let actions: SearchViewModelActions
    
    init(
        productRemoteRepositoryUseCase: ProductRemoteUseCase,
        actions: SearchViewModelActions
    ) {
        self.productRemoteRepositoryUseCase = productRemoteRepositoryUseCase
        self.actions = actions
    }
    
    // MARK: - Input
    func viewDidLoad() {
        Task {
            do {
                let productsPage = try await productRemoteRepositoryUseCase
                    .fetchProducts(
                        query: "수박",
                        sort: .similarity,
                        start: 1
                    )
                print(productsPage)
            } catch {
                print(error)
            }
        }
    }
}
