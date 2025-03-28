//
//  SentMessageView.swift
//  MessageFeature
//
//  Created by 최지철 on 1/12/25.
//

import UIKit
import MessageDomain

import SnapKit
import RxSwift
import RxCocoa

final class SentMessageView: UIView {
    let didSelectMessage = PublishRelay<MessageContentModel>()
    let deleteButtonTapped = PublishRelay<MessageContentModel>()
    
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
    
    func bind(sentMessages: [MessageContentModel]) {
        Observable.just(sentMessages)
            .bind(to: messageCollectionView.rx.items(
                cellIdentifier: String.MessageTexts.Identifier.messageCollectionViewCell,
                cellType: MessageCollectionViewCell.self
            )) { idx, item, cell in
                cell.configure(info: "To. " + item.studentInfo + item.reciverName,
                               date: item.date,
                               type: .sent,
                               read: item.isRead)
                cell.onDeleteButtonTap = { [weak self] in
                    self?.deleteButtonTapped.accept(item)
                  }
            }
            .disposed(by: disposeBag)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        messageCollectionView.delegate = nil
        messageCollectionView.dataSource = nil
        
        layout()
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
