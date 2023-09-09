//
//  SearchViewController.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/07.
//

import UIKit

import RxCocoa
import RxSwift
import SnapKit

final class SearchViewController: BaseViewController {
    
    // MARK: - Properties
    let viewModel: SearchViewModel
    let disposeBag = DisposeBag()
    
    // MARK: - UI
    private let searchBar = DefaultSearchBar()
    private let cancelButton = ButtonStyle1(title: "취소")
    
    // MARK: - Init
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.viewDidLoad()
    }
    
    // MARK: - Configure
    override func configure() {
        super.configure()
        
        [
            searchBar,
            cancelButton
        ].forEach { view.addSubview($0) }
    }
    
    override func configureLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().inset(8.0)
            $0.trailing.equalTo(cancelButton.snp.leading)
        }
        
        cancelButton.snp.makeConstraints {
            $0.centerY.equalTo(searchBar)
            $0.trailing.equalToSuperview().inset(8.0)
        }
        cancelButton.setContentCompressionResistancePriority(
            .defaultHigh,
            for: .horizontal
        )
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "쇼핑 검색"
    }
}
