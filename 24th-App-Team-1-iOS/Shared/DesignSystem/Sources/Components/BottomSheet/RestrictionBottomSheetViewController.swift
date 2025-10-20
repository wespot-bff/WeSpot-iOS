//
//  RestrictionBottomSheetViewController.swift
//  DesignSystem
//
//  Created by 김도현 on 10/20/25.
//


import UIKit

import SnapKit
import RxSwift
import ReactorKit
import RxCocoa
import Then
import CommonDomain



public final class RestrictionBottomSheetViewReactor: Reactor {
    
    public var initialState: State
    
    public enum Action {
        case confirm
        case inquire
    }
    
    public enum Mutation {
        case dismiss
    }
    
    public struct State {
        let restrictionEntity: RestrictionsEntity
    }
    
    public init(restrictionEntity: RestrictionsEntity) {
        self.initialState = State(restrictionEntity: restrictionEntity)
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .confirm, .inquire:
            return .just(.dismiss)
        }
    }
}


public final class RestrictionBottomSheetViewController: UIViewController, View {
    
    private let containerView: UIView = UIView()
    private let titleLabel: WSLabel = WSLabel(wsFont: .Header02)
    private let contentTextView: UITextView = UITextView()
    private let buttonStackView: UIStackView = UIStackView()
    private let confirmButton: WSButton = WSButton(wsButtonType: .default(12))
    private let inquiryButton: WSButton = WSButton(wsButtonType: .secondaryButton)
    
    public var disposeBag = DisposeBag()
    
    public init(reactor: RestrictionBottomSheetViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAutoLayout()
        setupAttributes()
    }
    
    private func setupUI() {
        view.addSubview(containerView)
        containerView.addSubviews(titleLabel, contentTextView, buttonStackView)
        buttonStackView.addArrangedSubview(inquiryButton)
        buttonStackView.addArrangedSubview(confirmButton)
    }
    
    private func setupAutoLayout() {
        containerView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(400)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        contentTextView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.greaterThanOrEqualTo(100)
        }
        
        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(contentTextView.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(52)
        }
        
        confirmButton.snp.makeConstraints {
            $0.height.equalTo(52)
        }
        
        inquiryButton.snp.makeConstraints {
            $0.height.equalTo(52)
        }
    }
    
    private func setupAttributes() {
        view.do {
            $0.backgroundColor = .black.withAlphaComponent(0.6)
        }
        
        containerView.do {
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
            $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            $0.backgroundColor = DesignSystemAsset.Colors.gray600.color
        }
        
        titleLabel.do {
            $0.textColor = DesignSystemAsset.Colors.gray100.color
            $0.textAlignment = .left
        }
        
        
        contentTextView.do {
            $0.textColor = DesignSystemAsset.Colors.gray300.color
            $0.backgroundColor = .clear
            $0.font = WSFont.Body06.font()
            $0.isEditable = false
            $0.isScrollEnabled = false
            $0.textContainerInset = .zero
            $0.textContainer.lineFragmentPadding = 0
        }
        
        buttonStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.distribution = .fillEqually
        }
        
        confirmButton.do {
            $0.setupFont(font: .Body03)
        }
        
        inquiryButton.do {
            $0.setupFont(font: .Body03)
            $0.setupButton(text: "1:1 문의하기")
        }
    }
    
    public func bind(reactor: RestrictionBottomSheetViewReactor) {
        reactor.state.map { $0.restrictionEntity }
            .take(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] entity in
                self?.configure(with: entity)
            })
            .disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .map { Reactor.Action.confirm }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        inquiryButton.rx.tap
            .map { Reactor.Action.inquire }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map { _ in () }
            .skip(1)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func configure(with entity: RestrictionsEntity) {
        titleLabel.text = entity.restrictionTitle
        
        let detailText = entity.restrictionDetails.joined(separator: "\n\n")
        contentTextView.text = detailText
        
        confirmButton.setupButton(text: entity.confirmButtonText)
        inquiryButton.isHidden = !entity.showInquiryButton

        if !entity.showInquiryButton {
            buttonStackView.distribution = .fill
        }
    }
}
