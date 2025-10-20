//
//  TemrsViewController.swift
//  VoteFeature
//
//  Created by 김도현 on 10/13/25.
//

import UIKit
import Util
import DesignSystem
import SnapKit
import Then

import RxSwift
import RxCocoa
import AllFeature





public final class TermsViewController: BaseViewController<TermsViewReactor> {
    private let titleLabel: WSLabel = WSLabel(wsFont: .Header03)
    private let contentView: UITextView = UITextView()
    
    private let scrollView: UIScrollView = UIScrollView()
    private let confirmButton: WSButton = WSButton(wsButtonType: .default(12))
    
    

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAttributedContent()
        setupAutoLayout()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .hideTabBar, object: nil)
    }
    
    public override func setupUI() {
        super.setupUI()
        view.addSubviews(titleLabel, contentView, confirmButton)
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        
        titleLabel.do {
            $0.textColor = DesignSystemAsset.Colors.gray100.color
            $0.text = "서비스 이용 약관 및 정책 업데이트 안내"
        }
        
        contentView.do {
            $0.backgroundColor = .clear
            $0.textAlignment = .left
            $0.textColor = DesignSystemAsset.Colors.gray200.color
        }
        
        confirmButton.do {
            $0.setupButton(text: "동의하기")
            $0.setupFont(font: .Body03)
        }
        
        
        navigationBar.do {
            $0.setNavigationBarUI(
                property: .rightIcon(DesignSystemAsset.Images.icTermsEllipseFiled.image)
            )
            $0.setNavigationBarAutoLayout(property: .rightIcon(30, 30))
        }
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.left.equalToSuperview().offset(20)
            $0.height.equalTo(30)
        }
        
        contentView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(confirmButton.snp.top).offset(40)
        }
        
        confirmButton.snp.makeConstraints {
            $0.height.equalTo(52)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(44)
        }
    }
    
    private func setupAttributedContent() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        
        let fullText = """
    안녕하세요. WeSpot 팀입니다.
    WeSpot 서비스를 이용해 주시는 회원분들께 감사드리며, WeSpot의 서비스 약관 및 개인정보처리 방침이 개정될 예정임을 안내해 드립니다.

    개정된 내용은 2025년 10월 14일에 공시되어 21일부터 효력이 발생하므로 서비스 이용에 참고해 주시기 바랍니다.

    내용의 전문을 살펴볼 수 있는 링크를 함께 공유드립니다.

    서비스 이용약관
    개인정보처리방침
    WeSpot (커뮤니티) 이용규칙

    개정되는 내용이 적용되기 전까지 별도의 거부 의사가 없으면 개정 내용에 동의한 것으로 간주합니다. 또한 탈퇴 이후 15일 내에 재로그인을 통해 탈퇴를 철회하여 서비스를 계속 사용 시에도 개정 내용에 동의한 것으로 간주합니다.

    개정 내용에 대해 궁금한 점이 있으시다면 언제든
    wespot.official.app@gmail.com 을 통해 말씀해 주세요.

    감사합니다.
    WeSpot 팀 드림
    """

        let attributedText = NSMutableAttributedString(string: fullText, attributes: [
            .foregroundColor: DesignSystemAsset.Colors.gray200.color,
            .font: DesignSystemFontFamily.Pretendard.semiBold.font(size: 14),
            .paragraphStyle: paragraphStyle
        ])

        let linkMappings: [(String, String)] = [
            ("서비스 이용약관", "https://gregarious-salesman-74d.notion.site/2814250111d280588025c88cd75886b8"),
            ("개인정보처리방침", "https://gregarious-salesman-74d.notion.site/2814250111d280a1ae1ff838befc7052"),
            ("WeSpot (커뮤니티) 이용규칙", "https://gregarious-salesman-74d.notion.site/WeSpot-2814250111d280528ecde3f5bb2ce7e0"),
            ("wespot.official.app@gmail.com", "mailto:wespot.official.app@gmail.com")
        ]

        for (keyword, link) in linkMappings {
            let range = (fullText as NSString).range(of: keyword)
            if range.location != NSNotFound {
                attributedText.addAttributes([
                    .link: URL(string: link)!,
                    .foregroundColor: UIColor.systemYellow
                ], range: range)
            }
        }

        contentView.attributedText = attributedText
        contentView.linkTextAttributes = [
            .foregroundColor: DesignSystemAsset.Colors.primary300.color
        ]
        contentView.isEditable = false
        contentView.isSelectable = true
        contentView.dataDetectorTypes = [.link]
    }
    
    
    public override func bind(reactor: TermsViewReactor) {
        super.bind(reactor: reactor)
        
        navigationBar.rightBarButton
            .rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .bind(with: self) { owner, _ in
                let sheetViewController = TermsBottomSheetViewController()
                sheetViewController.modalPresentationStyle = .overFullScreen
                sheetViewController.delegate = owner
                owner.present(sheetViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        confirmButton.rx
            .tap.throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { Reactor.Action.didTappedAllowButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    
        reactor.pulse(\.$isSuccess)
            .bind(with: self) { owner, isSuccess in
                if isSuccess == true {
                    owner.navigationController?.popViewController(animated: true)
                }
            }
            .disposed(by: disposeBag)
            
    }

    
}


extension TermsViewController: TermsBottomSheetViewControllerDelegate {
    func termsBottomSheetDidTapResign() {
        let resignSheetViewController = DependencyContainer.shared.injector.resolve(ProfileResignBottomSheetView.self)
        resignSheetViewController.modalPresentationStyle = .overCurrentContext
        resignSheetViewController.modalTransitionStyle = .crossDissolve
        self.present(resignSheetViewController, animated: true)
    }
}
