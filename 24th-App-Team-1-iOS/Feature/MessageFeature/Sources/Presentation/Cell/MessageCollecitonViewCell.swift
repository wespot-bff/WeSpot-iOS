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
    var onFavoriteButtonTap: (() -> Void)?
    var isFavorite: Bool = false
    private let redDot = UIView().then {
        $0.backgroundColor = UIColor(hex: "#FF4D4D")
        $0.layer.cornerRadius = 4
        
    }
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 25
        $0.clipsToBounds = true
    }
    
    private let moreButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Images.icEllipsis.image, for: .normal)
        $0.backgroundColor = .clear
    }
    private let favoriteButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Images.icStar.image, for: .normal)
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
        self.contentView.addSubviews(profileImageView,
                                     moreButton,
                                     studentInfoLabel,
                                     redDot,
                                     favoriteButton,
                                     dateLabel)
        
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.size.equalTo(50)
            $0.leading.equalToSuperview().offset(14)
        }
        redDot.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(60)
            $0.size.equalTo(8)
        }
        
        moreButton.snp.makeConstraints {
            $0.width.height.equalTo(18)
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().inset(12)
        }
        
        studentInfoLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(2)
            $0.leading.equalToSuperview().offset(15)
            $0.trailing.equalToSuperview().inset(14)
            $0.bottom.equalTo(dateLabel.snp.top).offset(-17)
        }
        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.bottom.equalToSuperview().inset(12)
        }
        favoriteButton.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.trailing.equalToSuperview().inset(10)
            $0.bottom.equalToSuperview().inset(10)
        }
    }
    
    func configure(info: String,
                   date: String,
                   type: MessageButtonTabEnum,
                   isFavorite: Bool = false,
                   isRead: Bool = false,
                   isBlock: Bool = false,
                   isReport: Bool = false) {

        self.redDot.isHidden = isRead || isBlock || isReport
        self.studentInfoLabel.text = isBlock ? String.MessageTexts.blockMessage : info
        self.studentInfoLabel.text = isReport ? String.MessageTexts.reportMessage : info
        self.favoriteButton.isHidden = isBlock || isReport
        self.profileImageView.image = (isBlock || isReport) ? DesignSystemAsset.Images.icCaution.image : readImage
        studentInfoLabel.text = info
        dateLabel.text = date
        self.favoriteButton.setImage(isFavorite ? DesignSystemAsset.Images.icStarFill.image : DesignSystemAsset.Images.icStar.image, for: .normal)
        moreButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.onMoreButtonTap?()
            }
            .disposed(by: disposeBag)
        
        favoriteButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.isFavorite.toggle()
                self.updateFavoriteButtonImage()
                self.onFavoriteButtonTap?()
            }
            .disposed(by: disposeBag)
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
    
    private func updateFavoriteButtonImage() {
        let image = isFavorite
            ? DesignSystemAsset.Images.icStarFill.image // For example, a filled star for favorited state
            : DesignSystemAsset.Images.icStar.image     // Original star image for non-favorited state
        favoriteButton.setImage(image, for: .normal)
    }
}
