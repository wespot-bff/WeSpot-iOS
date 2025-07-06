//
//  MessageStorageBottomSheetViewController.swift
//  MessageFeature
//
//  Created by 최지철 on 1/15/25.
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

public final class MessageStorageBottomSheetViewController: BaseViewController<MessageStorageReactor> {

    //MARK: - Properties
    
    private var message: MessageRoomEntity?
    private let buttonTableView = UITableView().then {
        $0.register(MessageBottomSheetTabelViewCell.self,
                    forCellReuseIdentifier: String.MessageTexts.Identifier.MessageBottomSheetTabelViewCell)
        $0.isScrollEnabled = false
    }
    private var items: [MessageBottomSheetButtonList] = []
    
    //MARK: - LifeCycle
    
    // Reactor를 주입받도록 init을 수정해야 합니다 (이전 답변에서 제안된 내용).
    public override init() {
        super.init()
    }
    
    // 이전 답변에서 제안된 convenience init (reactor 파라미터 포함)
    public convenience init(message: MessageRoomEntity, isFavorite: Bool, reactor: MessageStorageReactor) {
        
        self.init(reactor: reactor) // BaseViewController에 init(reactor:)가 있다고 가정
        self.message = message
        if let message = self.message {
             reactor.action.onNext(.setBottomSheetButtonList(message))
         }
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = DesignSystemAsset.Colors.gray600.color
    }
    
    //MARK: - Functions
    public override func setupUI() {
        super.setupUI()
        self.view.addSubview(buttonTableView)
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        buttonTableView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(15)
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        navigationBar.isHidden = true
        buttonTableView.do {
            $0.backgroundColor = .clear
            $0.separatorStyle = .singleLine
            $0.separatorColor = DesignSystemAsset.Colors.gray500.color
        }
    }
    
    public override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        buttonTableView.rx.setDelegate(self).disposed(by: disposeBag) // 이 부분은 그대로 둡니다.
        
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
    }
    
    private func bindAction(reactor: Reactor) {
        buttonTableView.rx.modelSelected(MessageBottomSheetButtonList.self)
            .observe(on: MainScheduler.instance)
            .bind(with: self) { owner, item in
                switch item {
                case .block:
                    reactor.action.onNext(.blockMessage(self.message!))
                case .unFavorite:
                    reactor.action.onNext(.bookMarked(self.message!))
                case .favorite:
                    reactor.action.onNext(.bookMarked(self.message!))
                }
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
            
    }
    
    private func bindState(reactor: Reactor) {
        reactor.pulse(\.$bottomSheetButtonList) // @Pulse로 변경했으므로 pulse 사용
            .bind(to: buttonTableView.rx.items(
                cellIdentifier: String.MessageTexts.Identifier.MessageBottomSheetTabelViewCell,
                cellType: MessageBottomSheetTabelViewCell.self
            )) { row, element, cell in
                cell.configureCell(text: element.titleText)
            }
            .disposed(by: disposeBag)
    }
}

