//
//  MessageWriteReactor.swift
//  MessageFeature
//
//  Created by 최지철 on 12/22/24.
//

import MessageDomain
import Extensions

import ReactorKit

public final class MessageWriteReactor: Reactor {
    
    // MARK: - UseCase

    
   
    
    // MARK: - Reactor Properties
    
    public var initialState: State
    
    public struct State {

    }
    
    public enum Action {

    }
    
    public enum Mutation {

    }
    
    // MARK: - Init

    public init(

    ) {
        
        self.initialState = State()
    }
}

// MARK: - Reactor

extension MessageWriteReactor {
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        
        }
        
        return newState
    }
}

// MARK: - Mutation Logic

extension MessageWriteReactor {
    /// 시간 체크 후 Mutation 반환
 
}

// MARK: - Helper Methods

extension MessageWriteReactor {
  
}
