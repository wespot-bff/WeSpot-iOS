//
//  MessageStorageViewController.swift
//  MessageFeature
//
//  Created by eunseou on 7/20/24.
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

public final class MessageStorageViewController: BaseViewController<MessageStorageReactor>, UIScrollViewDelegate {
    
    //MARK: - Properties
    
    private let globalState: WSGlobalServiceProtocol = WSGlobalStateService.shared
    private let allMessageButton = UIButton().then {
        $0.setTitle(String.MessageTexts.messageInventoryAllButton, for: .normal)
        $0.setImage(UIImage(systemName: "text.justify"), for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit // 이미지의 비율을 유지하며 공간에 맞춤
        $0.titleLabel?.font = WSFont.Body05.font()
        $0.layer.cornerRadius = 12
        
        $0.imageView?.snp.makeConstraints { make in
            make.size.equalTo(18)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
        }
    }

    private let favoriteMessageButton = UIButton().then {
        $0.setTitle(String.MessageTexts.messageInventoryFavoriteButton, for: .normal)
        $0.setImage(DesignSystemAsset.Images.icStarFill.image, for: .normal)
        $0.imageView?.contentMode = .scaleAspectFit
        $0.titleLabel?.font = WSFont.Body05.font()
        $0.layer.cornerRadius = 12
        
        $0.imageView?.snp.makeConstraints { make in
            make.size.equalTo(18)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(12)
        }
    }
    private let allMessageView = AllMessageView()
    private let favoriteMessageView = FavoriteMessageView()
    
    //MARK: - LifeCycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: - Functions
    public override func setupUI() {
        super.setupUI()
        self.view.addSubviews(allMessageButton,
                              favoriteMessageButton,
                              favoriteMessageView,
                              allMessageView)
        allMessageButton.updateTabStyle(isActive: true)
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        
        allMessageButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.width.equalTo(76)
            $0.height.equalTo(31)
        }
        
        favoriteMessageButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(6)
            $0.leading.equalTo(allMessageButton.snp.trailing).offset(12)
            $0.width.equalTo(95)
            $0.height.equalTo(31)
        }
        
        favoriteMessageView.snp.makeConstraints {
            $0.top.equalTo(favoriteMessageButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        allMessageView.snp.makeConstraints {
            $0.top.equalTo(favoriteMessageButton.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()

    }
    
    public  override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        favoriteMessageView.messageCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        allMessageView.messageCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: Reactor) {
                
        self.rx.viewWillAppear
            .bind(onNext: {  _ in
                reactor.action.onNext(.loadMessagesRoom)
            })
            .disposed(by: disposeBag)
        
        favoriteMessageButton.rx.tap
            .bind(onNext: {
                reactor.action.onNext(.favoriteMessageButtonTapped)
            })
            .disposed(by: disposeBag)
        
        allMessageButton.rx.tap
            .bind(onNext: {
                reactor.action.onNext(.receivedMessageButtonTapped)
            })
            .disposed(by: disposeBag)
        
        allMessageView
            .didSelectMessage
            .bind(onNext: {  message in
                reactor.action.onNext(.goToMessageRoom(message, self))
            })
            .disposed(by: disposeBag)
        
        favoriteMessageView
            .didSelectMessage
            .bind(onNext: {  message in
                reactor.action.onNext(.goToMessageRoom(message, self))
            })
            .disposed(by: disposeBag)
        
        allMessageView.moreButtonTapped
            .bind(with: self, onNext: {  this, message in
                this.showBottomSheet(with: message, message.isBookmarked)
            })
            .disposed(by: disposeBag)
        
        favoriteMessageView.moreButtonTapped
            .bind(with: self, onNext: {  this, message in
                this.showBottomSheet(with: message, message.isBookmarked)
            })
            .disposed(by: disposeBag)
        
        allMessageView.messageCollectionView.rx
            .reachedBottom
            .throttle(.seconds(1),
                      scheduler: MainScheduler.instance)
            .bind(onNext: {  _ in
                
            })
            .disposed(by: disposeBag)
        
        favoriteMessageView.messageCollectionView.rx
            .reachedBottom
            .throttle(.seconds(1),
                      scheduler: MainScheduler.instance)
            .bind(onNext: {  _ in
                
            })
            .disposed(by: disposeBag)
        
        favoriteMessageView.unFavoriteButtonTapped
            .bind(onNext: {  message in
                reactor.action.onNext(.unBookMarked(message))
            })
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: Reactor) {
        reactor.state
            .map { $0.tabState}
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(with: self) {  this, tabState in
                this.updateButtonStyles(for: tabState)
                switch tabState {
                case .received:
                    this.allMessageView.isHidden = false
                    this.favoriteMessageView.isHidden = true
                case .favorite:
                    this.favoriteMessageView.isHidden = false
                    this.allMessageView.isHidden = true
                }

            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$roomList)
            .filter{ $0.count > 0 }
            .bind(with: self) { this, messages in
                this.allMessageView.loadMessages(newMessages: messages)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$favoriteMessageList)
            .filter{ $0.count > 0 }
            .bind(with: self) { this, messages in
                print("favorite message list: \(messages)")
                this.favoriteMessageView.loadMessages(newMessages: messages)
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
}
extension MessageStorageViewController {
    private func updateButtonStyles(for tabState: MessageButtonTabEnum) {
        allMessageButton.updateTabStyle(isActive: tabState == .received)
        favoriteMessageButton.updateTabStyle(isActive: tabState == .favorite)
    }
    
    private func showBottomSheet(with message: MessageRoomEntity, _ isBookMarked: Bool) {
        guard let reactor = self.reactor else { return }
        
        let bottomSheetVC = DependencyContainer.shared.injector.resolve(
            MessageStorageBottomSheetViewController.self,
            arguments: message, isBookMarked, reactor
        )
        
        bottomSheetVC.modalPresentationStyle = .pageSheet
        if let sheet = bottomSheetVC.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    .custom { _ in return 156 }
                ]
                sheet.preferredCornerRadius = 25
            }
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        self.present(bottomSheetVC, animated: true)
    }
}


