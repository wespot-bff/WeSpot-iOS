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
    var confirmButton: WSButton = WSButton(wsButtonType: .default(10))
    var cancelButton: WSButton = WSButton(wsButtonType: .disableButton)
    var alertAction: WSAlertActionProperty?
    
    
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
        containerView.addSubviews(titleLabel, messageLabel, confirmButton, cancelButton)
    }
    
    
    private func setupAutoLayout() {
        
        containerView.snp.makeConstraints {
            $0.height.equalTo(208)
            $0.width.equalTo(310)
            $0.center.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.height.equalTo(32)
            $0.centerX.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().offset(20)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        confirmButton.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(52)
            $0.bottom.equalToSuperview().offset(-20)
            $0.width.equalTo(131)
        }
        
        cancelButton.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.height.equalTo(52)
            $0.bottom.equalToSuperview().offset(-20)
            $0.width.equalTo(131)
        }
        
    }
    
    private func setupAttributes() {
        view.backgroundColor = .black.withAlphaComponent(0.6)
        containerView.backgroundColor = DesignSystemAsset.Colors.gray600.color
        containerView.layer.cornerRadius = 20
        containerView.clipsToBounds = true
        titleLabel.textColor = DesignSystemAsset.Colors.gray100.color
        titleLabel.textAlignment = .center
        messageLabel.textColor = DesignSystemAsset.Colors.gray300.color
        
        confirmButton.addTarget(self, action: #selector(didTapConfirmButton), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
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