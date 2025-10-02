//
//  MessageSettingViewController.swift
//  MessageFeature
//
//  Created by 최지철 on 5/29/25.
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

public final class MessageSettingViewController: BaseViewController<MessageSettingReactor> {
    
    private let listTableView = UITableView().then {
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.register(MessageSettingTableViewCell.self,
                        forCellReuseIdentifier: String.MessageTexts.Identifier.MessageSettingTableViewCell)
        $0.backgroundColor = .clear
    }
    
    //MARK: - LifeCycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .hideTabBar, object: nil)
    }
    
    //MARK: - Functions
    
    public override func setupUI() {
        super.setupUI()
        self.view.addSubview(listTableView)
        listTableView
            .rx
            .setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        listTableView.snp.makeConstraints {
            $0.top.equalTo(self.navigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(300)
        }

    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        navigationBar.do {
            $0.setNavigationBarUI(property: .leftWithCenterItem(
                DesignSystemAsset.Images.arrow.image,
                "쪽지 설정"
            ))
            $0.setNavigationBarAutoLayout(property: .leftWithCenterItem)
        }
    }
    
    public override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        bindState(reactor: reactor)
        bindAction(reactor: reactor)
    }
    
    private func bindState(reactor: Reactor) {
        reactor.state
            .map {$0.settingList}
            .observe(on: MainScheduler.instance)
            .bind(to: listTableView.rx.items(
                cellIdentifier: String.MessageTexts.Identifier.MessageSettingTableViewCell,
                cellType: MessageSettingTableViewCell.self))
                { index, item, cell in
                    cell.selectionStyle = .none
                    cell.configureCell(title: item.title)
                }
                .disposed(by: disposeBag)
    }
    
    private func bindAction(reactor: Reactor) {
        
        listTableView.rx
            .modelSelected(MessageSettingListEnum.self)
            .bind {  list in
                print("list: \(list)")
                reactor.action.onNext(.routeToList(list, self))
            }
            .disposed(by: disposeBag)

    }
}
extension MessageSettingViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let contentHeightInsideContainer: CGFloat = 30 // titleLabel, chevronIcon 등이 차지하는 순수 높이
        let verticalPaddingForContainer: CGFloat = 12  // containerView의 상/하 각각의 패딩
        
        return contentHeightInsideContainer + (verticalPaddingForContainer * 2) // 예: 30 + (12 * 2) = 54
    }
}
