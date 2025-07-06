//
//  BlockMessageListViewContoller.swift
//  MessageFeature
//
//  Created by 최지철 on 5/29/25.
//

import UIKit
import Util
import DesignSystem
import MessageDomain
import Storage

import ReactorKit
import Then
import SnapKit
import Kingfisher
import RxCocoa
import RxDataSources

final class BlockMessageListViewContoller: BaseViewController<MessageSettingReactor> {
    
    private let globalState: WSGlobalServiceProtocol = WSGlobalStateService.shared
    private let titleLabel = WSLabel(wsFont: .Header01, text: "차단한 쪽지방 목록")
    private let blockMessageList = UICollectionView(frame: .zero, collectionViewLayout: createLayout()).then {
        $0.register(MessageCollectionViewCell.self, forCellWithReuseIdentifier: String.MessageTexts.Identifier.messageCollectionViewCell)
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
    }
    private let sectionsRelay = BehaviorRelay<[MessageSection]>(value: [MessageSection(header: "Messages", items: [])])

    //MARK: - LifeCycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.reactor?.action.onNext(.fetchBlockList)
    }
    
    //MARK: - Functions
    
    public override func setupUI() {
        super.setupUI()
        self.view.addSubviews(titleLabel,
                              blockMessageList)
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.equalToSuperview().offset(30)
        }
        blockMessageList.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }

    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        navigationBar.do {
            $0.setNavigationBarUI(property: .leftIcon(
                DesignSystemAsset.Images.arrow.image
            ))
            $0.setNavigationBarAutoLayout(property: .leftIcon)
        }
    }
    
    public override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        bindState(reactor: reactor)
        bindAction(reactor: reactor)
    }
    
    private func bindState(reactor: Reactor) {
        
        let dataSource = RxCollectionViewSectionedAnimatedDataSource<MessageSection>(
            configureCell: { dataSource, collectionView, indexPath, item in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String.MessageTexts.Identifier.messageCollectionViewCell, for: indexPath) as! MessageCollectionViewCell
                cell.configure(myNickname: item.senderProfile.name,
                               opponentNickname: item.receiverProfile.name,
                               myImaURL: item.senderProfile.iconUrl,
                               opponentImageURL: item.receiverProfile.iconUrl,
                               date: self.convertDate(item.latestChatTime),
                               isFavorite: item.isBookmarked,
                               isAnonymous: item.senderProfile.isAnonymous,
                               isBlocked: item.isBlocked,
                               isRead: item.isExistsUnreadMessage)

                cell.unBlockButtonTap = { [weak self] in
                    WSAlertBuilder(showViewController: self!)
                        .setAlertType(type: .message)
                        .setTitle(title: "차단을 해제하시나요?",
                                  titleAlignment: .left)
                        .setConfirm(text: "차단 해제")
                        .setCancel(text: "닫기")
                        .action(.confirm) {
                            reactor.action.onNext(.unblcockMessage(item.id))
                        }
                        .show()
                }
                
                return cell
            }
        )
        
        reactor.state.map {$0.blockList}
            .map { [MessageSection(header: "Messages", items: $0)] }
            .bind(to: sectionsRelay)
            .disposed(by: disposeBag)
        
        sectionsRelay
            .bind(to: blockMessageList.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$compelteUnBlock)
            .observe(on: MainScheduler.instance)
            .bind(with: self) { this, result in
                if result {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        this.globalState.event.onNext(.showToast("해체 완료", type: .check))
                    }
                }
            }
            .disposed(by: disposeBag)
        
        globalState.event
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) {  this, type in
                switch type {
                case .showToast(let message, let type):
                    this.showWSToast(image: type, message: message)
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func bindAction(reactor: Reactor) {
        

    }
}
extension BlockMessageListViewContoller {
    private static func createLayout() -> UICollectionViewLayout {
        let groupHeight: CGFloat = 150
        let spacing: CGFloat = 12

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),  // count 매개변수를 사용할 경우 시스템이 자동으로 (전체너비 - spacing)/2 로 계산합니다.
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
            count: 1
        )
        group.interItemSpacing = .fixed(spacing)
        // 좌우 inset 없이 그룹 전체를 사용
        group.contentInsets = .zero
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = .zero
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func convertDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = inputFormatter.date(from: dateString) else {
            print("Error: Could not parse date string: \(dateString)")
            return dateString // 파싱 실패 시 원본 문자열을 반환
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy. MM. dd"
        outputFormatter.timeZone = TimeZone.current

        let finalDateString = outputFormatter.string(from: date)
        print("DEBUG: Original Date String: \(dateString)")
        print("DEBUG: Parsed Date: \(date)")
        print("DEBUG: Formatted Date String: \(finalDateString)") // <-- 이 값 확인
        
        return finalDateString
    }

}

