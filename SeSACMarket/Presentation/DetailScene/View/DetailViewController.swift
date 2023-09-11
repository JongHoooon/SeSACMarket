//
//  DetailViewController.swift
//  SeSACMarket
//
//  Created by JongHoon on 2023/09/11.
//

import UIKit
import WebKit

import RxSwift
import RxCocoa

final class DetailViewController: BaseViewController {
    
    // MARK: - Properties
    private let viewModel: DetailViewModel
    private let disposeBag = DisposeBag()
    
    // MARK: - UI
    private let likeButton: LikeButton = {
        let button = LikeButton(isDetailView: true)
        return button
    }()
    
    private lazy var webView: WKWebView = {
        let webView = WKWebView(
            frame: .zero,
            configuration: WKWebViewConfiguration()
        )
        return webView
    }()
    private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.isHidden = true
        return indicator
    }()

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
    
    // MARK: - Configure
    override func configure() {
        super.configure()
        bind()
        [
            webView,
            indicator
        ].forEach { view.addSubview($0) }
    }
    
    override func configureLayout() {
        webView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        indicator.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    override func configureNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: likeButton)
    }
}

private extension DetailViewController {
    
    func bind() {

        let likeButtonTapped = likeButton.rx.tap
            .map { [weak self] _ in
                return self?.likeButton.isSelected
            }
            .compactMap { $0 }

        let input = DetailViewModel.Input(
            viewDidLoad: self.rx.viewDidLoad.asObservable(),
            webViewDidFinish: webView.rx.didFinishLoad.map { _ in }.asObservable(),
            webViewDidFail: webView.rx.didFailLoad.map(\.1).asObservable(),
            likeButtonTapped: likeButtonTapped
        )
        
        let output = viewModel.transform(input: input, disposeBag: disposeBag)
        
        output.title
            .asDriver()
            .drive(navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        output.webViewRequest
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: webView.rx.load)
            .disposed(by: disposeBag)
        
        output.isIndicatorAnimating
            .asDriver()
            .drive(indicator.rx.isShowAndAnimating)
            .disposed(by: disposeBag)
        
        output.likeButtonIsSelected
            .asDriver()
            .distinctUntilChanged()
            .drive(likeButton.rx.isSelected)
            .disposed(by: disposeBag)
        
        output.likeButtonIsSelectWithAnimation
            .asSignal()
            .distinctUntilChanged()
            .emit(to: likeButton.rx.selectWithAnimation)
            .disposed(by: disposeBag)
        
        output.errorHandlerRelay
            .asSignal()
            .emit(to: self.rx.defaultErrorHandler)
            .disposed(by: disposeBag)
    }
}
