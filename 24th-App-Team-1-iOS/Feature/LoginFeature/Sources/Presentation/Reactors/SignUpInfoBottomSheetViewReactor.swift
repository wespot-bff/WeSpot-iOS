//
//  SignUpInfoBottomSheetViewReactor.swift
//  LoginFeature
//
//  Created by Kim dohyun on 8/26/24.
//

import Foundation
import LoginDomain
import Util

import ReactorKit

public final class SignUpInfoBottomSheetViewReactor: Reactor {
    public typealias Mutation = NoMutation
    
    private let globalService: WSGlobalServiceProtocol = WSGlobalStateService.shared
    
    public let initialState: State
    
    public enum Action {
        case didTappedAccountEditButton
        case didTappedConfirmButton
    }
    
    public struct State {
        var accountRequest: CreateAccountRequest
        var schoolName: String
        var profileImage: Data?
    }
    
    public init(accountRequest: CreateAccountRequest, schoolName: String, profileImage: Data?) {
        self.initialState = State(
            accountRequest: accountRequest,
            schoolName: schoolName,
            profileImage: profileImage
        )
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case .didTappedAccountEditButton:
            globalService.event.onNext(.didTappedAccountEditButton(true))
        case .didTappedConfirmButton:
            globalService.event.onNext(.didTappedAccountConfirmButton(true))
        }
        
        return .empty()
    }
    
}
