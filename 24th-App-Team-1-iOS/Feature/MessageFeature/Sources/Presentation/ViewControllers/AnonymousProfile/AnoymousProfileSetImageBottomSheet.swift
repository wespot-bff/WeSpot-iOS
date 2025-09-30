//
//  AnoymousProfileSetImageBottomSheet.swift
//  MessageFeature
//
//  Created by 최지철 on 6/17/25.
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

public final class AnoymousProfileSetImageBottomSheet: BaseViewController<AnonymousProfileReactor> {
    
    //MARK: - Properties
    
    private let buttonTableView = UITableView().then {
        $0.register(MessageBottomSheetTabelViewCell.self,
                    forCellReuseIdentifier: String.MessageTexts.Identifier.MessageBottomSheetTabelViewCell)
        $0.isScrollEnabled = false
    }
    
    //MARK: - LifeCycle
    
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
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).inset(8)
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
        bindAction(reactor: reactor)
        
        reactor.state.map {$0.setProfileImageBottomSheet}
            .bind(to: buttonTableView.rx.items(cellIdentifier: String.MessageTexts.Identifier.MessageBottomSheetTabelViewCell,
                                               cellType: MessageBottomSheetTabelViewCell.self)) { index, item, cell in
                cell.configureCell(text: item.title)
            }
        .disposed(by: disposeBag)
    }
    
    private func bindAction(reactor: Reactor) {
        buttonTableView.rx
            .modelSelected(SetAnonymousProfileImageEnum.self)
            .bind(with: self){ this, item in
                switch item {
                case .setGalleryImage:
                    this.presentImagePicker()
                case .setBasicProfileImage:
                    let basicImage = DesignSystemAsset.Images.icBasicProfile.image
                    reactor.action.onNext(.setProfileImage(basicImage))
                    this.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: disposeBag)
    }
    private func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.present(imagePicker, animated: true, completion: nil)
    }
}

extension MessageStorageBottomSheetViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
extension AnoymousProfileSetImageBottomSheet: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    // 사용자가 이미지를 선택했을 때 호출되는 메서드입니다.
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 선택된 이미지를 가져옵니다.
        if let pickedImage = info[.originalImage] as? UIImage {
            // Reactor로 선택된 이미지를 보내는 액션을 전달합니다.
            reactor?.action.onNext(.setProfileImage(pickedImage))
        }
        
        // 이미지 피커를 닫고, 현재 바텀시트도 닫습니다.
        picker.dismiss(animated: true) {
            self.dismiss(animated: true)
        }
    }

    // 사용자가 이미지 선택을 취소했을 때 호출되는 메서드입니다.
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // 이미지 피커만 닫습니다.
        picker.dismiss(animated: true, completion: nil)
    }
}
