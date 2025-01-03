//
//  SignUpClassViewController.swift
//  LoginFeature
//
//  Created by eunseou on 7/12/24.
//

import UIKit
import Util
import DesignSystem

import Then
import SnapKit
import Swinject
import RxSwift
import RxCocoa
import ReactorKit
import LoginDomain

public final class SignUpClassViewController: BaseViewController<SignUpClassViewReactor> {

    //MARK: - Properties
    private let titleLabel = WSLabel(wsFont: .Header01, text: "반")
    private let subTitleLabel = WSLabel(wsFont: .Body06, text: "회원가입 이후에는 학년 변경이 어려워요")
    private let classTextField = WSTextField(state: .default, placeholder: "현재 반을 입력해 주세요")
    private let warningLabel = WSLabel(wsFont: .Body07, text: "정확한 반을 입력해 주세요")
    private let nextButton = WSButton(wsButtonType: .default(12))
    private let accountInjector: Injector = DependencyInjector()
    
    //MARK: - LifeCycle
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        classTextField.becomeFirstResponder()
        warningLabel.isHidden = true
    }
    
    //MARK: - Functions
    public override func setupUI() {
        super.setupUI()
        
        view.addSubviews(titleLabel, subTitleLabel, classTextField, warningLabel, nextButton)
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(9)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(30)
        }
        classTextField.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(60)
        }
        warningLabel.snp.makeConstraints {
            $0.top.equalTo(classTextField.snp.bottom).offset(4)
            $0.leading.equalTo(classTextField.snp.leading).offset(10)
        }
        nextButton.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(52)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-12)
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        
        view.backgroundColor = DesignSystemAsset.Colors.gray900.color
        
        navigationBar
            .setNavigationBarUI(property: .leftWithCenterItem(DesignSystemAsset.Images.arrow.image, "회원가입"))
            .setNavigationBarAutoLayout(property: .leftWithCenterItem)
        
        titleLabel.do {
            $0.textColor = DesignSystemAsset.Colors.gray100.color
        }
        
        subTitleLabel.do {
            $0.textColor = DesignSystemAsset.Colors.gray400.color
        }
        
        classTextField.do {
            $0.keyboardType = .numberPad
            $0.delegate = self
        }
        
        warningLabel.do {
            $0.textColor = DesignSystemAsset.Colors.destructive.color
        }
        
        nextButton.do {
            $0.setupButton(text: "다음")
            $0.isEnabled = false 
        }
    }
    
    public override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
     
        classTextField.rx.controlEvent([.editingDidBegin, .editingDidEnd])
            .map { self.classTextField.isEditing }
            .bind(to: classTextField.borderUpdateBinder)
            .disposed(by: disposeBag)
        
        classTextField.rx.text.orEmpty
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .compactMap { Int($0) }
            .map { Reactor.Action.inputClass($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.accountRequest.gender.isEmpty ? "다음" : "수정 완료" }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: nextButton.rx.title())
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isEnabledButton }
            .bind(to: warningLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.isEnabledButton }
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        nextButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.didTappedNextButton}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        reactor.pulse(\.$isSelected)
            .filter { $0 == true }
            .withLatestFrom(reactor.state.map { $0.accountRequest})
            .bind(with: self) { owner, response in
                if response.gender.isEmpty {
                    let signUpGenderViewController = DependencyContainer.shared.injector.resolve(SignUpGenderViewController.self, arguments: reactor.currentState.accountRequest, reactor.currentState.schoolName)
                    owner.navigationController?.pushViewController(signUpGenderViewController, animated: true)
                } else {
                    owner.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    
}

extension SignUpClassViewController: UITextFieldDelegate {
    
    // 숫자 이외의 입력 방지
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedChar = CharacterSet.decimalDigits
        let char = CharacterSet(charactersIn: string)
        return allowedChar.isSuperset(of: char)
    }
}
