//
//  PolicyAgreementBottomSheetViewReactor.swift
//  LoginFeature
//
//  Created by Kim dohyun on 8/27/24.
//

import Foundation
import Util

import ReactorKit

public final class PolicyAgreementBottomSheetViewReactor: Reactor {
    public var initialState: State
    private let globalService: WSGlobalServiceProtocol = WSGlobalStateService.shared
    
    public enum Action {
        case didTappedAllAgreement
        case didTappedPrivacyAgreement
        case didTappedServiceAgreement
        case didTappedMarketingAgreement
        case didTappedAgeAgreement
        case didTappedConfirmButton
    }
    
    public enum Mutation {
        case setupAllAgreement(Bool)
        case setupServiceAgreement(Bool)
        case setupAgeAgreement(Bool)
        case setupPrivacyAgreement(Bool)
        case setupMarketingAgreement(Bool)
        case setupConfirmButton(Bool)
    }
    
    public struct State {
        var isAllAgreement: Bool
        var isServiceAgreement: Bool
        var isPrivacyAgreement: Bool
        var isAgeAgreement: Bool
        var isMarketingAgreement: Bool
        var isEnabled: Bool
    }
    
    public init() {
        self.initialState = State(
            isAllAgreement: false,
            isServiceAgreement: false,
            isPrivacyAgreement: false,
            isAgeAgreement: false,
            isMarketingAgreement: false,
            isEnabled: false
        )
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTappedAllAgreement:
            return .concat(
                .just(.setupServiceAgreement(!currentState.isAllAgreement)),
                .just(.setupAgeAgreement(!currentState.isAgeAgreement)),
                .just(.setupAllAgreement(!currentState.isAllAgreement)),
                .just(.setupConfirmButton(!currentState.isAllAgreement)),
                .just(.setupMarketingAgreement(!currentState.isAllAgreement)),
                .just(.setupPrivacyAgreement(!currentState.isAllAgreement))
            )
        case .didTappedAgeAgreement:
            let isEnabled = !currentState.isAgeAgreement == true && currentState.isServiceAgreement == true ? true : false
            print("만 14세 이상 동의 체크값 입니다 : \(isEnabled)")
            return .concat(
                .just(.setupAgeAgreement(!currentState.isAgeAgreement)),
                .just(.setupConfirmButton(isEnabled))
            )
            
        case .didTappedPrivacyAgreement:
            let isEnabled = !currentState.isPrivacyAgreement == true && currentState.isServiceAgreement == true ? true : false
            return .concat(
                .just(.setupPrivacyAgreement(!currentState.isPrivacyAgreement)),
                .just(.setupConfirmButton(isEnabled))
            )
        case .didTappedServiceAgreement:
            let isEnabled = currentState.isPrivacyAgreement == true && !currentState.isServiceAgreement == true ? true : false
            return .concat(
                .just(.setupServiceAgreement(!currentState.isServiceAgreement)),
                .just(.setupConfirmButton(isEnabled))
            )
        case .didTappedMarketingAgreement:
            return .just(.setupMarketingAgreement(!currentState.isMarketingAgreement))
        case .didTappedConfirmButton:
            globalService.event.onNext(.didTappedAccountSuccessButton(true))
            return .empty()
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setupAgeAgreement(isAgeagreement):
            newState.isAgeAgreement = isAgeagreement
        case let .setupAllAgreement(isAllAgreement):
            newState.isAllAgreement = isAllAgreement
        case let .setupServiceAgreement(isServiceAgreement):
            newState.isServiceAgreement = isServiceAgreement
        case let .setupPrivacyAgreement(isPrivacyAgreement):
            newState.isPrivacyAgreement = isPrivacyAgreement
        case let .setupConfirmButton(isEnabled):
            newState.isEnabled = isEnabled
        case let .setupMarketingAgreement(isMarketingAgreement):
            globalService.event.onNext(.didTappedMarketingButton(isMarketingAgreement))
            newState.isMarketingAgreement = isMarketingAgreement
        }
        return newState
    }
    
}
