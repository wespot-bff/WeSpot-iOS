//
//  SearchStudentForMessageWriteViewController.swift
//  MessageFeature
//
//  Created by 최지철 on 12/22/24.
//

import UIKit
import Util
import DesignSystem
import MessageDomain
import Storage

import ReactorKit
import Then
import SnapKit
import RxCocoa
import RxDataSources

public final class SearchStudentForMessageWriteViewController: BaseViewController<MessageWriteReactor> {
    
    //MARK: - Properties
    
    private lazy var titleLabel = WSLabel(wsFont: .Header01).then {
        $0.textColor = DesignSystemAsset.Colors.gray100.color
        $0.text = "오늘 \(UserDefaultsManager.shared.userName ?? "")님을 설레게 했던\n친구는 누구인가요?"
    }
    private let gradientView = WSGradientView()
    private let studentSearchTextField = WSTextField(state: .withLeftItem(DesignSystemAsset.Images.magnifyingglass.image),
                                                     placeholder: "이름으로 검색해 보세요")
    private let noResultButton = UIButton().then {
        let title = String.MessageTexts.searchNoResultButtonText
        let attributedTitle = NSAttributedString(
            string: title,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: DesignSystemAsset.Colors.gray300.color,
                .font: WSFont.Body05.font()
            ]
        )
        $0.setAttributedTitle(attributedTitle, for: .normal)
        $0.setTitleColor(DesignSystemAsset.Colors.gray300.color, for: .normal)
        $0.titleLabel?.font = WSFont.Body05.font()
    }
    private let searchResultTableView = UITableView(frame: .zero).then {
        $0.register(StudentSearchTableViewCell.self,
                    forCellReuseIdentifier: String.MessageTexts.Identifier.studentSearchTableViewCell)
        $0.backgroundColor = .clear
        $0.separatorStyle = .none
        $0.rowHeight = 104
        $0.prefetchDataSource = nil
    }
    private let nextButton = WSButton(wsButtonType: .default(12))
    private let loadingIndicatorView: WSLottieIndicatorView = WSLottieIndicatorView()
    private let noresultFriendButton = UIButton()

    
    //MARK: - LifeCycle
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .hideTabBar, object: nil)
    }
    
    //MARK: - Configure

    public override func setupUI() {
        super.setupUI()
        [titleLabel,
         studentSearchTextField,
         searchResultTableView,
         gradientView,
         noresultFriendButton].forEach {
            self.view.addSubview($0)
        }
        
        gradientView.addSubview(nextButton)
        gradientView.passThroughButton = nextButton
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.navigationBar.safeAreaLayoutGuide.snp.bottom)
            $0.leading.equalToSuperview().offset(20)
        }
        studentSearchTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(60)
        }
        searchResultTableView.snp.makeConstraints {
            $0.top.equalTo(studentSearchTextField.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(nextButton.snp.top).offset(12)
        }
        
        gradientView.snp.makeConstraints {
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top)
            $0.height.equalTo(150)
        }
        
        nextButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-12)
            $0.height.equalTo(52)
        }
        
        noresultFriendButton.snp.makeConstraints {
            $0.top.equalTo(studentSearchTextField.snp.bottom).offset(24)
            $0.width.equalTo(111)
            $0.height.equalTo(23)
            $0.centerX.equalToSuperview()
        }
    }
    public override func setupAttributes() {
        super.setupAttributes()
        navigationBar.do {
            $0.setNavigationBarUI(property: .rightItem("닫기"))
            $0.setNavigationBarAutoLayout(property: .leftWithRightItem)
        }
        nextButton.do {
            $0.setupButton(text: "다음")
            $0.isEnabled = false
        }
        noresultFriendButton.do {
            $0.isHidden = false
            let title = "찾는 친구가 없다면?"
            let attributes: [NSAttributedString.Key: Any] = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: DesignSystemAsset.Colors.gray300.color,
                .foregroundColor: DesignSystemAsset.Colors.gray300.color,
                .font: WSFont.Body05.font(),
                .baselineOffset: 4
            ]
            let attributedTitle = NSAttributedString(string: title, attributes: attributes)
            $0.setAttributedTitle(attributedTitle, for: .normal)
            $0.isHidden = true
        }
    }
        
    public override func bind(reactor: MessageWriteReactor) {
        super.bind(reactor: reactor)
        bindAction(reactor: reactor)
        bindState(reactor: reactor)
        bindUI()
    }
}

    //MARK: - Bind

extension SearchStudentForMessageWriteViewController {
    private func bindAction(reactor: MessageWriteReactor) {
        studentSearchTextField.rx.controlEvent([.editingDidBegin,
                                                .editingDidEnd])
            .map { self.studentSearchTextField.isEditing }
            .bind(to: studentSearchTextField.borderUpdateBinder)
            .disposed(by: disposeBag)
        
        studentSearchTextField.rx.text.orEmpty
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .bind(with: self) {  this, text in
                this.noresultFriendButton.isHidden = false
                reactor.action.onNext(.searchStudent(text))
            }
            .disposed(by: disposeBag)
        
        searchResultTableView.rx.modelSelected(StudentListResponseEntity.UserEntity.self)
            .map { MessageWriteReactor.Action.selectUser($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        searchResultTableView.rx
            .reachedBottom
            .filter { reactor.currentState.isLoading }
            .bind(with: self) {  this, _ in
                reactor.action.onNext(.loadMoreUsers)
            }
            .disposed(by:  disposeBag)
        
        navigationBar.rightBarButton.rx
            .tap
            .bind(with: self) {  this, _ in
                WSAlertBuilder(showViewController: this)
                    .setAlertType(type: .titleWithMeesage)
                    .setTitle(title: "쪽지 작성을 중단하시나요?",
                              titleAlignment: .left)
                    .setMessage(message: "작성 중인 내용은 저장되지 않아요")
                    .setConfirm(text: "네 그만할래요")
                    .setCancel(text: "닫기")
                    .action(.confirm) { [weak self] in
                        self?.navigationController?.popToRootViewController(animated: true)
        
                    }
                    .show()
            }
            .disposed(by: disposeBag)
        
        nextButton.rx
            .tap
            .filter { reactor.currentState.selectedUser != nil}
            .bind(with: self) {  this, _ in
                reactor.action.onNext(.presentAnonymousBottomSheet(reactor.currentState.selectedUser?.id ?? 0, self))
            }
            .disposed(by: disposeBag)
        
        noresultFriendButton.rx.tap
            .bind(with: self) {  owner, _ in
                owner.shareToKakaoTalk()
            }
            .disposed(by: disposeBag)
    }
    
    private func bindState(reactor: MessageWriteReactor) {
        
        reactor.pulse(\.$completSetSenderProfile)
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self) { owner, completed in
                if completed {
                    print("completSetSenderProfile is true. Transitioning to MessageWriteViewController.")
                    let messageWriteVC = MessageWriteViewController(reactor: reactor)
                    owner.navigationController?.pushViewController(messageWriteVC, animated: true)
                }
            }
            .disposed(by: disposeBag)

        
        reactor.pulse(\.$serachResult)
            .observe(on: MainScheduler.asyncInstance)
            .compactMap { $0?.users }
            .bind(to: searchResultTableView.rx.items(
                cellIdentifier: String.MessageTexts.Identifier.studentSearchTableViewCell,
                cellType: StudentSearchTableViewCell.self
            )) { index, student, cell in
                cell.configureCell(name: student.name,
                                   info: student.totalInfo,
                                   image: student.profile.iconUrl)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$serachResult)
            .compactMap { $0?.users }
            .bind(with: self) {  owner, students in
                owner.noresultFriendButton.isHidden = students.isEmpty ? false : true
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .delay(.microseconds(200),
                   scheduler: MainScheduler.instance)
            .bind(to: loadingIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.state
            .map { $0.selectedUser != nil }
            .observe(on: MainScheduler.asyncInstance)
            .bind(to: nextButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
    }
    
    private func bindUI() {
        self.rx.viewWillAppear
            .delay(.microseconds(200),
                   scheduler: MainScheduler.instance)
            .bind(with: self) { this, _ in
                this.studentSearchTextField.becomeFirstResponder()
            }
            .disposed(by: disposeBag)
    }
    
}

extension SearchStudentForMessageWriteViewController {

}
