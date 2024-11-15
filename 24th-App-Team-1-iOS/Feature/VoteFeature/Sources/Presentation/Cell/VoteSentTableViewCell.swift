//
//  VoteSentTableViewCell.swift
//  VoteFeature
//
//  Created by Kim dohyun on 8/8/24.
//

import DesignSystem
import UIKit

import ReactorKit
import Kingfisher
import RxCocoa


final class VoteSentTableViewCell: UITableViewCell {
    
    private let sentContainerView: UIView = UIView()
    private let sentTitleLabel: WSLabel = WSLabel(wsFont: .Body04)
    private let sentDescriptionLabel: WSLabel = WSLabel(wsFont: .Body07)
    private let sentImageView: UIImageView = UIImageView()
    var disposeBag: DisposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupAutoLayout()
        setupAttributeds()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0))
    }
    
    private func setupUI() {
        sentContainerView.addSubviews(sentImageView, sentTitleLabel, sentDescriptionLabel)
        contentView.addSubviews(sentContainerView)
    }
    
    private func setupAutoLayout() {
        
        sentContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        sentImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(20)
            $0.size.equalTo(40)
        }
        
        sentTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(18)
            $0.left.equalTo(sentImageView.snp.right).offset(12)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(24)
        }
        
        sentDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(sentTitleLabel.snp.bottom)
            $0.left.equalTo(sentTitleLabel)
            $0.height.equalTo(20)
        }
    }
    
    private func setupAttributeds() {
        
        self.do {
            $0.backgroundColor = .clear
        }
        
        sentContainerView.do {
            $0.backgroundColor = DesignSystemAsset.Colors.gray700.color
            $0.layer.cornerRadius = 14
            $0.clipsToBounds = true
        }
        sentImageView.do {
            $0.image = DesignSystemAsset.Images.imgInventoryProfileFiled.image
        }
        
        sentTitleLabel.do {
            $0.textColor = DesignSystemAsset.Colors.gray100.color
            $0.text = "김선희에게 투표했어요"
            $0.lineBreakMode = .byTruncatingTail
        }
        
        sentDescriptionLabel.do {
            $0.textColor = DesignSystemAsset.Colors.gray300.color
            $0.text = "우리 반에서 애교가 가장 많은 친구"
        }
        
    }
}


extension VoteSentTableViewCell: ReactorKit.View {
    func bind(reactor: VoteSentCellReactor) {
        
        reactor.state
            .map {"\($0.userName)에게 투표했어요"}
            .distinctUntilChanged()
            .bind(to: sentTitleLabel.rx.text)
            .disposed(by: disposeBag)
        
        
        reactor.state
            .map { $0.title }
            .distinctUntilChanged()
            .bind(to: sentDescriptionLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.profileImage }
            .distinctUntilChanged()
            .bind(with: self) { owner, imageURL in
                owner.sentImageView.kf.setImage(with: imageURL)
            }
            .disposed(by: disposeBag)
    }
}
