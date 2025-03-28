//
//  MessageContentToastView.swift
//  MessageFeature
//
//  Created by 최지철 on 1/15/25.
//

import UIKit
import DesignSystem

import SnapKit
import RxSwift
import RxCocoa

final class MessageContentToastViewController: UIViewController {
    
    
    private let disposeBag = DisposeBag()
    
    // MARK: - UI Properties
    
    private let fromLabel = WSLabel(wsFont: .Body04, textAlignment: .right).then {
        $0.textColor = DesignSystemAsset.Colors.gray100.color
    }
    private let toLabel = WSLabel(wsFont: .Body04, textAlignment: .left).then {
        $0.textColor = DesignSystemAsset.Colors.gray100.color
    }
    private let contentLabel = TopRightWSLabel(wsFont: .Body04, textAlignment: .natural).then {
        $0.textColor = DesignSystemAsset.Colors.gray100.color
    }
    private let messageContentView = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.gray600.color
        $0.layer.cornerRadius = 20
        $0.layer.borderWidth = 1
        $0.layer.borderColor = DesignSystemAsset.Colors.primary400.color.cgColor
    }
    let dismissButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.setImage(DesignSystemAsset.Images.icXmark.image, for: .normal)
    }
    
    // MARK: - Properties
    private let toText: String
    private let fromText: String
    private let contentText: String
    
    // MARK: - Initializers
    init(to: String, from: String, content: String) {
        self.toText = to
        self.fromText = from
        self.contentText = content
        super.init(nibName: nil, bundle: nil)
    }
    
    // nib나 스토리보드를 사용하지 않으므로 fatalError
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        configureTexts()
        bind()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        self.view.addSubview(messageContentView)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        messageContentView.addSubviews(fromLabel, toLabel, contentLabel, dismissButton)
    }
    
    private func setupConstraints() {
        messageContentView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(32)
            $0.centerY.equalToSuperview()
            $0.height.greaterThanOrEqualTo(376)
            $0.height.lessThanOrEqualTo(424)
        }
        dismissButton.snp.makeConstraints {
            $0.width.height.equalTo(40)
            $0.top.equalToSuperview().inset(8)
            $0.trailing.equalToSuperview().inset(8)
        }
        toLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.horizontalEdges.equalToSuperview().inset(28)
            $0.height.equalTo(48)
        }
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(toLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(28)
        }
        fromLabel.snp.makeConstraints {
            $0.top.equalTo(contentLabel.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(28)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview().inset(24)
        }
    }
    
    private func configureTexts() {
        toLabel.text = "To.\n\(toText)"
        fromLabel.text = "From.\n\(fromText)"
        contentLabel.text = contentText
    }
    
    private func bind() {
        dismissButton.rx.tap
            .bind(with: self) {  this, _ in
                this.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}
