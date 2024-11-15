//
//  NotificationViewController.swift
//  NotificationFeature
//
//  Created by Kim dohyun on 8/19/24.
//

import DesignSystem
import UIKit
import Util

import Then
import Storage
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

public final class NotificationViewController: BaseViewController<NotificationViewReactor> {

    //MARK: - Properties
    private let notificationTableView: UITableView = UITableView()
    private let notificationDataSources: RxTableViewSectionedReloadDataSource<NotificationSection> = .init { dataSources, tableView, indexPath, sectionItem in
        
        switch sectionItem {
        case let .userNotificationItem(cellReactor):
            guard let notificationCell = tableView.dequeueReusableCell(withIdentifier: "NotificationTableViewCell", for: indexPath) as? NotificationTableViewCell else { return UITableViewCell() }
            notificationCell.reactor = cellReactor
            notificationCell.selectionStyle = .none
            return notificationCell
        }
    }
    
    //MARK: - LifeCycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .hideTabBar, object: nil)
    }

    //MARK: - Configure
    public override func setupUI() {
        super.setupUI()
        view.addSubview(notificationTableView)
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        
        notificationTableView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        navigationBar.do {
            $0.setNavigationBarUI(property: .leftWithCenterItem(
                DesignSystemAsset.Images.arrow.image,
                "알림"
            ))
            $0.setNavigationBarAutoLayout(property: .leftWithCenterItem)
        }
        
        
        notificationTableView.do {
            $0.register(NotificationTableViewCell.self, forCellReuseIdentifier: "NotificationTableViewCell")
            $0.rowHeight = UITableView.automaticDimension
            $0.estimatedRowHeight = 80
            $0.separatorStyle = .none
            $0.backgroundColor = .clear
            $0.showsVerticalScrollIndicator = false
        }
        
    }
    
    public override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        
        Observable.just(())
            .map { Reactor.Action.viewDidLoad }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$notificationSection)
            .asDriver(onErrorJustReturn: [])
            .drive(notificationTableView.rx.items(dataSource: notificationDataSources))
            .disposed(by: disposeBag)
        
        
        notificationTableView
            .rx.itemSelected
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.didTappedNotificationItem($0.item) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        notificationTableView
            .rx.prefetchRows
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { _ in Reactor.Action.fetchMoreItems }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        Observable
            .zip(
                reactor.pulse(\.$selectedType),
                reactor.pulse(\.$isCurrentDate),
                reactor.pulse(\.$voteResponseEntity)
            )
            .bind(with: self) { owner, response in
                switch response.0 {
                case .vote:
                    UserDefaultsManager.shared.voteRequest = []
                    let userInfo: [AnyHashable: Any] = ["voteOption": response.2]
                    NotificationCenter.default.post(name: .showVoteProccessController, object: nil, userInfo: userInfo)
                case .voteRecevied:
                    NotificationCenter.default.post(name: .showVoteInventoryViewController, object: nil)
                case .voteResults:
                    let userInfo: [AnyHashable: Any] = ["isCurrnetDate": response.1]
                    
                    NotificationCenter.default.post(name: .showVoteCompleteViewController, object: nil, userInfo: userInfo)
                default:
                    break
                }
            }
            .disposed(by: disposeBag)
        
    }
}
