//
//  SignInViewController.swift
//  LoginFeature
//
//  Created by eunseou on 7/13/24.
//

import UIKit
import Util
import Storage
import DesignSystem
import LoginDomain

import Then
import Lottie
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit
import AuthenticationServices

public final class SignInViewController: BaseViewController<SignInViewReactor> {
    
    //MARK: - Properties
    private let onboardingCarouselView = UIScrollView() // scroll
    private let horizentalStackView = UIStackView() // stackView
    private let pageControl = UIPageControl()
    private let appleLoginButton = ASAuthorizationAppleIDButton()
    private let kakaoLoginButton = UIButton()
    private let firstContainerView = UIView()
    private let firstBackgroundView = UIImageView()
    private let firstLottieView = WSLottieView()
    private let secondLottieView = WSLottieView()
    private let thirdLottieView = WSLottieView()
    private let loadingIndicatorView = WSLottieIndicatorView()
    
    private let lottieLabel = WSLabel(wsFont: .Body02, textAlignment: .center)
    private let onbardingLottieView = WSLottieView()
    
    //MARK: - LifeCycle
    public override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK: - Configure
    public override func setupUI() {
        super.setupUI()
        
        view.addSubviews(onboardingCarouselView, lottieLabel, pageControl, appleLoginButton, kakaoLoginButton, onbardingLottieView)
        onboardingCarouselView.addSubview(horizentalStackView)
        horizentalStackView.addArrangedSubview(firstContainerView)
        firstContainerView.addSubviews(firstBackgroundView, firstLottieView)
        horizentalStackView.addArrangedSubview(secondLottieView)
        horizentalStackView.addArrangedSubview(thirdLottieView)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupCarousel()
    }
    
    public override func setupAutoLayout() {
        super.setupAutoLayout()
        
        onboardingCarouselView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(90)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(onboardingCarouselView.snp.height)
        }
        
        horizentalStackView.snp.makeConstraints {
            $0.height.equalToSuperview()
            $0.edges.equalToSuperview()
        }
        
        firstContainerView.snp.makeConstraints {
            $0.width.equalTo(firstLottieView.snp.height)
            $0.width.equalTo(view)
        }
        
        secondLottieView.snp.makeConstraints {
            $0.width.equalTo(secondLottieView.snp.height)
            $0.width.equalTo(view)
        }
        
        thirdLottieView.snp.makeConstraints {
            $0.width.equalTo(thirdLottieView.snp.height)
            $0.width.equalTo(view)
        }
        
        firstLottieView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        firstBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        lottieLabel.snp.makeConstraints {
            $0.top.equalTo(onboardingCarouselView.snp.bottom).offset(6)
            $0.centerX.equalTo(onboardingCarouselView.snp.centerX)
        }
        
        pageControl.snp.makeConstraints {
            $0.top.equalTo(lottieLabel.snp.bottom).offset(18)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        appleLoginButton.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(pageControl.snp.bottom).offset(64)
            $0.height.equalTo(44)
            $0.width.equalTo(323)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        
        kakaoLoginButton.snp.makeConstraints {
            $0.top.equalTo(appleLoginButton.snp.bottom).offset(16)
            $0.height.equalTo(44)
            $0.width.equalTo(323)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(32)
        }
        
        onbardingLottieView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(180)
            $0.centerX.equalTo(view.safeAreaLayoutGuide)
            $0.size.equalTo(250)
        }
    }
    
    public override func setupAttributes() {
        super.setupAttributes()
        
        view.backgroundColor = DesignSystemAsset.Colors.gray900.color
        
        horizentalStackView.do {
            $0.spacing = 0
            $0.axis = .horizontal
        }
        
        onboardingCarouselView.do {
            $0.isPagingEnabled = true
            $0.showsHorizontalScrollIndicator = false
            $0.isScrollEnabled = true
            $0.bounces = false
        }
        
        lottieLabel.do {
            $0.text = "위스팟 행성에 오신 것을 환영해요!\n기다리고 있었어요"
            $0.textColor = DesignSystemAsset.Colors.gray100.color
        }
        
        pageControl.do {
            $0.numberOfPages = 3
            $0.currentPage = 0
        }
        
        kakaoLoginButton.do {
            $0.setImage(DesignSystemAsset.Images.kakaoLoginButton.image, for: .normal)
        }
        
        onbardingLottieView.do {
            $0.isHidden = true
            $0.isStatus = false
        }
        
        firstLottieView.do {
            $0.lottieView.loopMode = .loop
            $0.lottieView.animation = DesignSystemAnimationAsset.onboarding01.animation
            $0.isStatus = true
        }
        
        firstBackgroundView.do {
            $0.image = DesignSystemAsset.Images.bgOnboardingPlanet.image
            $0.contentMode = .scaleAspectFit
        }
        
        secondLottieView.do {
            $0.lottieView.loopMode = .loop
            $0.lottieView.animation = DesignSystemAnimationAsset.onboarding.animation
            $0.isStatus = true
        }
        
        thirdLottieView.do {
            $0.lottieView.loopMode = .loop
            $0.lottieView.animation = DesignSystemAnimationAsset.onboarding03.animation
            $0.isStatus = true
        }
    }
    
    public override func bind(reactor: Reactor) {
        super.bind(reactor: reactor)
        
        appleLoginButton.rx.loginOnTap()
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { authorization in Reactor.Action.signInWithApple(authorization)}
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        kakaoLoginButton.rx.tap
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .map { SignInViewReactor.Action.signInWithKakao }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        pageControl.rx.controlEvent(.valueChanged)
            .map { _ in self.pageControl.currentPage }
            .bind(with: self) { owner, currentPage in
                let offsetX = CGFloat(currentPage) * owner.onboardingCarouselView.frame.width
                owner.onboardingCarouselView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
            }
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .bind(to: loadingIndicatorView.rx.isHidden)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$signUpToken)
            .compactMap { $0?.signUpToken }
            .map { SignUpUserRequest(signUpToken: $0) }
            .bind(with: self) { owner, registerRequest in
                let signUpSchoolViewController = DependencyContainer.shared.injector.resolve(
                    SignUpSchoolViewController.self,
                    arguments: registerRequest, ""
                )
                owner.navigationController?.setViewControllers([signUpSchoolViewController], animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupCarousel() {
        onboardingCarouselView.delegate = self
    }
}

extension SignInViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x/scrollView.frame.size.width
        let index = Int(value)
        pageControl.currentPage = index
        
        if index < 1 {
            firstBackgroundView.isHidden = false
            DispatchQueue.global().async {
                OperationQueue.main.addOperation {
                    self.lottieLabel.text = "위스팟 행성에 오신 것을 환영해요!\n 기다리고 있었어요"
                }
            }
            firstLottieView.toggleAnimation(isStatus: true)
        } else if index < 2 {
            firstBackgroundView.isHidden = true
            DispatchQueue.global().async {
                OperationQueue.main.addOperation {
                    self.lottieLabel.text = "우리 반 비밀 투표에 참여하고\n서로에 대해 알아가고 볼까요?"
                }
            }
            
            secondLottieView.toggleAnimation(isStatus: true)
        } else {
            DispatchQueue.global().async {
                OperationQueue.main.addOperation {
                    self.lottieLabel.text = "매일 저녁, 딱 세 통만 보낼 수 있는\n비밀 쪽지로 마음을 표현해 보세요!"
                }
            }
            thirdLottieView.toggleAnimation(isStatus: true)
        }
    }
}
