//
//  SplashViewReactor.swift
//  LoginFeature
//
//  Created by 김도현 on 11/30/24.
//

import ReactorKit
import CommonDomain
import Util

public final class SplashViewReactor: Reactor {
    public var initialState: State
    private let fetchAppVersionUseCase: FetchAppVersionItemUseCaseProtocol
    
    public enum Action {
        case willEnterForeground
    }
    
    public enum Mutation {
        case setUpdatetype(WSUpdateTypes)
    }
    
    public struct State {
        var accessToken: String?
        var updateType: WSUpdateTypes = .noUpdate
    }
    
    public init(
        fetchAppVersionUseCase: FetchAppVersionItemUseCaseProtocol,
        accessToken: String?
    ) {
        self.initialState = State(accessToken: accessToken)
        self.fetchAppVersionUseCase = fetchAppVersionUseCase
    }
    
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .willEnterForeground:
            return Observable.create { [weak self] observer in
                Task {
                    do {
                        guard let self else { return }
                        let updateType = try await self.fetchAppVersionUseCase.execute()
                        observer.onNext(.setUpdatetype(updateType))
                    } catch {
                        observer.onError(error)
                    }
                }
                return Disposables.create()
            }
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setUpdatetype(updateType):
            newState.updateType = updateType
        }
        
        return newState
    }
    
}
