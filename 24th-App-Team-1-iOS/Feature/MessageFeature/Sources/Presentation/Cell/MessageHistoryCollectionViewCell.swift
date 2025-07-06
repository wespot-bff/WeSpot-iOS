//
//  MessageHistoryCollectionViewCell.swift
//  MessageFeature
//
//  Created by 최지철 on 5/14/25.
//

import UIKit
import Foundation

import DesignSystem
import MessageDomain

final class MessageHistoryCollectionViewCell: UICollectionViewCell {
    private let messageIcon = UIImageView(image: DesignSystemAsset.Images.icMessageWhite.image)
    private let dateLabel = WSLabel(wsFont: .Body09)
    private let darkOverlayView = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.gray700.color
        $0.layer.opacity = 0.5
    }
    private let receivedImg = UIImageView().then {
        $0.image = DesignSystemAsset.Images.icDownRedArrow.image
    }
    private let sentImg = UIImageView().then {
        $0.image = DesignSystemAsset.Images.icUpBlueArrow.image
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubviews(messageIcon, dateLabel, darkOverlayView)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.bringSubviewToFront(darkOverlayView)
    }
    
    override var isSelected: Bool {
        didSet {
            // isSelected 값이 변경될 때마다 이 블록이 호출됩니다.
            self.updateSelectionState()
        }
    }
    
    private func updateSelectionState() {
        if isSelected {
            self.layer.borderColor = DesignSystemAsset.Colors.primary400.color.cgColor
            darkOverlayView.isHidden = true
        } else {
            self.layer.borderColor = DesignSystemAsset.Colors.gray700.color.cgColor
            darkOverlayView.isHidden = false
        }
    }
        
    func configureCell(date: String,
                       messageState: MessageDirectionEnum) {

        dateLabel.text = self.formatDate(from: date) ?? date
        dateLabel.sizeToFit()
        switch messageState {
        case .sent:
            sentImg.isHidden = false
            receivedImg.isHidden = true
            messageIcon.tintColor = DesignSystemAsset.Colors.gray100.color
            
        case .received:
            receivedImg.isHidden = false
            sentImg.isHidden = true
            messageIcon.tintColor = DesignSystemAsset.Colors.primary300.color
        }
    }
    
    private func layout() {
        self.addSubviews(receivedImg, sentImg, messageIcon, dateLabel, darkOverlayView)
        self.layer.borderWidth = 1
        self.layer.cornerRadius = 10
        
        dateLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-10)
        }
        
        messageIcon.snp.makeConstraints {
            $0.bottom.equalTo(dateLabel.snp.top).offset(8.6)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(32)
            $0.height.equalTo(21)
        }
        
        receivedImg.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(messageIcon.snp.top).offset(-4)
        }
        
        sentImg.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(messageIcon.snp.top).offset(-4)
        }
        
        darkOverlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func formatDate(from isoString: String) -> String? {
        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        

        formatter.timeZone = TimeZone(secondsFromGMT: 0)

        guard let date = formatter.date(from: isoString) else {
            print("DEBUG: Failed to parse date string with DateFormatter: \(isoString)")
            return nil
        }
        let customFormatter = DateFormatter()
        customFormatter.dateFormat = "yyyy. M. d"
        customFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        return customFormatter.string(from: date)
    }
}
