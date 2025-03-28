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
        $0.text = UserDefaultsManager.shared.userName ?? "김제니" + String.MessageTexts.messageHomePostableTitleText
    }
    
    /// 편지 이미지를 보여주는 이미지 뷰
    private var messageLottieView = WSLottieView().then {
        $0.lottieView.animation = DesignSystemAnimationAsset.bgMessageOpenAnimate.animation
        $0.isStatus = true
        $0.lottieView.loopMode = .playOnce
    }
    
    /// "남은 시간"에 대한 소개 라벨
    private let leftTimeIntoLabel = WSLabel(wsFont: .Body09,
                                            text: String.MessageTexts.messageLeftTimeIntroText).then {
        $0.textColor = DesignSystemAsset.Colors.gray300.color
    }
    
    /// 타이머 아이콘
    private let timerImage = UIImageView().then {
        $0.image = DesignSystemAsset.Images.icMessageHomeTimer.image
        $0.contentMode = .scaleAspectFit
        $0.snp.makeConstraints {
            $0.width.height.equalTo(20)
        }
    }
    
    /// 남은 시간 라벨 (예: "00:00:00")
    private lazy var leftTimeLabel = WSLabel(wsFont: .Header05,
                                             text: "00:00:00",
                                             textAlignment: .left).then {
        $0.snp.makeConstraints {
            $0.width.equalTo(135)
        }
        $0.textColor = DesignSystemAsset.Colors.gray100.color
    }
    
    /// 타이머 이미지와 시간 라벨을 수평으로 배치할 스택 뷰
    private let timeHoriznotalStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 8
    }
    private let timeContentStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .center
        $0.spacing = 0
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
        
        [timerImage, leftTimeLabel].forEach {
            timeHoriznotalStackView.addArrangedSubview($0)
        }
        
        [leftTimeIntoLabel, timeHoriznotalStackView].forEach {
            timeContentStackView.addArrangedSubview($0)
        }
        
        [messageLottieView,
         titleLabel,
         timeContentStackView,
         sendMessageButton].forEach {
            self.addSubviews($0)
        }

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
        timeContentStackView.snp.makeConstraints {
            $0.height.equalTo(MessageConstants.messageSendButtonHeight)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(sendMessageButton.snp.top).offset(-20)
        }

    }
}

    // MARK: - Method

extension ReservedMessageCountView {
    
    func playLottie() {
        messageLottieView.lottieView.play()
    }
    
    func configureMessageCountView(leftTime: String,
                                   availableSend: MessageHomeTimeStateEntity.PostableTimeState) {
        
        leftTimeLabel.text = leftTime
        switch availableSend {
        case .waitTime:
            titleLabel.text = userName + String.MessageTexts.messageHomePostableTitleText
            messageLottieView.lottieView.animation = DesignSystemAnimationAsset.bgMessageOpenAnimate.animation
            sendMessageButton.setupButton(text: String.MessageTexts.messageSendWaitTimeButtonText)
            sendMessageButton.isEnabled = false
            timeContentStackView.isHidden = true
            
        case .postableTime:
            titleLabel.text = userName + String.MessageTexts.messageHomePostableTitleText
            messageLottieView.lottieView.animation = DesignSystemAnimationAsset.bgMessageOpenAnimate.animation
            sendMessageButton.setupButton(text: String.MessageTexts.messageSendAvailableButtonText)
            sendMessageButton.isEnabled = true
            timeContentStackView.isHidden = false

        case .etcTime:
            titleLabel.text = userName + String.MessageTexts.messageHomeCompeleteTitleText
            messageLottieView.lottieView.animation = DesignSystemAnimationAsset.bgMessageCloseAnimate.animation
            sendMessageButton.setupButton(text: String.MessageTexts.messageSendAvailableButtonText)
            sendMessageButton.isEnabled = false
            timeContentStackView.isHidden = true

        }
    }
}
