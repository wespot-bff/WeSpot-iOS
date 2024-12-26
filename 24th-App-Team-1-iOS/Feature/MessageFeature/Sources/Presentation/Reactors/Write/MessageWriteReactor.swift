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

    private let fetchSearchResultUseCase: FetchStudentSearchResultUseCase
   
    
    // MARK: - Reactor Properties
    
    public var initialState: State
    
    public struct State {
        @Pulse var serachResult: StudentListResponseEntity?
        var cursorId: Int = 0
        @Pulse var NoSearchResult: Bool = false
    }
    
    public enum Action {
        case searchStudent(String)
    }
    
    public enum Mutation {
        case setSearchResult(StudentListResponseEntity?)
    }
    
    // MARK: - Init

    public init(
        fetchSearchResultUseCase: FetchStudentSearchResultUseCase
    ) {
        self.fetchSearchResultUseCase = fetchSearchResultUseCase
        self.initialState = State()
    }
}

// MARK: - Reactor

extension MessageWriteReactor {
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
            
        case .searchStudent(let name):
            return searhStudent(name: name)
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        
        case .setSearchResult(let result):
            newState.serachResult = result
        }
        
        return newState
    }
}

// MARK: - Mutation Logic

extension MessageWriteReactor {
    private func searhStudent(name: String) -> Observable<Mutation> {
        let query = SearchStudentRequest(name: name,
                                         cursorId: currentState.cursorId)
        return fetchSearchResultUseCase.excute(query: query)
            .asObservable()
            .flatMap { result in
                return Observable.just(Mutation.setSearchResult(result))
            }
    }
}

// MARK: - Helper Methods

extension MessageWriteReactor {
  
}
