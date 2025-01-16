//
//  StudentSearchTableViewCell.swift
//  MessageFeature
//
//  Created by 최지철 on 12/26/24.
//

import UIKit
import DesignSystem

import SnapKit

public final class StudentSearchTableViewCell: UITableViewCell {
        
    //MARK: - Properties
    
    private let studentCellView = UIView()
    private let studentImageView = UIImageView()
    private let titleLabel = WSLabel(wsFont: .Body02, text: "학생이름")
    private let subTitleLabel = WSLabel(wsFont: .Body06, text: "인적정보")
    private let checkButton = UIButton().then {
        $0.setImage(DesignSystemAsset.Images.check.image, for: .normal)
    }
    
    //MARK: - Initializer
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
        setupAutoLayout()
        setupAttributes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Functions
    
    private func setupUI() {
        
        studentCellView.addSubviews(studentImageView, titleLabel, subTitleLabel, checkButton)
        contentView.addSubview(studentCellView)
    }
    
    private func setupAutoLayout() {
        
        studentCellView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        studentImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(studentCellView).offset(24)
            $0.size.equalTo(56)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(studentImageView.snp.top)
            $0.left.equalTo(studentImageView.snp.right).offset(16)
            $0.right.equalTo(checkButton.snp.left)
        }
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.left.equalTo(studentImageView.snp.right).offset(16)
            $0.right.equalTo(studentCellView).offset(-44)
        }
        checkButton.snp.makeConstraints {
            $0.top.equalTo(studentCellView).offset(14)
            $0.right.equalTo(studentCellView).offset(-14)
            $0.size.equalTo(20)
        }
    }
    
    private func setupAttributes() {
        
        backgroundColor = .clear
        selectionStyle = .none
        contentView.do {
            $0.layer.cornerRadius = 12
            $0.layer.masksToBounds = true
        }
        
        studentImageView.do {
            $0.layer.cornerRadius = 56 / 2
            $0.clipsToBounds = true
            $0.image = DesignSystemAsset.Images.boyPinkBackground.image
        }
        
        studentCellView.do {
            $0.backgroundColor = DesignSystemAsset.Colors.gray700.color
        }
        
        titleLabel.textColor = DesignSystemAsset.Colors.gray100.color
        
        subTitleLabel.textColor = DesignSystemAsset.Colors.gray300.color
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 16))
    }
    
    public func configureCell(name: String, info: String) {
        
        titleLabel.text = name
        subTitleLabel.text = info
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            contentView.layer.borderColor = DesignSystemAsset.Colors.primary400.color.cgColor
            contentView.layer.borderWidth = 1
            checkButton.setImage(DesignSystemAsset.Images.checkSelected.image, for: .normal)
        } else {
            contentView.layer.borderWidth = 0
            checkButton.setImage(DesignSystemAsset.Images.check.image, for: .normal)
        }
    }
    
}
