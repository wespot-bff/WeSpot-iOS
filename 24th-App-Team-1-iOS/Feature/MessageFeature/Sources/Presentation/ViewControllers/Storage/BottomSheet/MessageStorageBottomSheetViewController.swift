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
    
    private var message: MessageContentModel?
    private let buttonTableView = UITableView().then {
        $0.register(MessageBottomSheetTabelViewCell.self,
                    forCellReuseIdentifier: String.MessageTexts.Identifier.MessageBottomSheetTabelViewCell)
        $0.isScrollEnabled = false
    }
    
    //MARK: - LifeCycle
    
    public override init() {
        super.init()
    }
    
    public convenience init(message: MessageContentModel) {
        self.init()
        self.message = message
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
    
    public  override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        buttonTableView.rx.setDelegate(self).disposed(by: disposeBag)
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        let items: [MessageBottomSheetButtonList] = [
             .block,
             .delete,
             .report
         ]
         
         Observable.just(items)
             .bind(to: buttonTableView.rx.items(
                cellIdentifier: String.MessageTexts.Identifier.MessageBottomSheetTabelViewCell,
                 cellType: MessageBottomSheetTabelViewCell.self
             )) { row, element, cell in
                 cell.configureCell(text: element.titleText)
             }
             .disposed(by: disposeBag)
    }
    
    private func bindAction(reactor: Reactor) {
        buttonTableView.rx
            .modelSelected(MessageBottomSheetButtonList.self)
            .bind(with: self){ this, item in
                guard let message = this.message else {
                    return
                }
                this.showAlert(reacotr: reactor,
                               message: message,
                               type: item)
                
            }
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: Reactor) {
        reactor.pulse(\.$disMissBottomSheet)
            .bind(with: self, onNext: {  this, state in
                if state {
                    this.dismiss(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension MessageStorageBottomSheetViewController {
    private func showAlert(reacotr: MessageStorageReactor,
                           message: MessageContentModel,
                           type: MessageBottomSheetButtonList) {
        var title: String = ""
        var description: String = ""
        var buttonText: String = ""
        let cloeseButtonText: String = "닫기"
        switch type {
        case .block:
            title = String.MessageTexts.blockMessageAlertTitle
            description = String.MessageTexts.blockMessageAlertDes
            buttonText = String.MessageTexts.blockMessageBtnTitle
        case .delete:
            title = String.MessageTexts.deleteMessageAlertTitle
            description = String.MessageTexts.deleteMessageAlertDes
            buttonText = String.MessageTexts.deleteMessageBtnTitle
        case .report:
            title = String.MessageTexts.reportMessageAlertTitle
            description = String.MessageTexts.reportMessageAlertDes
            buttonText = String.MessageTexts.reportMessageBtnTitle
        }
        
        WSAlertBuilder(showViewController: self)
            .setAlertType(type: .titleWithMeesage)
            .setTitle(title: title,
                      titleAlignment: .left)
            .setMessage(message: description)
            .setConfirm(text: buttonText)
            .setCancel(text: cloeseButtonText)
            .action(.confirm) {
                reacotr.action.onNext(.buttonTapped(message, type))
                if type == .report {
                     let reactor = DependencyContainer.shared.injector.resolve(MessageStorageReactor.self)
                    let reportVC = DependencyContainer.shared.injector.resolve(
                            MesssageReportViewController.self,
                            arguments: message, reactor
                          )
                    
                    // 3. 화면 전환
                    reportVC.modalPresentationStyle = .fullScreen
                    self.present(reportVC, animated: false)
                }
            }
            .show()
    }
}

extension MessageStorageBottomSheetViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let totalRows = tableView.numberOfRows(inSection: indexPath.section)
        if indexPath.row == totalRows - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
        } else {
            cell.separatorInset = .zero
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}
