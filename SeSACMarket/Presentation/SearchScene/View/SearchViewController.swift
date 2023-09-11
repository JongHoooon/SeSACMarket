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
    private let viewModel: DefaultSearchViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - UI
    private let searchBar = DefaultSearchBar()
    private let cancelButton = ButtonStyle1(title: "취소")
    private let sortCollectionView = SortCollectionView()
    private let productsCollectionView = ProductsCollectionView()
    
    // MARK: - Init
    init(
        viewModel: DefaultSearchViewModel
    ) {
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
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        productsCollectionView.configureLayout()
        sortCollectionView.configureLayout()
    }
    
    // MARK: - Configure
    override func configure() {
        super.configure()
        bind()
        sortCollectionView.selectItem(
            at: IndexPath(item: 0, section: 0),
            animated: false,
            scrollPosition: .top
        )
        [
            searchBar, cancelButton,
            sortCollectionView,
            productsCollectionView
        ].forEach { view.addSubview($0) }
    }
    
    override func configureLayout() {
        searchBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalToSuperview().inset(Constant.Inset.medium)
            $0.trailing.equalTo(cancelButton.snp.leading)
        }
        
        cancelButton.snp.makeConstraints {
            $0.centerY.equalTo(searchBar)
            $0.trailing.equalToSuperview().inset(Constant.Inset.medium)
        }
        cancelButton.setContentCompressionResistancePriority(
            .defaultHigh,
            for: .horizontal
        )
        
        sortCollectionView.snp.makeConstraints {
            $0.top.equalTo(searchBar.snp.bottom).offset(Constant.Inset.defaultInset)
            $0.height.equalTo(Constant.SortCell.height)
            $0.horizontalEdges.equalToSuperview()
        }
        
        productsCollectionView.snp.makeConstraints {
            $0.top.equalTo(sortCollectionView.snp.bottom).offset(Constant.Inset.defaultInset)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    override func configureNavigationBar() {
        navigationItem.title = "쇼핑 검색"
    }
}

// MARK: - Bind
private extension SearchViewController {
    func bind() {
        
        let input = DefaultSearchViewModel.Input(
            viewDidLoad: self.rx.viewDidLoad.asObservable(),
            searchButtonClicked: searchBar.rx.searchButtonClicked.asObservable(),
            searchBarText: searchBar.rx.text.orEmpty.asObservable(),
            sortSelected: sortCollectionView.rx.modelSelected(SortEnum.self).asObservable(),
            prefetchItems: productsCollectionView.rx.prefetchItems.asObservable(),
            productCollectionViewWillDisplayIndexPath: productsCollectionView.rx.willDisplayCell.map { $0.at }.asObservable(),
            cancelButtonClicked: cancelButton.rx.tap.asObservable(), produtsCellSelected: productsCollectionView.rx.modelSelected(ProductCollectionViewCellViewModel.self).map(\.prodcut)
        )
        
        let output = viewModel.transform(input: input, disposeBag: disposeBag)
        
        output.sortItemsRelay
            .asDriver()
            .distinctUntilChanged()
            .drive(sortCollectionView.rx.items(
                cellIdentifier: SortCollectionViewCell.identifier,
                cellType: SortCollectionViewCell.self
            )) { _, sort, cell in
                cell.configureCell(sort: sort)
            }
            .disposed(by: disposeBag)
        
        output.productsCellViewModelsRelay
            .asDriver()
            .drive(productsCollectionView.rx.items(
                cellIdentifier: ProductCollectionViewCell.identifier,
                cellType: ProductCollectionViewCell.self
            )) { _, viewModel, cell in
                cell.viewModel = viewModel
            }
            .disposed(by: disposeBag)
        
        output.scrollContentOffsetRelay
            .asSignal()
            .emit(to: productsCollectionView.rx.contentOffset)
            .disposed(by: disposeBag)
        
        output.isShowIndicator
            .asSignal()
            .distinctUntilChanged()
            .emit(to: self.rx.isShowIndicator)
            .disposed(by: disposeBag)
        
        output.searchBarEndEditting
            .asSignal()
            .emit(to: searchBar.rx.endEditing)
            .disposed(by: disposeBag)
        
        output.errorHandlerRelay
            .asSignal()
            .emit(to: self.rx.defaultErrorHandler)
            .disposed(by: disposeBag)
        
        productsCollectionView.rx.didEndDisplayingCell
            .subscribe(onNext: { event in
                guard let cell = event.cell as? ProductCollectionViewCell else { return }
                cell.cancelTask()
            })
            .disposed(by: disposeBag)
    }
}
