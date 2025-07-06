//
//  MessageReportCollectionViewCell.swift
//  MessageFeature
//
//  Created by 최지철 on 1/22/25.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import MessageDomain
import DesignSystem

final class MessageReportCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI
  
    private let imageView = UIImageView()
    private let titleLabel = WSLabel(wsFont: .Body04)
    let textView = UITextView().then {
        $0.backgroundColor = .clear
        $0.isScrollEnabled = false
        $0.font = WSFont.Body04.font()
        $0.textColor = DesignSystemAsset.Colors.gray100.color
        $0.isHidden = true // 기본적으로 숨김
    }
    
    // MARK: - Rx
    private var disposeBag = DisposeBag()
    
    // MARK: - Callback
    /// 셀 내부에서 textView가 변할 때 컬렉션 뷰에게 높이 업데이트를 요청할 수 있도록, 외부에서 주입받을 클로저
    var onHeightChanged: (() -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - 재사용 처리
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = DesignSystemAsset.Images.check.image
        titleLabel.text = nil
        textView.text = ""
        textView.isHidden = true
        contentView.layer.borderColor = DesignSystemAsset.Colors.gray700.color.cgColor
        disposeBag = DisposeBag()
    }
    
    // MARK: - 셀 선택
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                contentView.layer.borderColor = DesignSystemAsset.Colors.primary400.color.cgColor
            } else {
                contentView.layer.borderColor = DesignSystemAsset.Colors.gray700.color.cgColor
            }
        }
    }
    
    // MARK: - Configure
    /// 외부에서 주입되는 데이터를 기반으로 UI 세팅
    func configureCell(item: ReportResonTypeModel,
                       isInput: Bool,
                       isSelected: Bool) {
        if isSelected {
            imageView.image = DesignSystemAsset.Images.checkSelected.image
            contentView.layer.borderColor = DesignSystemAsset.Colors.primary400.color.cgColor
        } else {
            imageView.image = DesignSystemAsset.Images.check.image
            contentView.layer.borderColor = DesignSystemAsset.Colors.gray700.color.cgColor
        }
        
        // 제목 설정
        titleLabel.text = item.title
        
        // 직접 입력 셀인 경우 텍스트뷰 표시
        textView.isHidden = !isInput
        if isInput {
            textView.text = "" // 초기 텍스트 설정 (필요 시)
        }
        
        // Rx 바인딩
        if isInput {
            bind()
        }
    }
    
    // MARK: - Binding
    private func bind() {
        /// textView의 didChange 이벤트를 Rx로 구독
        textView.rx.didChange
            .bind(onNext: { [weak self] in
                self?.onHeightChanged?()
                self?.titleLabel.isHidden = !(self?.textView.isFocused ?? true)
                self?.imageView.image = !(self?.textView.text.isEmpty ?? true)
                    ? DesignSystemAsset.Images.checkSelected.image
                    : DesignSystemAsset.Images.check.image
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        contentView.backgroundColor = DesignSystemAsset.Colors.gray700.color
        self.contentView.layer.cornerRadius = 12
    }
    
    // MARK: - Layout
    private func setupLayout() {
        contentView.addSubviews(imageView, titleLabel, textView)
        contentView.layer.borderWidth = 1
        
        // 이미지뷰 제약조건
        imageView.snp.makeConstraints {
            $0.width.height.equalTo(20)
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        
        // 제목 레이블 제약조건
        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(imageView.snp.trailing).offset(8)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview().inset(8)
        }
        
        // 텍스트뷰 제약조건
        textView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.leading.equalTo(imageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(8)
            $0.bottom.equalToSuperview().inset(8)
        }
    }
}
