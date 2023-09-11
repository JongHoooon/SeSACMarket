//
//  DetailViewController.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/11.
//

import UIKit

import RxSwift
import RxCocoa

final class DetailViewController: BaseViewController {
    
    // MARK: - Properties
    private let viewModel: DetailViewModel
    private let disposeBag = DisposeBag()

    // MARK: - Init
    init(viewModel: DetailViewModel)
    {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
