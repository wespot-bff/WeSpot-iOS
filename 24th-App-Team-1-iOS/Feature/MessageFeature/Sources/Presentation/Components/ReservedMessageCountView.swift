//
//  ReservedMessageCountView.swift
//  MessageFeature
//
//  Created by 최지철 on 12/20/24.
//

import UIKit

import DesignSystem
import Storage
import MessageDomain
import SnapKit
import Then
import Util

final class ReservedMessageCountView: UIView {
    
    // MARK: - UI
    
    /// 타이틀(“지금 쪽지를 보낼 수 있어요” 등)
    private lazy var titleLabel = WSLabel(wsFont: .Body01,
                                          textAlignment: .left).then {
        $0.textColor = .white
        $0.text = String.MessageTexts.messageHomePostableTitleText
        $0.sizeToFit()
    }
    
    /// 편지 이미지를 보여주는 이미지 뷰
    private var messageLottieView = WSLottieView().then {
        $0.lottieView.animation = DesignSystemAnimationAsset.bgMessageOpenAnimate.animation
        $0.isStatus = true
        $0.lottieView.loopMode = .playOnce
    }
    private let pencilIconImage = UIImageView().then {
        $0.image = DesignSystemAsset.Images.icPencil.image
        $0.contentMode = .scaleAspectFit
    }
    private let messageDesLabel = WSLabel(wsFont: .Body09,
                                                text: String.MessageTexts.postableMessageCount).then {
        $0.sizeToFit()
        $0.textColor = DesignSystemAsset.Colors.gray300.color
    }
    private lazy var leftMessageCountLabel = WSLabel(wsFont: .Header05,
                                             text: "3개",
                                             textAlignment: .left).then {
        $0.sizeToFit()
        $0.textColor = DesignSystemAsset.Colors.gray100.color
    }
    
    private let countHoriznotalStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 8
    }

    
    private let timerIcon = UIImageView().then {
        $0.image = DesignSystemAsset.Images.icMessageHomeTimer.image
        $0.contentMode = .scaleAspectFit
    }
    
    /// 남은 시간 라벨 (예: "00:00:00")
    private lazy var leftTimeMessageLabel = WSLabel(wsFont: .Header05,
                                             text: "00:00:00",
                                             textAlignment: .left).then {
        $0.sizeToFit()
        $0.textColor = DesignSystemAsset.Colors.gray100.color
    }
    
    /// 타이머 이미지와 시간 라벨을 수평으로 배치할 스택 뷰
    private let timeHoriznotalStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 8
    }
    
    
    private let countContentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 2
    }
    
    private let timeContentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 2
    }
    
    /// 쪽지 보내기 버튼
    lazy var sendMessageButton = WSButton(wsButtonType: .default(12))
    
    /// 전체 레이아웃을 잡아줄 최상위(vertical) 스택 뷰
    private let contentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 0
        $0.contentMode = .scaleAspectFit
        $0.isLayoutMarginsRelativeArrangement = false
    }
    
    private let userName: String = UserDefaultsManager.shared.userName ?? "김제니"
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI

extension ReservedMessageCountView {
    private func setupViews() {
        self.backgroundColor = DesignSystemAsset.Colors.gray700.color
        self.layer.cornerRadius = 18
        
        [pencilIconImage, leftMessageCountLabel].forEach {
            countHoriznotalStackView.addArrangedSubview($0)
        }
        
        [timerIcon, leftTimeMessageLabel].forEach {
            timeHoriznotalStackView.addArrangedSubview($0)
        }
        
        
        
        
        self.addSubviews(titleLabel,
                         messageLottieView,
                         messageDesLabel,
                         countHoriznotalStackView,
                         timeHoriznotalStackView,
                         sendMessageButton)
    }
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(28)
        }
        messageLottieView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.height.equalTo(355)
            $0.horizontalEdges.equalToSuperview()
        }
        sendMessageButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(28)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
        timeHoriznotalStackView.snp.makeConstraints {
            $0.height.equalTo(MessageConstants.messageSendButtonHeight)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(sendMessageButton.snp.top).offset(-20)
        }
        countHoriznotalStackView.snp.makeConstraints {
            $0.height.equalTo(MessageConstants.messageSendButtonHeight)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(sendMessageButton.snp.top).offset(-20)
        }
        messageDesLabel.snp.makeConstraints {
            $0.bottom.equalTo(sendMessageButton.snp.top).offset(-72)
            $0.centerX.equalToSuperview()
        }
    }
}

    // MARK: - Method

extension ReservedMessageCountView {
    
    func playLottie() {
        messageLottieView.lottieView.play { finished in
            if finished {

            }
        }
    }
    
    func configure(count: Int, time: String) {
        if count > 0 {
            leftMessageCountLabel.text = "\(count)개"
            self.sendMessageButton.setupButton(text: String.MessageTexts.messageSendAvailableButtonText)
            messageDesLabel.text = String.MessageTexts.postableMessageCount
            messageDesLabel.sizeToFit()
            self.sendMessageButton.isEnabled = true
            timeHoriznotalStackView.isHidden = true
            countHoriznotalStackView.isHidden = false
        
        } else {
            self.sendMessageButton.setupButton(text: String.MessageTexts.messageSendUnavailableButtonText)
            self.leftTimeMessageLabel.text = time
            self.sendMessageButton.isEnabled = false
            messageDesLabel.text = String.MessageTexts.messageLeftTimeIntroText
            messageDesLabel.sizeToFit()
            timeHoriznotalStackView.isHidden = false
            countHoriznotalStackView.isHidden = true
        }
    }
}
