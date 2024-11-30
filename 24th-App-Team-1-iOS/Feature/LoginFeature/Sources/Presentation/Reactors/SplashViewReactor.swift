//
//  SplashViewReactor.swift
//  LoginFeature
//
//  Created by 김도현 on 11/30/24.
//

import ReactorKit

public final class SplashViewReactor: Reactor {
    public var initialState: State
    
    public typealias Action = NoAction
    
    public struct State {
        @Pulse var accessToken: String?
    }
    
    public init(accessToken: String?) {
        self.initialState = State(accessToken: accessToken)
    }
    
}
