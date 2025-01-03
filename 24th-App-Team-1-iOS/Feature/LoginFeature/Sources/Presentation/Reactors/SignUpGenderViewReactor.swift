//
//  SignUpGenderViewReactor.swift
//  LoginFeature
//
//  Created by eunseou on 7/12/24.
//

import Foundation
import Util

import ReactorKit
import LoginDomain

public final class SignUpGenderViewReactor: Reactor {
    
    private let globalService: WSGlobalServiceProtocol = WSGlobalStateService.shared
    
    public struct State {
        var accountRequest: SignUpUserRequest
        var schoolName: String
    }
    
    public enum Action {
        case selectGender(String)
    }
    
    public enum Mutation {
        case setGender(String)
    }
    
    public var initialState: State
    
    public init(accountRequest: SignUpUserRequest,
                schoolName: String) {
        self.initialState = State(accountRequest: accountRequest, schoolName: schoolName)
    }
    
    public  func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .selectGender(let gender):
            globalService.event.onNext(.didTappedAccountGenderButton(gender: gender))
            return .just(.setGender(gender))
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setGender(let gender):
            newState.accountRequest.gender = gender
        }
        return newState
    }
}
