//
//  VoteResultViewController.swift
//  VoteFeature
//
//  Created by Kim dohyun on 7/13/24.
//

import DesignSystem
import UIKit
import Util

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

fileprivate typealias VoteResultStr = VoteStrings
fileprivate typealias VoteResultId = VoteStrings.Identifier
public final class VoteResultViewController: BaseViewController<VoteResultViewReactor> {
    
    //MARK: - Properties
    private lazy var voteResultCollectionViewLayout: UICollectionViewCompositionalLayout = UICollectionViewCompositionalLayout { [weak self] section, _ in
        return self?.createVoteResultSection()
    }
    private let loadingIndicator: WSLottieIndicatorView = WSLottieIndicatorView()
    private lazy var voteResultCollectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: voteResultCollectionViewLayout)
    private lazy var voteResultsCollectionViewDataSources: RxCollectionViewSectionedReloadDataSource<VoteResultSection> = .init { dataSources, collectionView, indexPath, sectionItem in
        switch sectionItem {
        case let .voteResultsItem(cellReactor):
            guard let voteResultsCell = collectionView.dequeueReusableCell(withReuseIdentifier: VoteResultId.voteResultCell , for: indexPath) as? VoteResultCollectionViewCell else { return UICollectionViewCell() }
            voteResultsCell.reactor = cellReactor
            return voteResultsCell
        }
    }
    private let confirmButton: WSButton = WSButton(wsButtonType: .default(12))
    private let backgrounImageView: UIImageView = UIImageView()
    private let resultPageControl: UIPageControl = UIPageControl()
    
    //MARK: - Configure
    public override func setupUI() {
        super.setupUI()
        view.addSubviews(voteResultCollectionView, confirmButton, backgrounImageView, resultPageControl)
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        
        voteResultCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(VoteConstraint.voteResultTopSpacing)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(resultPageControl.snp.top).offset(-16)
        }
        
        confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(12)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
        
        backgrounImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-98)
        }
        
        resultPageControl.snp.makeConstraints {
            $0.bottom.equalTo(confirmButton.snp.top).offset(-17)
            $0.centerX.equalToSuperview()
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        
        voteResultCollectionView.do {
            $0.register(VoteResultCollectionViewCell.self, forCellWithReuseIdentifier: VoteResultId.voteResultCell)
            $0.backgroundColor = .clear
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.isScrollEnabled = false
        }
        
        backgrounImageView.do {
            $0.image = DesignSystemAsset.Images.bgResultGradation.image
            $0.contentMode = .scaleAspectFill
        }
        
        confirmButton.do {
            $0.setupButton(text: VoteResultStr.voteMyResultButtonText)
            $0.isHidden = true
        }
        
        resultPageControl.do {
            $0.currentPage = 0
            $0.isUserInteractionEnabled = false
            $0.isHidden = true
        }
    }
    
    public override func bind(reactor: VoteResultViewReactor) {
        super.bind(reactor: reactor)
        
        Observable.just(())
            .map { Reactor.Action.fetchWinnerResultItems }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .bind(to: loadingIndicator.rx.isHidden)
            .disposed(by: disposeBag)
        
        confirmButton
            .rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                let voteInventoryController = DependencyContainer.shared.injector.resolve(VoteInventoryViewController.self)
                owner.navigationController?.pushViewController(voteInventoryController, animated: true)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$resultSection)
            .asDriver(onErrorJustReturn: [])
            .drive(voteResultCollectionView.rx.items(dataSource: voteResultsCollectionViewDataSources))
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.winnerResponseEntity }
            .map { $0.response.count }
            .distinctUntilChanged()
            .bind(to: resultPageControl.rx.numberOfPages)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.currentPage }
            .distinctUntilChanged()
            .bind(to: resultPageControl.rx.currentPage)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isShowing)
            .filter { $0 == true}
            .bind(with: self) { owner, _ in
                owner.shareToKakaoTalk()
            }
            .disposed(by: disposeBag)
        
        reactor.state
            .map { !$0.isLoading }
            .distinctUntilChanged()
            .bind(to: confirmButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { !$0.isLoading }
            .distinctUntilChanged()
            .bind(to: resultPageControl.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    private func createVoteResultSection() -> NSCollectionLayoutSection {
        let verticalInset = (voteResultCollectionView.frame.height - VoteConstraint.voteResultItemHeight) / 2
        
        let voteResultItemSize: NSCollectionLayoutSize = .init(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(VoteConstraint.voteResultItemHeight)
        )
        
        let voteResultItem: NSCollectionLayoutItem = NSCollectionLayoutItem(layoutSize: voteResultItemSize)
        
        voteResultItem.contentInsets = .init(top: 0, leading: 25, bottom: 0, trailing: 25)
        
        let voteResultGroupSize: NSCollectionLayoutSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.8),
            heightDimension: .absolute(VoteConstraint.voteResultItemHeight)
        )
        
        let voteResultGroup: NSCollectionLayoutGroup = NSCollectionLayoutGroup.horizontal(
            layoutSize: voteResultGroupSize,
            subitems: [voteResultItem]
        )
        voteResultGroup.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let voteResultSection: NSCollectionLayoutSection = NSCollectionLayoutSection(group: voteResultGroup)
        voteResultSection.orthogonalScrollingBehavior = .groupPagingCentered
        voteResultSection.contentInsets = .init(top: verticalInset, leading: 40, bottom: 0, trailing: 40)

        voteResultSection.visibleItemsInvalidationHandler = { [weak self] visibleItems, offset, env in
            visibleItems.forEach { item in
                
                let position = offset.x / (env.container.contentSize.width * 0.8)
                let roundPosition = Int(round(position))
            
                let intersectedRect = item.frame.intersection(CGRect(x: offset.x, y: offset.y, width: env.container.contentSize.width, height: item.frame.height))
                let percentVisible = intersectedRect.width / item.frame.width
                
                let originalHeight: CGFloat = 392
                let reducedHeight: CGFloat = 334
                
                let height = reducedHeight + (originalHeight - reducedHeight) * percentVisible
            
                self?.reactor?.action.onNext(.didShowVisibleCell(roundPosition))
                item.transform = CGAffineTransform(scaleX: 1.0, y: height / originalHeight)

            }
        }
        return voteResultSection
    }
}
