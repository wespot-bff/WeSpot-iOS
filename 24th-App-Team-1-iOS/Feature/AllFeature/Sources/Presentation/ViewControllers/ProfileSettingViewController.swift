//
//  ProfileSettingViewController.swift
//  AllFeature
//
//  Created by Kim dohyun on 8/12/24.
//

import DesignSystem
import PhotosUI
import UIKit
import Util

import Then
import Storage
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import Kingfisher

public final class ProfileSettingViewController: BaseViewController<ProfileSettingViewReactor> {

    //MARK: - Properties
    private let scrollView: UIScrollView = UIScrollView()
    private let containerView: UIView = UIView()
    private let userContainerView: UIView = UIView()
    private let userImageView: UIImageView = UIImageView()
    private let userProfileEditButton: UIButton = UIButton(type: .custom)
    private let loadingIndicatorView: WSLottieIndicatorView = WSLottieIndicatorView()
    private let userNameTextField: WSTextField = WSTextField(state: .withRightItem(DesignSystemAsset.Images.lock.image), placeholder: "김선희", title: "이름")
    private let userGenderTextFiled: WSTextField = WSTextField(state: .withRightItem(DesignSystemAsset.Images.lock.image), placeholder: "여", title: "성별")
    private let userClassInfoTextField: WSTextField = WSTextField(state: .withRightItem(DesignSystemAsset.Images.lock.image), placeholder: "역삼중학교 1학년 6반", title: "학적 정보")
    private let userIntroduceTextField: WSTextField = WSTextField(state: .default, placeholder: "|(ex. 귀염둥이 엥뿌삐 ENFP)", title: "MBTI")
    private let privacyButton: WSButton = WSButton(wsButtonType: .default(12))
    private let editButton: WSButton = WSButton(wsButtonType: .default(12))
    private let errorLabel: WSLabel = WSLabel(wsFont: .Body07)
    private let introduceCountLabel: WSLabel = WSLabel(wsFont: .Body07)
    private let pickerConfiguration: PHPickerConfiguration = {
        var configuration: PHPickerConfiguration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1
        configuration.selection = .default
        return configuration
    }()
    private lazy var pickerViewController: PHPickerViewController = PHPickerViewController(configuration: pickerConfiguration)
    
    //MARK: - LifeCycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .hideTabBar, object: nil)
    }

    //MARK: - Configure
    public override func setupUI() {
        super.setupUI()
        userContainerView.addSubview(userImageView)
        containerView.addSubviews(userContainerView, userProfileEditButton, userNameTextField, userGenderTextFiled, userClassInfoTextField, userIntroduceTextField, errorLabel, introduceCountLabel)
        scrollView.addSubview(containerView)
        view.addSubviews(scrollView, editButton)
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.left.right.top.bottom.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        userContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.size.equalTo(90)
            $0.centerX.equalToSuperview()
        }
        
        userProfileEditButton.snp.makeConstraints {
            $0.width.height.equalTo(28)
            $0.bottom.equalTo(userContainerView)
            $0.right.equalTo(userContainerView)
        }
        
        userImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        userNameTextField.snp.makeConstraints {
            $0.top.equalTo(userContainerView.snp.bottom).offset(52)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(ProfileConstraint.profileSettingTextFiledHeight)
        }
        
        userGenderTextFiled.snp.makeConstraints {
            $0.top.equalTo(userNameTextField.snp.bottom).offset(52)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(ProfileConstraint.profileSettingTextFiledHeight)
        }
        
        userClassInfoTextField.snp.makeConstraints {
            $0.top.equalTo(userGenderTextFiled.snp.bottom).offset(52)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(ProfileConstraint.profileSettingTextFiledHeight)
        }
        
        userIntroduceTextField.snp.makeConstraints {
            $0.top.equalTo(userClassInfoTextField.snp.bottom).offset(52)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(ProfileConstraint.profileSettingTextFiledHeight)
            $0.bottom.equalToSuperview()
        }
        
        errorLabel.snp.makeConstraints {
            $0.top.equalTo(userIntroduceTextField.snp.bottom).offset(4)
            $0.left.equalTo(userIntroduceTextField.snp.left).offset(10)
            $0.width.equalTo(150)
            $0.height.equalTo(24)
        }
        
        introduceCountLabel.snp.makeConstraints {
            $0.top.equalTo(userIntroduceTextField.snp.bottom).offset(4)
            $0.right.equalTo(userIntroduceTextField.snp.right).offset(-4)
            $0.height.equalTo(24)
            $0.width.equalTo(55)
        }
        
        editButton.snp.makeConstraints {
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-24)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        navigationBar.do {
            $0.setNavigationBarUI(property: .leftWithCenterItem(
                DesignSystemAsset.Images.arrow.image,
                "프로필 수정"
            ))
            $0.setNavigationBarAutoLayout(property: .leftWithCenterItem)
        }

        editButton.do {
            $0.setupFont(font: .Body03)
            $0.setupButton(text: "수정 완료")
            $0.isEnabled = false
        }
        
        userContainerView.do {
            $0.backgroundColor = DesignSystemAsset.Colors.primary300.color
            $0.layer.cornerRadius = 90 / 2
            $0.clipsToBounds = true
        }
        
        introduceCountLabel.do {
            $0.textColor = DesignSystemAsset.Colors.gray400.color
            $0.textAlignment = .right
        }
        
        errorLabel.do {
            $0.isHidden = true
            $0.text = "비속어 포함 되어있습니다."
            $0.textColor = DesignSystemAsset.Colors.destructive.color
        }
        
        userProfileEditButton.do {
            $0.configuration = .filled()
            $0.layer.cornerRadius = 28 / 2
            $0.clipsToBounds = true
            $0.configuration?.baseBackgroundColor = DesignSystemAsset.Colors.gray400.color
            $0.configuration?.image = DesignSystemAsset.Images.icProfileEditOutline.image
        }
        
        userImageView.do {
            $0.image = DesignSystemAsset.Images.girl.image
        }
        
        scrollView.do {
            $0.canCancelContentTouches = true
        }
    }
    
    
    public override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        containerView
            .rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.containerView.endEditing(true)
            }
            .disposed(by: disposeBag)
        
        
        userIntroduceTextField
            .rx.text.changed
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .do(onNext: { [weak self] _ in
                self?.userIntroduceTextField.updateBorder()
            })
            .compactMap { $0 }
            .map { Reactor.Action.didUpdateIntroduceProfile($0)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        userProfileEditButton
            .rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.showProfileActionSheetViewController()
            }
            .disposed(by: disposeBag)
        
        pickerViewController
            .rx.didSelectImage
            .map { Reactor.Action.didTappedProfileEditButton($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        userNameTextField.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.showWSToast(image: .warning, message: "하단의 버튼을 눌러 변경 신청 해주세요")
            }
            .disposed(by: disposeBag)
        
        userGenderTextFiled.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.showWSToast(image: .warning, message: "하단의 버튼을 눌러 변경 신청 해주세요")
            }
            .disposed(by: disposeBag)
        
        userClassInfoTextField.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                owner.showWSToast(image: .warning, message: "하단의 버튼을 눌러 변경 신청 해주세요")
            }
            .disposed(by: disposeBag)
        
        userIntroduceTextField
            .rx.controlEvent([.editingDidBegin, .editingDidEnd])
            .map { self.userIntroduceTextField.isEditing }
            .bind(to: userIntroduceTextField.borderUpdateBinder)
            .disposed(by: disposeBag)
        
        
        NotificationCenter.default.rx
            .notification(UIResponder.keyboardWillChangeFrameNotification)
                   .compactMap { $0.userInfo }
                   .map { userInfo -> CGFloat in
                       let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
                       let keyboardHeight = UIScreen.main.bounds.height - keyboardFrame.origin.y
                       return keyboardHeight
                   }
                   .bind(with: self) { owner, keyboardHeight in
                       let spacing: CGFloat = keyboardHeight == 384 ? 140 : 130
                       owner.scrollView.contentInset.bottom = (keyboardHeight + spacing)
                       owner.scrollView.verticalScrollIndicatorInsets.bottom = (keyboardHeight + spacing)
                   }
                   .disposed(by: disposeBag)
        
        
        NotificationCenter.default
            .rx.notification(UIResponder.keyboardWillHideNotification, object: nil)
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, _ in
                owner.scrollView.contentInset.bottom = .zero
                owner.scrollView.verticalScrollIndicatorInsets.bottom = .zero
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isEnabled)
            .bind(to: editButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        
        userIntroduceTextField
            .rx.text.orEmpty
            .scan("") { previous, new -> String in
                if new.count <= 20 {
                    return previous
                }
                return new
            }
            .distinctUntilChanged()
            .bind(to: userIntroduceTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.userProfileEntity?.name }
            .distinctUntilChanged()
            .bind(to: userNameTextField.rx.placeholderText)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap{ $0.userProfileEntity?.gender }
            .map { $0 == "MALE" ? "남" : "여"}
            .distinctUntilChanged()
            .bind(to: userGenderTextFiled.rx.placeholderText)
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.userProfileEntity }
            .compactMap { $0 }
            .compactMap { "\($0.schoolName) \($0.grade)학년 \($0.classNumber)반"}
            .distinctUntilChanged()
            .bind(to: userClassInfoTextField.rx.placeholderText)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$userProfileEntity)
            .compactMap { $0?.introduction }
            .distinctUntilChanged()
            .bind(to: userIntroduceTextField.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.userProfileEntity?.profile.backgroundColor }
            .distinctUntilChanged()
            .map { UIColor(hex: $0)}
            .bind(to: userContainerView.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.imageData }
            .map { UIImage(data: $0) }
            .distinctUntilChanged()
            .bind(to: userImageView.rx.image)
            .disposed(by: disposeBag)
            
        reactor.state
            .map { $0.userProfileImageEntity?.url }
            .filter { $0 == nil }
            .map { _ in DesignSystemAsset.Images.profile.image }
            .distinctUntilChanged()
            .bind(to: userImageView.rx.image)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.userProfileEntity?.profile.iconUrl }
            .filter { $0 != nil }
            .map { URL(string: $0 ?? "")}
            .distinctUntilChanged()
            .bind(with: self) { owner, iconURL in
                owner.userImageView.kf.setImage(with: iconURL)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.userProfileEntity }
            .compactMap { "\($0.introduction.count)/20" }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: introduceCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isProfanity)
            .map { !$0 }
            .bind(to: errorLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.errorMessage }
            .distinctUntilChanged()
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: errorLabel.rx.text)
            .disposed(by: disposeBag)
        
        userIntroduceTextField
            .rx.text.orEmpty
            .map { "\($0.count)/20" }
            .bind(to: introduceCountLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isUpdate)
            .filter{ $0 == true }
            .bind(with: self) { owner, _ in
                owner.view.endEditing(true)
                owner.showWSToast(image: .check, message: "수정 완료")
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .bind(to: loadingIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)
        
        editButton
            .rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.didTapUpdateUserButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
    }
}


extension ProfileSettingViewController {
    
    private func showProfileActionSheetViewController() {
        let profileEditAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let addProfileImageAction = UIAlertAction(title: "앨범에서 사진 선택", style: .default) { _ in
            self.showPickerViewController()
        }
        
        let removeProfileAction = UIAlertAction(title: "기본 이미지 적용", style: .destructive) { _ in
            self.reactor?.action.onNext(.didTappedRemoveProfileImage)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        profileEditAlertController.addAction(addProfileImageAction)
        profileEditAlertController.addAction(removeProfileAction)
        profileEditAlertController.addAction(cancelAction)
        
        self.present(profileEditAlertController, animated: true)
    }
    
    private func showPickerViewController() {
        pickerViewController.modalPresentationStyle = .fullScreen
        present(pickerViewController, animated: true)
    }
    
}
