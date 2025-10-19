//
//  ProfileResignBottomSheetVieReactor.swift
//  AllFeature
//
//  Created by Kim dohyun on 8/17/24.
//

import Foundation

import ReactorKit
import AllDomain
import Util

public final class ProfileResignBottomSheetVieReactor: Reactor {
    public var initialState: State
    private let globalState: WSGlobalServiceProtocol = WSGlobalStateService.shared
    private let createUserResignUseCase: CreateUserResignUseCaseProtocol
    
    
    
    public enum Action {
        case didTappedResignConfirmButton
        case didTappedAgreementButton
        case didTappedResignAlarmButton
    }
    
    public enum Mutation {
        case setAgreementEnabled(Bool)
        case setUserResign(Bool)
    }
    
    public struct State {
        var isEnabled: Bool
        var isSuccess: Bool
    }
    
    public init(createUserResignUseCase: CreateUserResignUseCaseProtocol) {
        self.initialState = State(isEnabled: false, isSuccess: false)
        self.createUserResignUseCase = createUserResignUseCase
    }
    
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTappedResignAlarmButton:
            return createUserResignUseCase
                .execute()
                .asObservable()
                .withUnretained(self)
                .flatMap { owner, isSuccess ->  Observable<Mutation> in
                    owner.globalState.event.onNext(.didTappedRevokeButton(isSuccess))
                    return .just(.setUserResign(isSuccess))
                }
            
        case .didTappedResignConfirmButton:
            globalState.event.onNext(.didTappedResignButton(true))
            return .empty()
        case .didTappedAgreementButton:
            return .just(.setAgreementEnabled(!currentState.isEnabled))
        }
    }
    
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setAgreementEnabled(isEnabled):
            newState.isEnabled = isEnabled
        case let .setUserResign(isSuccess):
            newState.isSuccess = isSuccess
        }
        
        return newState
    }
    
}
