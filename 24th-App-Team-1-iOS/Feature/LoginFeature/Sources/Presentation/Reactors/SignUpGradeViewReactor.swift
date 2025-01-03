//
//  SignUpGradeViewReactor.swift
//  LoginFeature
//
//  Created by eunseou on 7/12/24.
//

import Foundation
import Util

import ReactorKit
import LoginDomain

public final class SignUpGradeViewReactor: Reactor {
    
    private let globalService: WSGlobalServiceProtocol = WSGlobalStateService.shared
    
    public struct State {
        var accountRequest: SignUpUserRequest
        var isGradeSelected: Bool = false
        var schoolName: String
        @Pulse var isSelected: Bool = false
    }
    
    public enum Action {
        case selectGrade(Int)
        case didTappedNextButton
    }
    
    public enum Mutation {
        case setGrade(Int)
        case setGradeSelected(Bool)
        case setConfirm(Bool)
    }
    
    public var initialState: State
    
    public init(accountRequest: SignUpUserRequest,
                schoolName: String) {
        self.initialState = State(accountRequest: accountRequest, schoolName: schoolName)
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .selectGrade(let grade):
            
            return Observable.concat([
                .just(.setGrade(grade)),
                .just(.setGradeSelected(true))
            ])
        case .didTappedNextButton:
            globalService.event.onNext(.didChangedAccountGrade(grade: currentState.accountRequest.grade))
            return .just(.setConfirm(true))
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setGrade(let grade):
            newState.accountRequest.grade = grade
        case .setGradeSelected(let isSelected):
            newState.isGradeSelected = isSelected
        case let .setConfirm(isSelected):
            newState.isSelected = isSelected
        }
        return newState
    }
}
