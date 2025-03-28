//
//  RecviedMessageView.swift
//  MessageFeature
//
//  Created by 최지철 on 1/12/25.
//

import UIKit
import MessageDomain

import SnapKit
import RxSwift
import RxCocoa
import RxDataSources

final class RecviedMessageView: UIView {
    
    let didSelectMessage = PublishRelay<MessageContentModel>()
    let moreButtonTapped = PublishRelay<MessageContentModel>()
    private let messagesRelay = BehaviorRelay<[MessageContentModel]>(value: [])
    private var messageIndexDict = [Int: Int]()
    private let sectionsRelay = BehaviorRelay<[MessageSection]>(value: [MessageSection(header: "Messages", items: [])])

    let messageCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.register(MessageCollectionViewCell.self, forCellWithReuseIdentifier: String.MessageTexts.Identifier.messageCollectionViewCell)
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
                cell.configure(info: "From. " + item.studentInfo + item.senderName,
                               date: item.date,
                               type: .received,
                               read: item.isRead)
                cell.onMoreButtonTap = { [weak self] in
                    self?.moreButtonTapped.accept(item)
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
        layout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private static func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(200)
        )
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitems: [item, item]
        )
        group.interItemSpacing = .fixed(15)

        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        section.interGroupSpacing = 16
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
