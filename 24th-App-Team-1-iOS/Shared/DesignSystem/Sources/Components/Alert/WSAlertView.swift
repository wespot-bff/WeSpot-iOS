//
//  WSAlertView.swift
//  DesignSystem
//
//  Created by Kim dohyun on 7/9/24.
//

import UIKit

import SnapKit
import Then


public final class WSAlertView: UIViewController {
    
    //MARK: Properties
    private let containerView: UIView = UIView()
    var titleLabel: WSLabel = WSLabel(wsFont: .Header01)
    var messageLabel: WSLabel = WSLabel(wsFont: .Body06)
    let buttonStackView: UIStackView = UIStackView()
    var confirmButton: WSButton = WSButton(wsButtonType: .default(10))
    var cancelButton: WSButton = WSButton(wsButtonType: .secondaryButton)
    var alertAction: WSAlertActionProperty?
    
    var alertType: AlertType = .titleWithMeesage
    var buttonType: ButtonType = .all
    private var titleText: String?
    private var messageText: String?
    private var confirmText: String?
    private var cancelText: String?
    
    //MARK: LifeCycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAutoLayout()
        setupAttributes()
    }
    
    //MARK: Configure
    private func setupUI() {
        view.addSubview(containerView)
        
        switch buttonType {
        case .confirm:
            buttonStackView.addArrangedSubview(confirmButton)
        case .cancel:
            buttonStackView.addArrangedSubview(cancelButton)
        case .all:
            buttonStackView.addArrangedSubviews(cancelButton, confirmButton)
        }
        
        switch alertType {
        case .message:
            containerView.addSubviews(titleLabel, buttonStackView)
        case .titleWithMeesage:
            containerView.addSubviews(titleLabel, messageLabel, buttonStackView)
        }
    }
    
    
    private func setupAutoLayout() {
        
        switch alertType {
        case .message:
            containerView.snp.makeConstraints {
                $0.height.equalTo(158)
                $0.width.equalTo(310)
                $0.center.equalToSuperview()
            }
            
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().inset(32)
                $0.horizontalEdges.equalToSuperview().inset(20)
                $0.height.equalTo(30)
            }
            
            buttonStackView.snp.makeConstraints {
                $0.horizontalEdges.equalToSuperview().inset(20)
                $0.height.equalTo(52)
                $0.bottom.equalToSuperview().inset(20)
            }
            
            
        case .titleWithMeesage:
            //HACK: 추후 리펙토링
            containerView.snp.makeConstraints {
                $0.height.equalTo(208)
                $0.width.equalTo(310)
                $0.center.equalToSuperview()
            }
            
            titleLabel.snp.makeConstraints {
                $0.top.equalToSuperview().offset(32)
                $0.height.equalTo(32)
                $0.horizontalEdges.equalToSuperview().inset(20)
                $0.centerX.equalToSuperview()
            }
            
            messageLabel.snp.makeConstraints {
                $0.horizontalEdges.equalToSuperview().inset(20)
                $0.top.equalTo(titleLabel.snp.bottom).offset(8)
            }
            
            buttonStackView.snp.makeConstraints {
                $0.horizontalEdges.equalToSuperview().inset(20)
                $0.height.equalTo(52)
                $0.bottom.equalToSuperview().inset(20)
            }
        }
        
    }
    
    private func setupAttributes() {
        view.do {
            $0.backgroundColor = .black.withAlphaComponent(0.6)
        }
        
        containerView.do {
            $0.backgroundColor = DesignSystemAsset.Colors.gray600.color
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
        }
        
        titleLabel.do {
            $0.textColor = DesignSystemAsset.Colors.gray100.color
        }
        
        messageLabel.do {
            $0.textColor = DesignSystemAsset.Colors.gray300.color
        }
        
        buttonStackView.do {
            $0.axis = .horizontal
            $0.spacing = 8
            $0.distribution = .fillEqually
        }
        
        confirmButton.do {
            $0.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        }
        
        cancelButton.do {
            $0.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        }
    }
    
    
    @objc
    private func didTapConfirmButton() {
        self.dismiss(animated: true) { [weak self] in
            self?.alertAction?.confirmAction?()
        }
    }
    
    @objc
    private func didTapCancelButton() {
        alertAction?.cancelAction?()
        dismiss(animated: true)
    }
}
