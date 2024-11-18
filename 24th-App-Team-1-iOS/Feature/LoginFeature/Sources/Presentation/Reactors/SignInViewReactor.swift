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
    
    private let createNewMemberUseCase: CreateNewMemberUseCaseProtocol
    private let globalService: WSGlobalServiceProtocol = WSGlobalStateService.shared
    public var initialState: State
    
    public struct State {
        var accountRequest: CreateAccountRequest
        @Pulse var signUpTokenResponse: CreateSignUpTokenResponseEntity?
        @Pulse var isLoading: Bool
        @Pulse var isShow: Bool
    }
    
    public enum Action {
        case signInWithApple(ASAuthorization)
        case signInWithKakao
    }
    
    public enum Mutation {
        case setSignUpTokenResponse(CreateSignUpTokenResponseEntity)
        case setLoading(Bool)
        case setTransitionFlag(Bool)
    }
    
    public init(createNewMemberUseCase: CreateNewMemberUseCaseProtocol) {
        self.createNewMemberUseCase = createNewMemberUseCase
        self.initialState = State(
            accountRequest: CreateAccountRequest(),
            isLoading: false,
            isShow: false
        )
    }
    
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
            return executeSignUp(socialType: SocialTypes.apple.rawValue.uppercased(), authorizationCode: authorizationCode, identityToken: identityToken)
        case .signInWithKakao:
            UserDefaultsManager.shared.socialType = SocialTypes.kakao.rawValue
            return handleKakaoLogin()
                .flatMap { self.executeSignUp(socialType: SocialTypes.kakao.rawValue.uppercased(), authorizationCode: "", identityToken: $0) }
            
        }
    }
    
    func handleKakaoLogin() -> Observable<String> {
        return Observable.create { observer in
            // 카카오톡 앱에 접근 가능할 때
            if (UserApi.isKakaoTalkLoginAvailable()) {
                UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                    if let error = error {
                        print(error)
                        observer.onError(error)
                    } else if let oauthToken = oauthToken {
                        observer.onNext(oauthToken.accessToken)
                        observer.onCompleted()
                    }
                }
            } else { // 카카오톡 설치가 안되어 있으면
                UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                    if let error = error {
                        print(error)
                    } else if let oauthToken = oauthToken {
                        observer.onNext(oauthToken.accessToken)
                        observer.onCompleted()
                    }
                }
            }
            return Disposables.create()
        }
    }
    
    private func executeSignUp(socialType: String, authorizationCode: String, identityToken: String) -> Observable<Mutation> {
        let fcmToken = UserDefaultsManager.shared.fcmToken ?? ""
        let body = CreateSignUpTokenRequest(socialType: socialType,
                                            authorizationCode: authorizationCode,
                                            identityToken: identityToken,
                                            fcmToken: fcmToken)
        
        let accessToken = KeychainManager.shared.get(type: .accessToken)
        
        if accessToken == nil {
            return createNewMemberUseCase
                .execute(body: body)
                .asObservable()
                .compactMap { $0 }
                .flatMap { response -> Observable<Mutation> in
                    return .concat(
                        .just(.setLoading(false)),
                        .just(.setSignUpTokenResponse(response)),
                        .just(.setLoading(true))
                    )
                }
        } else {
            return .just(.setTransitionFlag(true))
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setSignUpTokenResponse(let signUpTokenResponse):
            newState.signUpTokenResponse = signUpTokenResponse
            newState.accountRequest.signUpToken = signUpTokenResponse.signUpToken
            let expiredDate = Date.now.addingTimeInterval(30 * 60)
                .toFormatLocaleString(with: .dashYyyyMMddhhmmss)
                .toLocalDate(with: .dashYyyyMMddhhmmss)
            UserDefaultsManager.shared.expiredDate = expiredDate
        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case let .setTransitionFlag(isShow):
            newState.isShow = isShow
        }
        return newState
    }
}
