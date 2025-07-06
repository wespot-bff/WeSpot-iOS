//
//  MesssageReportViewController.swift
//  MessageFeature
//
//  Created by 최지철 on 1/21/25.
//

import UIKit
import Util
import DesignSystem
import MessageDomain

import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources  // RxDataSources 임포트

typealias ReportSectionModel = SectionModel<String, ReportResonTypeModel>

public final class MesssageReportViewController: BaseViewController<MessageStorageReactor>, UIScrollViewDelegate {
    
    // MARK: - UI
    
    var onDismiss: (() -> Void)?
    private var message: MessageContentModel?
    private let reportTitleLable = WSLabel(wsFont: .Header01)
    private let calImageView = UIImageView()
    private let calTitleLabel = WSLabel(wsFont: .Body03)
    private let descriptionCalLabel = WSLabel(wsFont: .Body06)
    private let descriptionReportLabel = WSLabel(wsFont: .Body08)
    private var selectedIndexPaths = Set<IndexPath>()
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let reportItems: [ReportResonTypeModel] = [
        .dataLeak,
        .identityTheft,
        .fraudAttempt,
        .ad,
        .input
    ]
    private let reportResonCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ in
            if sectionIndex == 0 {
                // 고정 높이 셀 (60pt)
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(60)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: itemSize,
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 12
                section.contentInsets = .init(top: 0, leading: 0, bottom: 20, trailing: 0)
                return section
            } else {
                // 동적 높이 셀 (최소 60pt)
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(60)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: itemSize,
                    subitems: [item]
                )
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 10
                section.contentInsets = .init(top: 0, leading: 0, bottom: 20, trailing: 0)
                return section
            }
        }
    ).then {
        $0.register(
            MessageReportCollectionViewCell.self,
            forCellWithReuseIdentifier: String.MessageTexts.Identifier.MessageReportCollectionViewCell
        )
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
    }

    
    private let confirmButton = WSButton(wsButtonType: .default(12))
        
    private lazy var dataSource = RxCollectionViewSectionedReloadDataSource<ReportSectionModel>(
        configureCell: { [weak self] (ds, collectionView, indexPath, item) in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: String.MessageTexts.Identifier.MessageReportCollectionViewCell,
                for: indexPath
            ) as? MessageReportCollectionViewCell else {
                return UICollectionViewCell()
            }
            
            // 해당 셀이 직접 입력 셀인지 여부 판단
            let isInput = indexPath.section == 1
            
            cell.configureCell(
                item: item,
                isInput: isInput,
                isSelected: self?.selectedIndexPaths.contains(indexPath) ?? false
            )
            
            // 직접 입력 셀인 경우 텍스트뷰의 높이 변경 시 레이아웃 업데이트
            if isInput {
                cell.onHeightChanged = { [weak self] in
                    guard let self = self else { return }
                    self.reportResonCollectionView.performBatchUpdates(nil, completion: nil)
                }
            } else {
                cell.onHeightChanged = nil
            }
            
            return cell
        }
    )
    
    // MARK: - Initializer
    
    public convenience init(message: MessageContentModel) {
        self.init()
        self.message = message
    }
    
    // MARK: - LifeCycle
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.isBeingDismissed || self.isMovingFromParent {
            onDismiss?()
        }
    }
    
    public override func bind(reactor: MessageStorageReactor) {
        super.bind(reactor: reactor)
        
        Observable.just([
            ReportSectionModel(model: "신고사유", items: Array(reportItems.dropLast())),
            ReportSectionModel(model: "직접입력", items: [reportItems.last!]) // 별도 섹션 추가
        ])
        .bind(to: reportResonCollectionView.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        // Delegate 설정
        reportResonCollectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        // 셀 선택 이벤트 처리
        reportResonCollectionView.rx.itemSelected
            .bind(with: self) { this, indexPath in
                // 0번 섹션만 선택 가능
                if indexPath.section == 0 {
                    if this.selectedIndexPaths.contains(indexPath) {
                        this.selectedIndexPaths.remove(indexPath)
                    } else {
                        this.selectedIndexPaths.insert(indexPath)
                    }
                    this.reportResonCollectionView.reloadItems(at: [indexPath])
                    
                    // 선택된 상태에 따라 버튼 활성화/비활성화
                    this.confirmButton.isEnabled = !self.selectedIndexPaths.isEmpty
                }
            }
            .disposed(by: disposeBag)
        
        confirmButton.rx.tap
            .bind(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                let selectedContent = self.selectedIndexPaths.compactMap { idx -> String? in
                    if idx.section == 0, idx.item < self.reportItems.count - 1 {
                        return self.reportItems[idx.item].title
                    }
                    return nil
                }
                
                guard let selectedContent = selectedContent.first else {
                    return
                }
               // reactor.action.onNext(.reportMessage((self.message)!, selectedContent))
                
                self.view.window?.rootViewController?.dismiss(animated: false, completion: nil)
            })
            .disposed(by: disposeBag)
        
        self.navigationBar.leftBarButton.rx.tap
            .bind { [weak self] in
                self?.dismiss(animated: false)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Setup UI
    
    public override func setupUI() {
        super.setupUI()
        
        // 네비게이션 바 설정
        navigationBar.do {
            $0.setNavigationBarUI(property: .leftWithCenterItem(DesignSystemAsset.Images.arrow.image, "신고"))
            $0.setNavigationBarAutoLayout(property: .leftWithCenterItem)
        }
        
        // 서브뷰 추가
        self.view.addSubviews(scrollView, confirmButton)
        scrollView.addSubview(contentView)
        contentView.addSubviews(
            reportTitleLable,
            calImageView,
            calTitleLabel,
            descriptionCalLabel,
            descriptionReportLabel,
            reportResonCollectionView
        )
        
        // 속성 설정
        reportTitleLable.do {
            $0.text = "해당 쪽지를 신고하시는 이유가 궁금해요"
            $0.sizeToFit()
        }
        calImageView.do {
            $0.image = DesignSystemAsset.Images.exclamationmarkFillDestructive.image
        }
        calTitleLabel.do {
            $0.text = "유의사항"
            $0.sizeToFit()
        }
        descriptionCalLabel.do {
            $0.text = "허위 신고로 확인될 시 서비스 이용이 제한돼요"
            $0.sizeToFit()
        }
        descriptionReportLabel.do {
            $0.text = "* 쪽지는 신고 즉시 차단됩니다."
            $0.sizeToFit()
        }
        confirmButton.do {
            $0.setupButton(text: "선택완료")
            $0.isEnabled = false
        }
        
        // 1. Tap Gesture Recognizer 추가
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutside))
        tapGesture.cancelsTouchesInView = false // 다른 터치 이벤트와 충돌 방지
        scrollView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Setup Layout
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        
        // 1. ScrollView 기본 위치 설정
        scrollView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-12)
        }
        
        // 2. 컨텐츠뷰 제약조건 (핵심)
        contentView.snp.makeConstraints {
            $0.edges.equalTo(scrollView.contentLayoutGuide)
            $0.width.equalTo(scrollView.frameLayoutGuide) // 가로 스크롤 방지
        }
        
        // 3. 버튼 위치 설정 (변경 없음)
        confirmButton.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(52)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-12) // 키보드 바로 위
        }
        
        // 4. 모든 서브뷰를 contentView에 배치
        reportTitleLable.snp.makeConstraints {
            $0.top.equalTo(contentView).offset(20)
            $0.leading.trailing.equalTo(contentView).inset(30)
        }
        
        calImageView.snp.makeConstraints {
            $0.top.equalTo(reportTitleLable.snp.bottom).offset(32)
            $0.leading.equalTo(contentView).offset(30)
            $0.size.equalTo(24)
        }
        
        calTitleLabel.snp.makeConstraints {
            $0.centerY.equalTo(calImageView.snp.centerY)
            $0.leading.equalTo(calImageView.snp.trailing).offset(6)
            $0.trailing.equalTo(contentView).inset(30)
        }
        
        descriptionCalLabel.snp.makeConstraints {
            $0.top.equalTo(calTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(contentView).inset(30)
        }
        
        descriptionReportLabel.snp.makeConstraints {
            $0.top.equalTo(descriptionCalLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalTo(contentView).inset(30)
        }
        
        // 5. 컬렉션뷰 제약조건 (변경)
        reportResonCollectionView.snp.makeConstraints {
            $0.top.equalTo(descriptionReportLabel.snp.bottom).offset(24)
            $0.horizontalEdges.equalTo(contentView).inset(20)
            $0.height.greaterThanOrEqualTo(500)
            $0.bottom.equalTo(contentView).offset(-20) 
        }
    }
    
    // MARK: - Tap Gesture Action
    @objc private func handleTapOutside() {
        view.endEditing(true) // 키보드 내리기
    }
    
    // MARK: - CompositionalLayout
    
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: sectionIndex == 0 ? .absolute(60) : .estimated(60)
            )
            
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: itemSize,
                subitems: [item]
            )
            
            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = 12
            return section
        }
        return layout
    }
}

