//
//  TermsViewReactor.swift
//  VoteFeature
//
//  Created by 김도현 on 10/13/25.
//

import Foundation

import ReactorKit
import CommonDomain

public final class TermsViewReactor: Reactor {
    
    private let updateAllowPolicyUseCase: UpdateAllowPolicyUseCaseProtocol
    
    
    public var initialState: State
    
    public struct State {
        @Pulse var isSuccess: Bool = false
    }
    
    public enum Action {
        case didTappedAllowButton
    }
    
    public enum Mutation {
        case setAllow(Bool)
    }
    
    public init(updateAllowPolicyUseCase: UpdateAllowPolicyUseCaseProtocol) {
        self.initialState = State()
        self.updateAllowPolicyUseCase = updateAllowPolicyUseCase
        
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .didTappedAllowButton:
            let query = UpdateAllowPollcyQuery(policyType: "NEW_POLICY_ABOUT_ACCOUNT")
            return updateAllowPolicyUseCase
                .execute(query: query)
                .asObservable()
                .flatMap { isSuccess -> Observable<Mutation> in
                    return .just(.setAllow(isSuccess))
                }
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setAllow(isSuccess):
            newState.isSuccess = isSuccess
        }
        
        return newState
    }
}
