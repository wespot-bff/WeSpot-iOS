//
//  MakeAnonymousProfilePopupViewController.swift
//  MessageFeature
//
//  Created by 최지철 on 4/17/25.
//

import UIKit
import Util
import DesignSystem
import MessageDomain

import Then
import SnapKit
import RxSwift
import RxCocoa

final class MakeAnonymousProfilePopupViewController: BaseViewController<AnonymousProfileReactor> {
    public var onProfileCreated: ((_ name: String, _ imageUrl: String, _ isAnonymous: Bool, _ profileImg: UIImage) -> Void)?
    private let contentView = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.gray600.color
        $0.layer.cornerRadius = 20
    }
    
    private let titleLabel = WSLabel(wsFont: .Body01, text: String.MessageTexts.makeAnonymousProfilePopTitle).then {
        $0.textAlignment = .center
    }
    private let imageView = UIImageView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.gray700.color
        $0.layer.cornerRadius = 43.3
        $0.contentMode = .scaleAspectFit
        $0.clipsToBounds = true
    }
    private let galleryButton = UIButton().then {
        $0.layer.cornerRadius = 12
        $0.backgroundColor = DesignSystemAsset.Colors.gray400.color
        $0.setImage(DesignSystemAsset.Images.icPhoto.image, for: .normal)
    }
    private let dismissButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Images.icXmark.image, for: .normal)
        $0.backgroundColor = .clear
    }

    private let makeProfileButton = WSButton(wsButtonType: .default(10))
    private let nickNameTextField = WSTextField(state: .default, placeholder: "닉네임을 입력해 주세요").then {
        $0.backgroundColor = .clear
        $0.borderStyle = .none
        $0.textColor = .white
    }
    private let underline = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.gray400.color
    }
    private let nameCountLabel = WSLabel(wsFont: .Body04, text: "0/10").then {
        $0.textColor = DesignSystemAsset.Colors.gray400.color
    }

    //MARK: - LifeCycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black.withAlphaComponent(0.6)
        self.navigationBar.isHidden = true
    }
    
    //MARK: - Functions
    
    public override func setupUI() {
        super.setupUI()
        self.view.addSubview(contentView)
        self.contentView.addSubviews(titleLabel,
                              dismissButton,
                              imageView,
                              galleryButton,
                              nickNameTextField,
                              makeProfileButton)
        nickNameTextField.addSubviews(nameCountLabel)
        nickNameTextField.addSubview(underline)

    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        
        contentView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalTo(409)
            $0.horizontalEdges.equalToSuperview().inset(32)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        imageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(87)
        }
        galleryButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.trailing.equalTo(imageView.snp.trailing).offset(-3)
            $0.bottom.equalTo(imageView.snp.bottom).offset(-2)
        }
        dismissButton.snp.makeConstraints{
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.size.equalTo(20)
        }
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(36)
            $0.horizontalEdges.equalToSuperview().inset(32)
            $0.height.equalTo(28)
        }
        nameCountLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.equalTo(40)
            $0.height.equalTo(20)
        }
        makeProfileButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-20)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
        underline.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        makeProfileButton.isEnabled = false
        makeProfileButton.setupButton(text: "설정완료")
    }
    
    public override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        bindState(reactor: reactor)
        bindAction(reactor: reactor)
    }
    
    private func bindState(reactor: Reactor) {
        reactor.state
            .map{$0.profileImage}
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: imageView.rx.image)
            .disposed(by: disposeBag)
        
        reactor.state.map {$0.userName}
            .observe(on: MainScheduler.instance)
            .bind(with:self) { this, name in
                if name.count > 0 {
                    this.makeProfileButton.isEnabled = true
                } else {
                    this.makeProfileButton.isEnabled = false
                }
                this.nameCountLabel.text = "\(name.count)/10"
            }
            .disposed(by: disposeBag)
    }
    
    private func bindAction(reactor: Reactor) {
        nickNameTextField.rx.text.orEmpty
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { this, text in
                reactor.action.onNext(.inputUserName(text))
            }
            .disposed(by: disposeBag)
        
        makeProfileButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(with: self) { this, _ in
                this.onProfileCreated?(reactor.currentState.userName, reactor.currentState.profileImageURL, true, reactor.currentState.profileImage)
                this.presentingViewController?.presentingViewController?.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        dismissButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(with: self) { this, _ in
                this.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
        
        galleryButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(with: self) { this, _ in
                print("갤러리 버튼 클릭")
                reactor.action.onNext(.setImageTapped(self))
            }
            .disposed(by: disposeBag)
    }
}
