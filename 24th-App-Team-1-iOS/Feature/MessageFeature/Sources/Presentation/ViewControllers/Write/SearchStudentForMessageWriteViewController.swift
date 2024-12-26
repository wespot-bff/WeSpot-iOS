//
//  SearchStudentForMessageWriteViewController.swift
//  MessageFeature
//
//  Created by 최지철 on 12/22/24.
//

import UIKit
import Util
import DesignSystem

import ReactorKit
import Then
import SnapKit
import RxCocoa

public final class SearchStudentForMessageWriteViewController: BaseViewController<MessageWriteReactor> {
    
    //MARK: - Properties
    
    private lazy var titleLabel = WSLabel(wsFont: .Header01).then {
        $0.textColor = DesignSystemAsset.Colors.gray100.color
        $0.text = "오늘 WeSpot님을 설레게 했던\n친구는 누구인가요?"
    }
    private let studentSearchTextField = WSTextField(state: .withLeftItem(DesignSystemAsset.Images.magnifyingglass.image),
                                                     placeholder: "이름으로 검색해 보세요")
    private let noResultButton = UIButton().then {
        let title = "찾는 학교가 없다면?"
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
        $0.backgroundColor = .red
    }
    private let nextButton = WSButton(wsButtonType: .default(12))
    
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
         nextButton ,
         searchResultTableView].forEach {
            self.view.addSubview($0)
        }
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
            $0.bottom.equalTo(nextButton.snp.top).offset(-12)
        }
        nextButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(52)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-12)
        }
    }
    public override func setupAttributes() {
        super.setupAttributes()
        navigationBar.do {
            $0.setNavigationBarUI(property: .leftWithRightItem(DesignSystemAsset.Images.arrow.image,
                                                               "닫기",
                                                        UIImage()))
            $0.setNavigationBarAutoLayout(property: .leftWithRightItem)
        }
        nextButton.do {
            $0.setupButton(text: "다음")
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
    }
    
    private func bindState(reactor: MessageWriteReactor) {
        
    }
    
    private func bindUI() {
        self.rx.viewWillAppear
            .delay(.microseconds(100),
                   scheduler: MainScheduler.instance)
            .bind(with: self) { this, _ in
                this.studentSearchTextField.becomeFirstResponder()

            }
            .disposed(by: disposeBag)
    }
}

