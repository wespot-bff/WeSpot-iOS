//
//  MessageWriteViewController.swift
//  MessageFeature
//
//  Created by 최지철 on 12/30/24.
//

import UIKit
import Util
import DesignSystem
import MessageDomain

import ReactorKit
import Then
import SnapKit
import RxCocoa
import RxDataSources

public final class MessageWriteViewController: BaseViewController<MessageWriteReactor> {
    
    //MARK: - Properties
    
    private let titleLabel = WSLabel(wsFont: .Header01).then {
        $0.textColor = DesignSystemAsset.Colors.gray100.color
        $0.text = String.MessageTexts.messageWriteTitle
    }
    private let contentTextField = WSTextView(state: .default,
                                              placeholder: "나랑 등교 같이할래?")
    private let contetnTextCountLabel = WSLabel(wsFont: .Body04,
                                                text: "0/200",
                                                textAlignment: .right).then {
        $0.textColor = DesignSystemAsset.Colors.gray400.color
        $0.snp.makeConstraints {
            $0.width.equalTo(71)
            $0.height.equalTo(24)
        }
    }
    private let postButton = WSButton(wsButtonType: .default(12))
    private let profanityWarningLabel = WSLabel(wsFont: .Body07).then {
        $0.textColor = DesignSystemAsset.Colors.destructive.color
        $0.text = "비속어가 포함되어 있어요"
        $0.sizeToFit()
        $0.isHidden = true
    }
    
    private let overTextWarningLabel = WSLabel(wsFont: .Body07).then {
        $0.textColor = DesignSystemAsset.Colors.destructive.color
        $0.text = "200자 이내로 입력해 주세요"
        $0.sizeToFit()
        $0.isHidden = true
    }

    
    //MARK: - LifeCycle
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contentTextField.becomeFirstResponder()
    }
    
    //MARK: - Configure

    public override func setupUI() {
        super.setupUI()
        [titleLabel,
         contentTextField,
         contetnTextCountLabel,
         profanityWarningLabel,
         overTextWarningLabel,
         postButton].forEach {
            self.view.addSubview($0)
        }
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.navigationBar.safeAreaLayoutGuide.snp.bottom)
            $0.leading.equalToSuperview().offset(20)
        }
        contentTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(228)
        }
        profanityWarningLabel.snp.makeConstraints {
            $0.top.equalTo(contentTextField.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(30)
        }
        overTextWarningLabel.snp.makeConstraints {
            $0.top.equalTo(contentTextField.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(30)
        }
        contetnTextCountLabel.snp.makeConstraints {
            $0.top.equalTo(contentTextField.snp.bottom)
            $0.trailing.equalToSuperview().inset(28)
        }
        postButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(MessageConstants.messageSendButtonHeight)
            $0.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).offset(-12)
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        navigationBar.do {
            $0.setNavigationBarUI(property: .leftWithRightItem(DesignSystemAsset.Images.arrow.image,
                                                               "닫기",
                                                        UIImage()))
            $0.setNavigationBarAutoLayout(property: .leftWithRightItem)
        }
        postButton.do {
            $0.setupButton(text: "작성완료")
            $0.isEnabled = false
        }
        contentTextField.delegate = self
    }
        
    public override func bind(reactor: MessageWriteReactor) {
        super.bind(reactor: reactor)
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindUI()
    }
}

    //MARK: - Bind

extension MessageWriteViewController {
    private func bindAction(reactor: MessageWriteReactor) {
        contentTextField.rx.text.orEmpty
            .observe(on: MainScheduler.instance)
            .bind(with: self) {  this, text in
                reactor.action.onNext(.writeMessage(text))
                this.contetnTextCountLabel.text = "\(text.count)/200"
                this.postButton.isEnabled = text.count > 0
            }
            .disposed(by: disposeBag)
        
        navigationBar.rightBarButton.rx
            .tap
            .bind(with: self) {  this, _ in
                WSAlertBuilder(showViewController: this)
                    .setAlertType(type: .titleWithMeesage)
                    .setTitle(title: "쪽지 작성을 중단하시나요?",
                              titleAlignment: .left)
                    .setMessage(message: "작성 중인 내용은 저장되지 않아요")
                    .setConfirm(text: "네 그만할래요")
                    .setCancel(text: "닫기")
                    .action(.confirm) { [weak self] in
                        self?.navigationController?.popToRootViewController(animated: true)
                        
                    }
                    .show()
            }
            .disposed(by: disposeBag)
        
        postButton.rx.tap
            .bind(with: self) {  this, _ in
                
                if this.reactor!.currentState.isReply {
                    let vc = MessageReplyInfoViewController(reactor: reactor)
                    this.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = MessageInfoInputViewController(reactor: reactor)
                    this.navigationController?.pushViewController(vc, animated: true)
                }

            }
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: MessageWriteReactor) {
        reactor.pulse(\.$profanityDetection)
            .observe(on: MainScheduler.instance)
            .bind(with:self) {  this, profanityDetection in
                print(profanityDetection)
                if profanityDetection {
                    this.profanityWarningLabel.isHidden = false
                    this.postButton.isEnabled = false
                    this.profanityWarningLabel.shakeAnimation()
                } else {
                    this.postButton.isEnabled = true
                    this.profanityWarningLabel.isHidden = true
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func bindUI() {
        
    }
}
extension MessageWriteViewController: UITextViewDelegate {
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 현재 텍스트를 가져오고, 변경 후의 텍스트 길이를 계산합니다.
        guard let currentText = textView.text,
              let textRange = Range(range, in: currentText) else { return true }
        let updatedText = currentText.replacingCharacters(in: textRange, with: text)
        if updatedText.count > 200 {
            overTextWarningLabel.isHidden = false
            overTextWarningLabel.shakeAnimation()
            postButton.isEnabled = false
        } else {
            overTextWarningLabel.isHidden = true
            postButton.isEnabled = true
        }
        return updatedText.count <= 200
    }
}
