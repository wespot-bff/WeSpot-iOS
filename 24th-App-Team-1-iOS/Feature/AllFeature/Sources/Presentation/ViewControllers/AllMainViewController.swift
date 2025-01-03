//
//  AllMainViewController.swift
//  AllFeature
//
//  Created by Kim dohyun on 8/11/24.
//

import DesignSystem
import UIKit
import Util
import Storage

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import Kingfisher
import RxDataSources

public final class AllMainViewController: BaseViewController<AllMainViewReactor> {

    //MARK: - Properties
    private let profileContainerView: UIView = UIView()
    private let profileImageView: UIImageView = UIImageView()
    private let profileNameLabel: WSLabel = WSLabel(wsFont: .Body02)
    private let profileClassLabel: WSLabel = WSLabel(wsFont: .Body06)
    private let profileEditButton: WSButton = WSButton(wsButtonType: .secondaryButton)
    private let loadingIndicatorView: WSLottieIndicatorView = WSLottieIndicatorView()
    private let voteAddBanner: WSBanner = WSBanner(image: DesignSystemAsset.Images.icProfileVoteFiled.image, titleText: "더 다양한 선택지를 원한다면? ", subText: "위스팟에게 알려주세요")
    private let mainTableView: UITableView = UITableView()
    private let mainDataSources: RxTableViewSectionedReloadDataSource<AllMainSection> = .init { dataSources, tableView, indexPath, sectionItem in
        
        switch sectionItem {
        case let .appInfoItem(title):
            guard let appInfoCell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
            appInfoCell.bind(title)
            appInfoCell.selectionStyle = .none
            return appInfoCell
        case let .movementItem(title):
            guard let movementCell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
            movementCell.bind(title)
            movementCell.selectionStyle = .none
            return movementCell
        case let .makerInfoItem(title):
            guard let makerCell = tableView.dequeueReusableCell(withIdentifier: "MainTableViewCell", for: indexPath) as? MainTableViewCell else { return UITableViewCell() }
            makerCell.selectionStyle = .none
            makerCell.bind(title)
            return makerCell
        }
    }
    
    //MARK: - LifeCycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .showTabBar, object: nil)
    }

    //MARK: - Configure
    public override func setupUI() {
        super.setupUI()
        
        profileContainerView.addSubview(profileImageView)
        view.addSubviews(profileContainerView, profileNameLabel, profileClassLabel, profileEditButton, voteAddBanner, mainTableView)
        
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        
        profileContainerView.snp.makeConstraints {
            $0.size.equalTo(48)
            $0.left.equalToSuperview().inset(24)
            $0.top.equalTo(navigationBar.snp.bottom).offset(16)
        }
        
        profileImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        profileNameLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(16)
            $0.left.equalTo(profileContainerView.snp.right).offset(12)
            $0.height.equalTo(27)
        }
        
        profileClassLabel.snp.makeConstraints {
            $0.top.equalTo(profileNameLabel.snp.bottom)
            $0.left.equalTo(profileNameLabel)
            $0.width.equalTo(180)
        }
        
        profileEditButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(24)
            $0.width.equalTo(75)
            $0.height.equalTo(28)
            $0.centerY.equalTo(profileImageView)
        }
        
        voteAddBanner.snp.makeConstraints {
            $0.top.equalTo(profileClassLabel.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(ProfileConstraint.profileBannerViewHeight)
        }
        
        mainTableView.snp.makeConstraints {
            $0.top.equalTo(voteAddBanner.snp.bottom).offset(ProfileConstraint.profileTableViewTopSpacing)
            $0.horizontalEdges.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview()
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        
        navigationBar.do {
            $0.setNavigationBarUI(property: .rightIcon(DesignSystemAsset.Images.icNavigationBarSettingFiled.image))
            $0.setNavigationBarAutoLayout(property: .rightIcon(40, 40))
        }
        
        profileContainerView.do {
            $0.backgroundColor = DesignSystemAsset.Colors.primary300.color
            $0.layer.cornerRadius = 48 / 2
            $0.clipsToBounds = true
        }
        
        
        profileNameLabel.do {
            $0.textAlignment = .left
        }
        
        profileClassLabel.do {
            $0.textAlignment = .left
            $0.numberOfLines = 0
            $0.lineBreakMode = .byTruncatingTail
        }
        
        profileEditButton.do {
            $0.setupButton(text: "프로필 수정")
            $0.setupFont(font: .Body09)
            $0.layer.cornerRadius = 14
        }
        
        voteAddBanner.do {
            $0.setBorderColor()
        }
        
        mainTableView.do {
            $0.register(MainTableViewCell.self, forCellReuseIdentifier: "MainTableViewCell")
            $0.register(MainTableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "MainTableViewHeaderFooterView")
            $0.rowHeight = 50
            $0.isScrollEnabled = false
            $0.separatorStyle = .none
            $0.backgroundColor = .clear
        }
        
    }
    
    public override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        
        self.rx.viewWillAppear
            .map { _ in Reactor.Action.viewWillAppear }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        navigationBar
            .rightBarButton.rx.tap
            .bind(with: self) { owner, _ in
                let profileAppSettingViewController = DependencyContainer.shared.injector.resolve(ProfileAppSettingViewController.self)
                owner.navigationController?.pushViewController(profileAppSettingViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$mainAllSection)
            .asDriver(onErrorJustReturn: [])
            .drive(mainTableView.rx.items(dataSource: mainDataSources))
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$accountProfileEntity)
            .map { $0?.profile.iconUrl }
            .filter { $0 == nil }
            .map { _ in DesignSystemAsset.Images.profile.image }
            .distinctUntilChanged()
            .bind(to: profileImageView.rx.image)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$accountProfileEntity)
            .map { $0?.profile.iconUrl }
            .filter { $0 != nil }
            .compactMap { URL(string: $0 ?? "")}
            .observe(on: MainScheduler.asyncInstance)
            .distinctUntilChanged()
            .bind(with: self) { owner, imageURL in
                owner.profileImageView.kf.setImage(with: imageURL)
            }
            .disposed(by: disposeBag)

        
        reactor.pulse(\.$isLoading)
            .bind(to: loadingIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$accountProfileEntity)
            .compactMap { $0?.profile }
            .map { UIColor(hex: $0.backgroundColor) }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: profileContainerView.rx.backgroundColor)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$accountProfileEntity)
            .compactMap {$0 }
            .map { "\($0.schoolName) \($0.grade)학년 \($0.classNumber)반"}
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: profileClassLabel.rx.text)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$accountProfileEntity)
            .compactMap { $0?.name }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: profileNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        profileEditButton
            .rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, entity in
                let profileSettingViewController = DependencyContainer.shared.injector.resolve(ProfileSettingViewController.self)
                owner.navigationController?.pushViewController(profileSettingViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        
        
        voteAddBanner
            .rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                let profileWebViewController = DependencyContainer.shared.injector.resolve(WSWebViewController.self, argument: WSURLType.addQuestion.urlString)
                owner.navigationController?.pushViewController(profileWebViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        
        
        mainTableView
            .rx.itemSelected
            .bind(with: self) { owner, indexPath in
                switch owner.mainDataSources[indexPath] {
                case .movementItem:
                    if indexPath.item == 0 {
                        let profileWebViewController = DependencyContainer.shared.injector.resolve(WSWebViewController.self, argument: WSURLType.kakaoChaanel.urlString)
                        owner.navigationController?.pushViewController(profileWebViewController, animated: true)
                    } else {
                        let profileWebViewController = DependencyContainer.shared.injector.resolve(WSWebViewController.self, argument: WSURLType.accountOfficial.urlString)
                        owner.navigationController?.pushViewController(profileWebViewController, animated: true)
                    }
                case .appInfoItem:
                    if indexPath.item == 0  {
                        
                    } else if indexPath.item == 1 {
                        let profileWebViewController = DependencyContainer.shared.injector.resolve(WSWebViewController.self, argument: WSURLType.wespotOpinion.urlString)
                        owner.navigationController?.pushViewController(profileWebViewController, animated: true)
                    } else {
                        let profileWebViewController = DependencyContainer.shared.injector.resolve(WSWebViewController.self, argument: WSURLType.wespotResearch.urlString)
                        owner.navigationController?.pushViewController(profileWebViewController, animated: true)
                    }
                case .makerInfoItem:
                    let profileWebViewController = DependencyContainer.shared.injector.resolve(WSWebViewController.self, argument: WSURLType.wespotMakers.urlString)
                    owner.navigationController?.pushViewController(profileWebViewController, animated: true)
                }
            }
            .disposed(by: disposeBag)
        
        mainTableView
            .rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
}


extension AllMainViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        switch self.mainDataSources[section] {
        case .appInfo, .movementInfo:
            guard let lineView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MainTableViewHeaderFooterView") as? MainTableViewHeaderFooterView else { return UITableViewHeaderFooterView() }
            return lineView
        default:
            return nil
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
}
