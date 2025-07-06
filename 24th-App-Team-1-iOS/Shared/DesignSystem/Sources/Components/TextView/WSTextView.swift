//
//  WSTextView.swift
//  DesignSystem
//
//  Created by 최지철 on 1/3/25.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

public final class WSTextView: UITextView {

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    public enum TextViewState {
        case `default`
        case withLeftItem(UIImage)
        case withRightItem(UIImage)
        case detailMessage
        
        var padding: UIEdgeInsets {
            switch self {
            case .default:
                return .init(top: 18, left: 20, bottom: 18, right: 18)
            case .withLeftItem:
                return .init(top: 18, left: 59, bottom: 18, right: 18)
            case .withRightItem:
                return .init(top: 18, left: 20, bottom: 18, right: 48)
            case .detailMessage:
                return .init(top: 24, left: 0, bottom: 3, right: 0)

            }
        }
    }
    
    private var textViewState: TextViewState = .default
    private let placeholderLabel = UILabel().then {
        $0.textColor = DesignSystemAsset.Colors.gray400.color
        $0.numberOfLines = 0
        $0.font = WSFont.Body04.font()
        $0.isUserInteractionEnabled = false
    }
    
    private let leftImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    private let rightImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.isHidden = true
    }
    
    public var placeholder: String = "Placeholder" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    
    public override var text: String! {
        didSet {
            placeholderLabel.isHidden = !text.isEmpty
        }
    }
    
    // MARK: - Initializer
    public init(state: TextViewState = .default, placeholder: String = "Placeholder") {
        super.init(frame: .zero, textContainer: nil)
        self.textViewState = state
        self.placeholder = placeholder
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        // 기본 설정
        backgroundColor = DesignSystemAsset.Colors.gray700.color
        textColor = DesignSystemAsset.Colors.gray100.color
        font = WSFont.Body04.font()
        isScrollEnabled = true
        textContainerInset = textViewState.padding
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = UIColor.clear.cgColor

        // Placeholder 설정
        addSubview(placeholderLabel)
        addSubview(leftImageView)
        addSubview(rightImageView)
        placeholderLabel.text = placeholder
        placeholderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(textViewState.padding)
            make.leading.equalToSuperview().offset(26)
            make.trailing.equalToSuperview().inset(textViewState.padding.right)
        }
        
        leftImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        rightImageView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        // Placeholder 숨김 상태 업데이트
        placeholderLabel.isHidden = !text.isEmpty
        
        switch textViewState {
        case .withLeftItem(let image):
            leftImageView.image = image
            leftImageView.isHidden = false
        case .withRightItem(let image):
            rightImageView.image = image
            rightImageView.isHidden = false
        default:
            break
        }

        // 텍스트 변경 이벤트를 관찰하여 Placeholder 상태 업데이트
        rx.text.orEmpty
            .bind { [weak self] text in
                self?.placeholderLabel.isHidden = !text.isEmpty
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Update Functions
    public func updateBorder(isActive: Bool) {
        layer.borderColor = isActive ? DesignSystemAsset.Colors.primary400.color.cgColor : UIColor.clear.cgColor
    }
}
