//
//  SentMessageView.swift
//  MessageFeature
//
//  Created by 최지철 on 1/12/25.
//

import UIKit
import MessageDomain

import RxDataSources
import SnapKit
import RxSwift
import RxCocoa

final class FavoriteMessageView: UIView {
    let didSelectMessage = PublishRelay<MessageContentModel>()
    let unFavoriteButtonTapped = PublishRelay<MessageContentModel>()
    let moreButtonTapped = PublishRelay<MessageContentModel>()
    private let sectionsRelay = BehaviorRelay<[MessageSection]>(value: [MessageSection(header: "Messages", items: [])])
    let messageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.register(MessageCollectionViewCell.self,
                    forCellWithReuseIdentifier: String.MessageTexts.Identifier.messageCollectionViewCell)
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
    }
    
    private let disposeBag = DisposeBag()
    
    private func layout() {
        self.addSubview(messageCollectionView)
        messageCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
    }
    
    func loadMessages(newMessages: [MessageContentModel]) {
        // 전체 새로운 목록으로 대체 (애니메이션 효과와 함께 업데이트됨)
        let newSection = MessageSection(header: "Messages", items: newMessages)
        sectionsRelay.accept([newSection])
    }
    
    private func bind() {
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<MessageSection>(
            configureCell: { dataSource, collectionView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String.MessageTexts.Identifier.messageCollectionViewCell, for: indexPath) as! MessageCollectionViewCell
                cell.configure(info: item.studentInfo,
                               date: item.date,
                               type: .favorite)
                cell.onMoreButtonTap = { [weak self] in
                    self?.moreButtonTapped.accept(item)
                }
                
                cell.onFavoriteButtonTap = { [weak self] in
                    self?.unFavoriteButtonTapped.accept(item)
                }
                return cell
            }
        )
        
        sectionsRelay
            .bind(to: messageCollectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        messageCollectionView.rx.modelSelected(MessageContentModel.self)
            .bind(with: self) { this, message in
                this.didSelectMessage.accept(message)
            }
            .disposed(by: disposeBag)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        messageCollectionView.delegate = nil
        messageCollectionView.dataSource = nil
        bind()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func createLayout() -> UICollectionViewLayout {
        let groupHeight: CGFloat = 170
        let spacing: CGFloat = 15

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),  // count 매개변수를 사용할 경우 시스템이 자동으로 (전체너비 - spacing)/2 로 계산합니다.
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = .zero
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(groupHeight)
        )
        // count 매개변수를 사용하면, 시스템이 각 셀의 너비를 (전체너비 - interItemSpacing)/count 로 계산합니다.
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: item,
            count: 2
        )
        group.interItemSpacing = .fixed(spacing)
        // 좌우 inset 없이 그룹 전체를 사용
        group.contentInsets = .zero
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = .zero
        
        return UICollectionViewCompositionalLayout(section: section)
    }

}
