//
//  DetailMessageStorageViewController.swift
//  MessageFeature
//
//  Created by 최지철 on 4/20/25.
//

import UIKit
import Util
import DesignSystem
import MessageDomain

import Then
import SnapKit
import RxSwift
import RxCocoa
import RxDataSources
import ReactorKit

public final class DetailMessageStorageViewController: BaseViewController<MessageWriteReactor> {
    

    private let customNavigationBar = DetailMessageCustomNaviBar()
    private let loadingIndicatorView: WSLottieIndicatorView = WSLottieIndicatorView()

    private let contentView = DetailMessageView()
    private lazy var messageHistoryCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: self.createLayout()).then {
            $0.backgroundColor = .clear
            $0.register(
                MessageHistoryCollectionViewCell.self,
                forCellWithReuseIdentifier: String.MessageTexts.Identifier.MessageHistoryCollectionViewCell
            )
        }
        return collectionView
    }()

    private let roomInfo: MessageRoomDetailEntity
    private let info: MessageRoomEntity

    
    //MARK: - LifeCycle
    
    public init(roomInfo: MessageRoomDetailEntity, info: MessageRoomEntity) {
        self.roomInfo = roomInfo
        self.info = info
        super.init()
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = DesignSystemAsset.Colors.gray600.color
        self.navigationBar.isHidden = true
        NotificationCenter.default.post(name: .hideTabBar, object: nil)
        self.reactor?.action.onNext(.tappedMessage(self.roomInfo.messages.last ?? MessageDetailEntity(id: 0, createdAt: "", content: "", direction: .received, isRead: false, isAbleToAnswer: false)))
        reactor?.action.onNext(.setReplyMessage(self.info))
    }
    
    //MARK: - Functions
    
    public override func setupUI() {
        super.setupUI()
        self.navigationBar.isHidden = true
        self.view.addSubviews(customNavigationBar,
                              contentView,
                              messageHistoryCollectionView)
        customNavigationBar.configureNavi(name: roomInfo.name,
                                          isAnonymous: roomInfo.isReceiverAnonymous, imageUrl: roomInfo.thumbnailURL ?? URL(fileURLWithPath: "")
                                          , isBookmarked: roomInfo.isBookmarked)
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        customNavigationBar.snp.makeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(60)
        }
        contentView.snp.makeConstraints {
            $0.top.equalTo(self.customNavigationBar.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.height.equalTo(464)
        }
        
        messageHistoryCollectionView.snp.makeConstraints {
            $0.top.equalTo(contentView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
            $0.height.equalTo(90)
        }

    }
    
    public override func setupAttributes() {
        super.setupAttributes()
    }
    
    public override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        bindState(reactor: reactor)
        bindAction(reactor: reactor)
    }
    
    private func bindState(reactor: Reactor) {
        Observable.just(roomInfo.messages)
            .do(onNext: { [weak self] messages in
                guard let self = self, !messages.isEmpty else { return }
                Task { @MainActor in
                    self.selectLastMessage()
                }
            })
            .bind(to: messageHistoryCollectionView.rx.items(cellIdentifier: String.MessageTexts.Identifier.MessageHistoryCollectionViewCell, cellType: MessageHistoryCollectionViewCell.self)) { index, item, cell in
                let dateStr = item.createdAt // .description은 필요 없습니다. createdAt이 이미 String 타입일 것입니다.
                cell.configureCell(date: dateStr, messageState: item.direction)
            }
            .disposed(by: disposeBag)
        
        reactor.state.map {$0.detailMessage}
            .observe(on: MainScheduler.instance)
            .bind(with: self) { this, detailMessage in
                this.contentView.configureView(isSent: detailMessage?.isAbleToAnswer ?? false, message: detailMessage?.content ?? "")
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$successDelete)
            .observe(on: MainScheduler.instance)
            .bind(with: self) { this, _ in
                this.loadingIndicatorView.isHidden = true
                this.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func bindAction(reactor: Reactor) {
        customNavigationBar.backButton.rx.tap
            .bind { _ in
                self.navigationController?.popViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        
        contentView.deleteButton.rx
            .tap
            .observe(on: MainScheduler.instance)
            .bind(with: self) { this, _ in
                WSAlertBuilder(showViewController: this)
                    .setAlertType(type: .titleWithMeesage)
                    .setTitle(title: "해당 쪽지를 삭제하시나요?",
                              titleAlignment: .left)
                    .setMessage(message: "삭제한 쪽지는 절대 되돌릴 수 없어요")
                    .setConfirm(text: "네 삭제할래요")
                    .setCancel(text: "닫기")
                    .action(.confirm) {
                        this.loadingIndicatorView.isHidden = false
                        reactor.action.onNext(.deleteMessage(reactor.currentState.detailMessage ?? MessageDetailEntity(id: 0, createdAt: "", content: "", direction: .received, isRead: false, isAbleToAnswer: false)))
                    }
                    .show()
            }
            .disposed(by: disposeBag)
        
        messageHistoryCollectionView.rx
            .modelSelected(MessageDetailEntity.self)
            .observe(on: MainScheduler.instance)
            .bind(with: self) { this, message in
                this.reactor?.action.onNext(.tappedMessage(message))
            }
            .disposed(by: disposeBag)
        
        contentView.replyButton.rx
            .tap
            .observe(on: MainScheduler.instance)
            .bind(with: self) { this, _ in
                let vc = MessageWriteViewController(reactor: reactor)
                this.navigationController?.pushViewController(vc,
                                                              animated: true)
            }
            .disposed(by: disposeBag)
            
    }
    
    private func createLayout() -> UICollectionViewLayout {
        // 1. Item: 개별 셀의 크기를 정의합니다.
        // 너비 80, 높이 90으로 설정합니다.
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
            heightDimension: .absolute(90)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        // 2. Group: 아이템들을 담는 그룹의 크기와 형태를 정의합니다.
        // 여기서는 아이템 1개가 그룹 1개가 되는 단순한 형태로, 수평 스크롤을 할 것입니다.
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .absolute(80),
            heightDimension: .absolute(90)
        )
        // .horizontal은 그룹 내의 아이템들이 수평으로 배치됨을 의미합니다.
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        // 3. Section: 그룹을 감싸는 섹션을 정의합니다.
        // 여기서 스크롤 방향, 그룹 간 간격, 섹션의 여백 등을 설정합니다.
        let section = NSCollectionLayoutSection(group: group)
        
        // ✅ 셀 간 간격을 16으로 설정합니다. (수평 스크롤에서는 그룹 간 간격이 곧 아이템 간 간격이 됩니다)
        section.interGroupSpacing = 16
        
        // ✅ 양 끝의 여백(inset)을 12로 설정합니다.
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
        
        // ✅ 수평 스크롤을 가능하게 합니다.
        section.orthogonalScrollingBehavior = .continuous

        // 4. Layout: 완성된 섹션을 기반으로 최종 레이아웃 객체를 생성합니다.
        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
    
    private func selectLastMessage() {
        // 메시지 데이터가 비어있는 경우를 대비
        guard !roomInfo.messages.isEmpty else { return }
        
        // 마지막 아이템의 인덱스를 계산
        let lastItemIndex = roomInfo.messages.count - 1
        
        // 마지막 아이템의 IndexPath 생성 (섹션은 0으로 가정)
        let indexPath = IndexPath(item: lastItemIndex, section: 0)
        
        // 해당 IndexPath의 셀을 선택하고, 수평 중앙으로 스크롤
        self.messageHistoryCollectionView.selectItem(
            at: indexPath,
            animated: true,
            scrollPosition: .centeredHorizontally
        )
    }
}

