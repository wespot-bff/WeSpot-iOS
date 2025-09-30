//
//  AnonymousProfileBottomSheetsViewController.swift
//  MessageFeature
//
//  Created by 최지철 on 4/13/25.
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

final class AnonymousProfileBottomSheetsViewController: BaseViewController<AnonymousProfileReactor> {
    public var onProfileCreated: ((_ name: String, _ imageUrl: String, _ isAnonymous: Bool, _ profile: UIImage) -> Void)?
    private let titleLabel = WSLabel(wsFont: .Body01, text: String.MessageTexts.anonymousProfileTitle)
    private let desLabel = WSLabel(wsFont: .Body06, text: String.MessageTexts.anonymousProfileDes).then {
        $0.textColor = DesignSystemAsset.Colors.gray300.color
    }
    private let profileTableView = UITableView(frame: .zero).then {
        $0.backgroundColor = .clear
        $0.register(AnonymousProfileCell.self,
                    forCellReuseIdentifier: String.MessageTexts.Identifier.AnonymousProfileCell)
        $0.separatorStyle = .none
    }
    private var tableViewHeight: CGFloat = 0
    private let makeProfileButton = WSMakeAnonymousProfileButton(title: String.MessageTexts.anonymousProfileMakeButton)
    private var status: AnonymousProfileStatusEnum?
    private lazy var dataSource = RxTableViewSectionedReloadDataSource<Section>(
      configureCell: { ds, tv, ip, item in
        let cell = tv.dequeueReusableCell(
          withIdentifier: String.MessageTexts.Identifier.AnonymousProfileCell,
          for: ip
        ) as! AnonymousProfileCell
        cell.configureCell(item)
        return cell
      }
    )
    private lazy var id: Int = 0

    //MARK: - LifeCycle

    convenience init(status: AnonymousProfileStatusEnum, id: Int, reactor: AnonymousProfileReactor) {
        self.init()
        self.reactor = reactor
        self.status = status
        self.id = id
        if status == .full {
            self.makeProfileButton.isHidden = true
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = DesignSystemAsset.Colors.gray600.color
        self.navigationBar.isHidden = true
        self.profileTableView.rx.setDelegate(self).disposed(by: disposeBag)
        self.reactor?.action.onNext(.fetchProfileList(id: self.id))
    }
    
    //MARK: - Functions
    
    public override func setupUI() {
        super.setupUI()
        self.view.addSubviews(titleLabel,
                              desLabel,
                              profileTableView,
                              makeProfileButton)
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.leading.equalToSuperview().offset(28)
        }
        desLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(28)
        }
        profileTableView.snp.makeConstraints {
            $0.top.equalTo(desLabel.snp.bottom).offset(28)
            $0.horizontalEdges.equalToSuperview().inset(28)
            $0.height.equalTo(status?.profileTableViewHeight ?? 0)
        }
        makeProfileButton.snp.makeConstraints {
            $0.top.equalTo(profileTableView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(28)
            $0.height.equalTo(34)
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
        
        reactor.pulse(\.$profileList)
          .observe(on: MainScheduler.instance)
          .map { list -> [Section] in
            // 아이템 하나당 하나의 섹션
            return list.map { item in
              Section(model: (), items: [item])
            }
          }
          .bind(to: profileTableView.rx.items(dataSource: dataSource))
          .disposed(by: disposeBag)
    }
    
    private func bindAction(reactor: Reactor) {
        makeProfileButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(with: self) { this, _ in
                guard let callback = this.onProfileCreated else { return }
                reactor.action.onNext(.presentMakeProfilePopup(vc: this, onProfileCreated: callback))
            }
            .disposed(by: disposeBag)
        
        profileTableView.rx
            .modelSelected(AnonymousProfileEntity.self)
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .bind(with: self) { this, item in
                let image = DesignSystemAsset.Images.icDefaultProfile.image
                this.onProfileCreated?(item.name,
                                       item.image,
                                       item.isAnonymous,
                                       image)
                print("---------\(item)")
                this.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)
    }
}
extension AnonymousProfileBottomSheetsViewController: UITableViewDelegate {
  func tableView(_ tv: UITableView, heightForRowAt ip: IndexPath) -> CGFloat {
    return 34
  }
  func tableView(_ tv: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return section == (tv.numberOfSections - 1) ? 0 : 24
  }
  func tableView(_ tv: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let v = UIView()
    v.backgroundColor = .clear
    return v
  }
}
