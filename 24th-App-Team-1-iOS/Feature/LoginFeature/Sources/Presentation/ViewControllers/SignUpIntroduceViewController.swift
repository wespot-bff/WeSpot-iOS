//
//  SignUpIntroduceViewController.swift
//  LoginFeature
//
//  Created by Kim dohyun on 8/28/24.
//

import UIKit
import PhotosUI
import Util
import Storage
import DesignSystem

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

public final class SignUpIntroduceViewController: BaseViewController<SignUpIntroduceViewReactor> {
    //MARK: - Properties
    private let scrollView: UIScrollView = UIScrollView()
    private let containerView: UIView = UIView()
    private let profileContainerView: UIView = UIView()
    private let profileImageView: UIImageView = UIImageView()
    private let profileEdtiButton: UIButton = UIButton(type: .custom)
    private let introduceLabel: WSLabel = WSLabel(wsFont: .Header01)
    private let introduceTextField: WSTextField = WSTextField(placeholder: "(ex. 귀염둥이 엥뿌삐 ENFP)", title: "한 줄 소개")
    private let loadingIndicatorView: WSLottieIndicatorView = WSLottieIndicatorView()
    private let confirmButton: WSButton = WSButton(wsButtonType: .default(12))
    private let introduceCountLabel: WSLabel = WSLabel(wsFont: .Body07)
    private let errorLabel: WSLabel = WSLabel(wsFont: .Body07)
    private let pickerConfiguration: PHPickerConfiguration = {
        var configuration: PHPickerConfiguration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1
        configuration.selection = .default
        return configuration
    }()
    private lazy var pickerViewController: PHPickerViewController = PHPickerViewController(configuration: pickerConfiguration)
    
    deinit {
        print(#function)
    }
    
    //MARK: - LifeCycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    //MARK: - Configure
    public override func setupUI() {
        super.setupUI()
        scrollView.addSubview(containerView)
        profileContainerView.addSubview(profileImageView)
        containerView.addSubviews(introduceLabel, profileContainerView, profileEdtiButton ,introduceTextField, errorLabel, introduceCountLabel)
        view.addSubviews(scrollView, confirmButton)
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
            $0.height.equalTo(scrollView.frameLayoutGuide).priority(.low)
        }
        introduceLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(30)
            $0.height.equalTo(60)
        }
        
        profileContainerView.snp.makeConstraints {
            $0.top.equalTo(introduceLabel.snp.bottom).offset(28)
            $0.centerX.equalTo(introduceLabel)
            $0.size.equalTo(110)
        }
        
        profileImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        profileEdtiButton.snp.makeConstraints {
            $0.bottom.equalTo(profileContainerView)
            $0.size.equalTo(28)
            $0.right.equalTo(profileContainerView)
        }
        
        introduceTextField.snp.makeConstraints {
            $0.top.equalTo(profileContainerView.snp.bottom).offset(58)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(introduceTextField.snp.bottom).offset(4)
            $0.left.equalTo(introduceTextField.snp.left).offset(10)
            $0.width.equalTo(150)
            $0.height.equalTo(24)
        }
        
        introduceCountLabel.snp.makeConstraints {
            $0.top.equalTo(introduceTextField.snp.bottom).offset(4)
            $0.right.equalTo(introduceTextField)
            $0.height.equalTo(20)
        }
        
        confirmButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(52)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-12)
        }
        
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        
        navigationBar.do {
            $0.setNavigationBarUI(property: .all(
                DesignSystemAsset.Images.arrow.image,
                "닫기",
                "",
                DesignSystemAsset.Colors.gray300.color
            ))
            $0.setNavigationBarAutoLayout(property: .all)
        }
        
        scrollView.do {
            $0.canCancelContentTouches = true
        }
        
        introduceLabel.do {
            guard let name = UserDefaultsManager.shared.userName else { return }
            $0.text = "친구들에게 \(name)님을 소개하는\n한 줄을 작성해 주세요"
            $0.textColor = DesignSystemAsset.Colors.gray100.color
        }
        
        profileEdtiButton.do {
            $0.configuration = .filled()
            $0.layer.cornerRadius = 28 / 2
            $0.clipsToBounds = true
            $0.configuration?.baseBackgroundColor = DesignSystemAsset.Colors.gray400.color
            $0.configuration?.image = DesignSystemAsset.Images.icProfileEditOutline.image
        }
    
        profileContainerView.do {
            $0.layer.cornerRadius = 110 / 2
            $0.clipsToBounds = true
            $0.backgroundColor = DesignSystemAsset.Colors.gray700.color
        }
        
        profileImageView.do {
            $0.image = DesignSystemAsset.Images.imgSignupProfileClear.image
            $0.contentMode = .scaleAspectFill
        }
        
        introduceCountLabel.do {
            $0.textColor = DesignSystemAsset.Colors.gray700.color
            $0.textAlignment = .right
        }
        
        errorLabel.do {
            $0.isHidden = true
            $0.textColor = DesignSystemAsset.Colors.destructive.color
        }
        
        confirmButton.do {
            $0.setupFont(font: .Body03)
            $0.setupButton(text: "확인")
        }
    }
    
    public override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        
        NotificationCenter.default
            .rx.notification(UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo }
            .map { userInfo -> CGFloat in
                let keyboardHeight = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                return keyboardHeight
            }
            .bind(with: self) { owner, keyboardHeight in
                let additionalOffset: CGFloat = 40
                UIView.animate(withDuration: 0.3) {
                    owner.scrollView.transform = CGAffineTransform(translationX: 0, y: -(additionalOffset))
                }
            }
            .disposed(by: disposeBag)
        
        containerView
            .rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.containerView.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        introduceTextField.rx.text
            .changed
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                self?.introduceTextField.updateBorder()
            })
            .compactMap { $0 }
            .map { Reactor.Action.didUpdateIntroduce($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .withLatestFrom(reactor.state.map { $0.accountReqeust})
            .bind(with: self) { owner , arg in
                let signupResultViewController = DependencyContainer.shared.injector.resolve(SignUpResultViewController.self, arguments: arg, reactor.currentState.schoolName, reactor.currentState.imageData)
                owner.navigationController?.pushViewController(signupResultViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        introduceTextField
            .rx.text.orEmpty
            .map { "\($0.count)/20"}
            .bind(to: introduceCountLabel.rx.text)
            .disposed(by: disposeBag)
    
        profileEdtiButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.pickerViewController.modalPresentationStyle = .fullScreen
                owner.present(owner.pickerViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        pickerViewController.rx
            .didSelectImage
            .map { Reactor.Action.didSelectedImage($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$imageData)
            .compactMap { $0 }
            .map { UIImage(data: $0)}
            .bind(to: profileImageView.rx.image)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isValidation }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: errorLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isValidation }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: confirmButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.errorMessage }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: errorLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .bind(to: loadingIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)
    }
}
