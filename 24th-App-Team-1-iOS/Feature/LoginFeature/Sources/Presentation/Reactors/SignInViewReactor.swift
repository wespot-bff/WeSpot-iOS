//
//  SignInViewReactor.swift
//  LoginFeature
//
//  Created by eunseou on 7/13/24.
//

import Foundation
import Networking
import LoginDomain
import Storage
import Util

import ReactorKit
import AuthenticationServices
import KakaoSDKUser
import KakaoSDKAuth
import KeychainSwift

public final class SignInViewReactor: Reactor {
    
    private let signInUseCase: SignInUserUseCaseProtocol
    private let globalService: WSGlobalServiceProtocol = WSGlobalStateService.shared
    private var disposeBag = DisposeBag()
    public var initialState: State
    
    public struct State {
        var loginRequest: SignInUserRequest
        @Pulse var signUpToken: SignUpTokenEntity?
        @Pulse var isLoading: Bool
        @Pulse var isShow: Bool
    }
    
    public enum Action {
        case signInWithApple(ASAuthorization)
        case signInWithKakao
    }
    
    public enum Mutation {
        case setSignUpToken(SignUpTokenEntity)
        case setLoginUser(LoginUserEntity)
        case setLoading(Bool)
        case setTransitionFlag(Bool)
    }
    
    public init(signInUseCase: SignInUserUseCaseProtocol) {
        self.signInUseCase = signInUseCase
        self.initialState = State(
            loginRequest: SignInUserRequest(socialType: "",
                                              authorizationCode: "",
                                              identityToken: "",
                                              fcmToken: ""),
            isLoading: false,
            isShow: false
        )
    }
    
    //MARK: - Reactor Method
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .signInWithApple(let authorization):
            //애플로그인 로직
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else { return .empty() }
            
            guard let authorizationCodeData = appleIDCredential.authorizationCode,
                  let authorizationCode = String(data: authorizationCodeData, encoding: .utf8),
                  let identityTokenData = appleIDCredential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8)
            else {
                return .empty()
            }
            UserDefaultsManager.shared.socialType = SocialTypes.kakao.rawValue
            return executeTryLogin(socialType: SocialTypes.apple.rawValue.uppercased(), authorizationCode: authorizationCode, identityToken: identityToken)
        case .signInWithKakao:
            UserDefaultsManager.shared.socialType = SocialTypes.kakao.rawValue
            return handleKakaoLogin()
                .flatMap { self.executeTryLogin(socialType: SocialTypes.kakao.rawValue.uppercased(), authorizationCode: "", identityToken: $0) }
            
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setSignUpToken(let signUpTokenResponse):
            KeychainManager.shared.delete(type: .accessToken)
            KeychainManager.shared.delete(type: .refreshToken)
            newState.signUpToken = signUpTokenResponse
            let expiredDate = Date.now.addingTimeInterval(30 * 60)
                .toFormatLocaleString(with: .dashYyyyMMddhhmmss)
                .toLocalDate(with: .dashYyyyMMddhhmmss)
            UserDefaultsManager.shared.expiredDate = expiredDate
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case let .setTransitionFlag(isShow):
            newState.isShow = isShow
        case .setLoginUser(let userInfo):
            KeychainManager.shared.set(value: userInfo.accessToken,
                                       type: .accessToken)
            KeychainManager.shared.set(value: userInfo.refreshToken,
                                       type: .refreshToken)
            
            NotificationCenter.default.post(name: .dismissProfileOnboardingView, object: nil)
        }
        return newState
    }
}

    //MARK: - Mutation Logic

extension SignInViewReactor {
    private func executeTryLogin(socialType: String,
                               authorizationCode: String,
                               identityToken: String) -> Observable<Mutation> {
        let fcmToken = UserDefaultsManager.shared.fcmToken ?? ""
        let body = SignInUserRequest(socialType: socialType,
                                            authorizationCode: authorizationCode,
                                            identityToken: identityToken,
                                            fcmToken: fcmToken)
        
        
        return signInUseCase
            .execute(body: body)
            .asObservable()
            .compactMap { $0 }
            .flatMap { response -> Observable<Mutation> in
                switch response {
                case .success202(let signUpTokenEntity):
                    return .concat(
                        .just(.setLoading(false)),
                        .just(.setSignUpToken(signUpTokenEntity)),
                        .just(.setLoading(true))
                    )
                case .success200(let loginUserEntity):
                    return .concat(
                        .just(.setLoading(false)),
                        .just(.setLoginUser(loginUserEntity)),
                        .just(.setLoading(true))
                    )
                default:
                    // 다른 경우 처리 (필요하다면 에러 처리 또는 빈 시퀀스 반환)
                    return .just(.setLoading(false))
                }
            }

    }
    
    private func handleKakaoLogin() -> Observable<String> {
        return Observable.create { observer in
            // 카카오톡 앱에 접근 가능할 때
            if (UserApi.isKakaoTalkLoginAvailable()) {
                UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                    if let error = error {
                        WSLogger.error(category: "SignInViewReactor 카카오톡(설치O) 로그인 에러" ,
                                       message: "\(error)")
                        observer.onError(error)
                    } else if let oauthToken = oauthToken {
                        observer.onNext(oauthToken.accessToken)
                        observer.onCompleted()
                    }
                }
            } else { // 카카오톡 설치가 안되어 있으면
                UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                    if let error = error {
                        WSLogger.error(category: "SignInViewReactor 카카오톡(설치X) 로그인 에러" ,
                                       message: "\(error)")
                    } else if let oauthToken = oauthToken {
                        observer.onNext(oauthToken.accessToken)
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }
}
