//
//  MessageCollecitonViewCell.swift
//  MessageFeature
//
//  Created by 최지철 on 1/12/25.
//

import UIKit
import DesignSystem

import RxSwift
import SnapKit
import MessageDomain

final class MessageCollectionViewCell: UICollectionViewCell {
    
    private let readImage: UIImage = DesignSystemAsset.Images.messageRead.image
    private let UnreadImage: UIImage = DesignSystemAsset.Images.messageUnread.image
    private var disposeBag = DisposeBag()
    var onMoreButtonTap: (() -> Void)?
    var onDeleteButtonTap: (() -> Void)?
    private let messageImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .clear
        $0.image = DesignSystemAsset.Images.messageUnread.image
    }
    
    private let moreButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Images.icEllipsis.image, for: .normal)
        $0.backgroundColor = .clear
    }
    private let xMarkButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Images.icXmark.image, for: .normal)
        $0.backgroundColor = .clear
    }
    private let studentInfoLabel = WSLabel(wsFont: .Body09).then {
        $0.textColor = DesignSystemAsset.Colors.gray100.color
    }
    private let dateLabel = WSLabel(wsFont: .Body11).then {
        $0.textColor = DesignSystemAsset.Colors.gray300.color
    }
    
    private func layout() {
        self.backgroundColor = DesignSystemAsset.Colors.gray700.color
        self.layer.cornerRadius = 12
        self.contentView.addSubviews(messageImageView,
                                     moreButton,
                                     xMarkButton,
                                     studentInfoLabel,
                                     dateLabel)
        
        messageImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.horizontalEdges.equalToSuperview().inset(15)
            $0.height.equalTo(100)
        }

        xMarkButton.snp.makeConstraints {
            $0.width.height.equalTo(18)
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().inset(12)
        }
        
        moreButton.snp.makeConstraints {
            $0.width.height.equalTo(18)
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().inset(12)
        }
        
        studentInfoLabel.snp.makeConstraints {
            $0.top.equalTo(messageImageView.snp.bottom).offset(2)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().inset(14)
            $0.bottom.equalTo(dateLabel.snp.top).offset(-17)
        }
        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(15)
            $0.bottom.equalToSuperview().inset(12)
        }
    }
    
    func configure(info: String,
                   date: String,
                   type: MessageButtonTabEnum,
                   read: Bool = false,
                   isReport: Bool = false) {
        // 메시지 읽음 여부에 따른 이미지 설정
        messageImageView.image = read ? readImage : UnreadImage

        // 라벨 텍스트 설정
        studentInfoLabel.text = info
        dateLabel.text = date
        
        // type에 따른 버튼 표시 처리
        switch type {
        case .received:
            // 받은 메시지 : moreButton 표시, xMarkButton 숨김
            moreButton.isHidden = false
            xMarkButton.isHidden = true
            moreButton.rx.tap
                .bind { [weak self] in
                    self?.onMoreButtonTap?()
                }
                .disposed(by: disposeBag)
        case .sent:
            // 보낸 메시지 : xMarkButton 표시, moreButton 숨김
            moreButton.isHidden = true
            xMarkButton.isHidden = false
            xMarkButton.rx.tap
           .bind(with: self) { owner, _ in
               owner.onDeleteButtonTap?()
           }
           .disposed(by: disposeBag)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
