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
    
    private var disposeBag = DisposeBag()
    var onMoreButtonTap: (() -> Void)?
    var unBlockButtonTap: (() -> Void)?
    var isFavorite: Bool = false
    private let redDot = UIView().then {
        $0.backgroundColor = UIColor(hex: "#FF4D4D")
        $0.layer.cornerRadius = 4
        
    }
    private let favoriteImage = UIImageView().then {
        $0.image = DesignSystemAsset.Images.icStarGoldFill.image
        $0.contentMode = .scaleAspectFit
    }
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 17
        $0.clipsToBounds = true
        $0.image = DesignSystemAsset.Images.boy.image
    }
    private let switchImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = DesignSystemAsset.Images.icVerticalSwitchArrorw.image
    }
    private let meLabel = WSLabel(wsFont: .Body09, text: "나").then {
        $0.textColor = DesignSystemAsset.Colors.gray100.color
    }
    private let meView = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.gray600.color
        $0.layer.cornerRadius = 8
    }
    private let nameLabel = WSLabel(wsFont: .Body09, text: "실명").then {
        $0.textColor = DesignSystemAsset.Colors.gray100.color
    }
    private let nameView = UIView().then {
        $0.backgroundColor = DesignSystemAsset.Colors.gray600.color
        $0.layer.cornerRadius = 8
    }
    private let myNameLabel = WSLabel(wsFont: .Body06)
    private let opponentNameLabel = WSLabel(wsFont: .Body06)
    
    private let opponentImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .clear
        $0.layer.cornerRadius = 17
        $0.clipsToBounds = true
        $0.image = DesignSystemAsset.Images.girl.image
    }
    
    private let moreButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Images.icEllipsis.image, for: .normal)
        $0.backgroundColor = .clear
    }

    private let dateLabel = WSLabel(wsFont: .Body09).then {
        $0.textColor = DesignSystemAsset.Colors.gray300.color
    }
    private let unBlockButton = UIButton().then {
        $0.setTitle("차단 해제", for: .normal)
        $0.titleLabel?.font = WSFont.Body09.font()
        $0.setTitleColor(DesignSystemAsset.Colors.gray100.color, for: .normal)
        $0.backgroundColor = DesignSystemAsset.Colors.gray500.color
        $0.layer.cornerRadius = 16
    }
    
    private func layout() {
        self.backgroundColor = DesignSystemAsset.Colors.gray700.color
        self.layer.cornerRadius = 12
        self.contentView.addSubviews(profileImageView,
                                     moreButton,
                                     opponentImageView,
                                     switchImage,
                                     redDot,
                                     meView,
                                     nameView,
                                     myNameLabel,
                                     unBlockButton,
                                     opponentNameLabel,
                                     dateLabel)
        
        self.meView.addSubview(meLabel)
        self.nameView.addSubviews(nameLabel, favoriteImage)
        
        profileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(22)
            $0.size.equalTo(34)
            $0.leading.equalToSuperview().offset(20)
        }
        switchImage.snp.makeConstraints {
            $0.size.equalTo(16)
            $0.top.equalTo(profileImageView.snp.bottom).offset(11)
            $0.leading.equalToSuperview().offset(29)
        }
        opponentImageView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20.5)
            $0.size.equalTo(34)
            $0.leading.equalToSuperview().offset(20)
        }
        redDot.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalToSuperview().offset(14)
            $0.size.equalTo(8)
        }
        
        meView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
            $0.height.equalTo(20)
            $0.width.equalTo(31)
        }
        meLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        nameView.snp.makeConstraints {
            $0.top.equalTo(switchImage.snp.bottom).offset(8)
            $0.leading.equalTo(opponentImageView.snp.trailing).offset(16)
            $0.height.equalTo(20)
            $0.width.equalTo(39)
        }
        myNameLabel.snp.makeConstraints {
            $0.top.equalTo(meView.snp.bottom).offset(4)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(16)
        }
        opponentNameLabel.snp.makeConstraints {
            $0.top.equalTo(nameView.snp.bottom).offset(4)
            $0.leading.equalTo(opponentImageView.snp.trailing).offset(16)
        }
        nameLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        favoriteImage.snp.makeConstraints {
            $0.size.equalTo(10)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(nameLabel.snp.leading).offset(-3.5)
        }
        
        moreButton.snp.makeConstraints {
            $0.width.height.equalTo(18)
            $0.top.equalToSuperview().offset(8)
            $0.trailing.equalToSuperview().inset(12)
        }
        
        dateLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(14)
            $0.bottom.equalToSuperview().inset(16)
        }
        
        unBlockButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().inset(16)
            $0.width.equalTo(65)
            $0.height.equalTo(28)
        }

    }
    
    func configure(myNickname: String,
                   opponentNickname: String,
                   myImaURL: String,
                   opponentImageURL: String,
                   date: String,
                   isFavorite: Bool,
                   isAnonymous: Bool = false,
                   isBlocked: Bool = false,
                   isRead: Bool) {
        self.profileImageView.kf.setImage(with: URL(string: myImaURL))
        self.opponentImageView.kf.setImage(with: URL(string: opponentImageURL))
        self.redDot.isHidden = !isRead
        self.myNameLabel.text = myNickname
        self.opponentNameLabel.text = opponentNickname
        if isFavorite {
            self.favoriteImage.isHidden = false
            self.nameView.snp.updateConstraints {
                $0.width.equalTo(51)
            }
        } else {
            self.favoriteImage.isHidden = true
            self.nameView.snp.updateConstraints {
                $0.width.equalTo(39)
            }
        }
        if isBlocked {
            unBlockButton.isHidden = false
            moreButton.isHidden = true
        } else {
            moreButton.isHidden = false
            unBlockButton.isHidden = true
        }
        self.nameLabel.text = isAnonymous ? "익명" : "실명"
        dateLabel.text = date
        moreButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.onMoreButtonTap?()
            }
            .disposed(by: disposeBag)
        unBlockButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.unBlockButtonTap?()
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
}
