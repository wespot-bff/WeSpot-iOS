//
//  VoteResultCollectionViewCell.swift
//  VoteFeature
//
//  Created by Kim dohyun on 7/14/24.
//

import DesignSystem
import UIKit

import ReactorKit
import RxCocoa
import Kingfisher

final class VoteResultCollectionViewCell: UICollectionViewCell {
    
    //MARK: - Properties
    private let rankView: VoteRankView = VoteRankView()
    private let descriptionLabel: WSLabel = WSLabel(wsFont: .Body03)
    private let faceView: UIView = UIView()
    private let faceImageView: UIImageView = UIImageView()
    private let nameLabel: WSLabel = WSLabel(wsFont: VoteConstraint.voteResultNameLableFont)
    private let introduceLabel: WSLabel = WSLabel(wsFont: .Body07)
    private let resultContainerView: UIView = UIView()
    private let resultDescriptionLabel: WSLabel = WSLabel(wsFont: .Body06)
    var disposeBag: DisposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupAutoLayout()
        setupAttributes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        resultContainerView.addSubview(resultDescriptionLabel)
        faceView.addSubview(faceImageView)
        contentView.addSubviews(rankView, descriptionLabel, faceView, nameLabel, introduceLabel, resultContainerView)
    }
    
    //MARK: - Configure
    private func setupAutoLayout() {
        rankView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(VoteConstraint.voteResultRankViewTopSpacing)
            $0.left.equalToSuperview().offset(VoteConstraint.voteResultRankViewLeftSpacing)
            $0.width.equalTo(VoteConstraint.voteResultRankViewWidth)
            $0.height.equalTo(VoteConstraint.voteResultRankViewHeight)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(rankView.snp.bottom).offset(VoteConstraint.voteResultDescriptionLabelTopSpacing)
            $0.left.equalToSuperview().offset(20)
            $0.height.equalTo(48)
            $0.width.equalTo(207)
        }
        
        faceView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(VoteConstraint.voteResultFaceImageViewTopSpacing)
            $0.size.equalTo(VoteConstraint.voteResultFaceImageViewSize)
            $0.centerX.equalToSuperview()
        }
        
        faceImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(faceImageView.snp.bottom).offset(VoteConstraint.voteResultNameLabelTopSpacing)
            $0.height.equalTo(VoteConstraint.voteResultNameLabelHeight)
            $0.centerX.equalToSuperview()
        }
        
        introduceLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(VoteConstraint.voteResultIntroduceLabelTopSpacing)
            $0.height.equalTo(VoteConstraint.voteResultIntroduceLabelHeight)
            $0.centerX.equalToSuperview()
        }
        
        resultContainerView.snp.makeConstraints {
            $0.top.equalTo(introduceLabel.snp.bottom).offset(VoteConstraint.voteResultContainerViewTopSpacing)
            $0.height.equalTo(32)
            $0.centerX.equalToSuperview()
        }
        
        resultDescriptionLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(12)
            $0.verticalEdges.equalToSuperview().inset(5)
        }
    }
    
    private func setupAttributes() {
        
        self.do {
            $0.backgroundColor = DesignSystemAsset.Colors.white.color.withAlphaComponent(0.15)
            $0.layer.cornerRadius = 20
            $0.clipsToBounds = true
        }
        
        resultContainerView.do {
            $0.backgroundColor = DesignSystemAsset.Colors.gray500.color
            $0.layer.cornerRadius = 8
            $0.clipsToBounds = true
        }

        resultDescriptionLabel.do {
            $0.text = "전체 결과 보기"
            $0.textColor = DesignSystemAsset.Colors.gray100.color
        }
        
        introduceLabel.do {
            $0.text = "안녕! 모르는거 있으면 나한테 다 물어봐"
            $0.textColor = DesignSystemAsset.Colors.gray300.color
        }
        
        nameLabel.do {
            $0.text = "이지호"
            $0.textColor = DesignSystemAsset.Colors.primary300.color
        }
        
        rankView.do {
            $0.rankLabel.text = "10표"
            $0.rankImageView.image = DesignSystemAsset.Images.icResultCrwonFiled.image
            $0.layer.cornerRadius = VoteConstraint.voteResultRankViewRadius
            $0.layer.masksToBounds = true
            $0.clipsToBounds = true
            $0.layer.borderColor = DesignSystemAsset.Colors.gray300.color.cgColor
            $0.layer.borderWidth = 1
        }
        
        faceView.do {
            $0.layer.cornerRadius = VoteConstraint.voteResultFaceImageViewSize / 2
            $0.clipsToBounds = true
            $0.backgroundColor = .clear
        }
        
        faceImageView.do {
            $0.image = DesignSystemAsset.Images.imgResultCharacter.image
        }
        
        descriptionLabel.do {
            $0.text = "우리 반에서 모르는게생기면물어보고싶은은은은은은은은 친구는?"
            $0.textColor = DesignSystemAsset.Colors.gray100.color
        }
    }
}

extension VoteResultCollectionViewCell: ReactorKit.View {
    
    func bind(reactor: VoteResultCellReactor) {
        
        resultContainerView
            .rx.tap
            .map { Reactor.Action.didTappedResultButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
        reactor.state
            .map { $0.content }
            .distinctUntilChanged()
            .bind(to: descriptionLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { "\($0.voteCount)표" }
            .distinctUntilChanged()
            .bind(to: rankView.rankLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.winnerUser }
            .map { $0.name }
            .distinctUntilChanged()
            .bind(to: nameLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.winnerUser }
            .map { $0.introduction }
            .distinctUntilChanged()
            .bind(to: introduceLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.winnerUser?.profile.iconUrl }
            .bind(with: self) { owner, iconURL in
                owner.faceImageView.kf.setImage(with: iconURL)
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.winnerUser?.profile.backgroundColor }
            .map { UIColor(hex: $0) }
            .distinctUntilChanged()
            .bind(to: faceView.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        reactor.state
            .filter { $0.winnerUser == nil }
            .map { _ in "분석 중이에요"}
            .distinctUntilChanged()
            .bind(to: nameLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .filter { $0.winnerUser == nil }
            .map { _ in "더 많은 친구들의 투표가 필요해요" }
            .distinctUntilChanged()
            .bind(to: introduceLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .filter { $0.winnerUser == nil }
            .map { _ in "친구에게 데려오기" }
            .distinctUntilChanged()
            .bind(to: resultDescriptionLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.state
            .filter { $0.winnerUser == nil }
            .map { _ in DesignSystemAsset.Images.icVoteAnalyze.image }
            .distinctUntilChanged()
            .bind(to: faceImageView.rx.image)
            .disposed(by: disposeBag)
        
        reactor.state
            .filter { $0.winnerUser == nil }
            .map { _ in UIColor.clear }
            .distinctUntilChanged()
            .bind(to: faceView.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        reactor.state
            .filter { $0.winnerUser == nil }
            .map { _ in "??표" }
            .distinctUntilChanged()
            .bind(to: rankView.rankLabel.rx.text)
            .disposed(by: disposeBag)
        
    }
}
