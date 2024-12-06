//
//  VoteMainViewReactor.swift
//  VoteFeature
//
//  Created by Kim dohyun on 7/11/24.
//

import Foundation
import Util
import CommonDomain

import ReactorKit

public final class VoteMainViewReactor: Reactor {
    public var initialState: State
    private let globalService: WSGlobalServiceProtocol = WSGlobalStateService.shared
    private let fetchAppVersionUseCase: FetchAppVersionItemUseCaseProtocol
    
    
    
    public enum Action {
        case viewDidLoad
        case didTapToggleButton(VoteTypes)
    }
    
    public struct State {
        var voteTypes: VoteTypes
        var updateType: WSUpdateTypes
        @Pulse var isShowEffectView: Bool
        @Pulse var isSelected: Bool
        @Pulse var voteResponseEntity: VoteResponseEntity?
    }
    
    public enum Mutation {
        case setVoteTypes(VoteTypes)
        case setUpdateType(WSUpdateTypes)
        case setSelectedVoteButton(Bool, VoteResponseEntity?)
        case setShowEffectView(Bool)
    }
    
    public init(
        fetchAppVersionUseCase:FetchAppVersionItemUseCaseProtocol
    ) {
        self.initialState = State(
            voteTypes: .main,
            updateType: .noUpdate,
            isShowEffectView: false,
            isSelected: false
        )
        self.fetchAppVersionUseCase = fetchAppVersionUseCase
    }
    
    public func transform(mutation: Observable<Mutation>) -> Observable<Mutation> {
        let fetchVoteResponse = globalService.event
            .flatMap { event -> Observable<Mutation> in
                switch event {
                case let .didTappedVoteButton(isSelected, response):
                    return .just(.setSelectedVoteButton(isSelected, response))
                case .didTappedResultButton:
                    return .just(.setShowEffectView(true))
                default:
                    return .empty()
                }
            }
        return .merge(mutation, fetchVoteResponse)
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            return Observable.create { [weak self] observer in
                Task {
                    do {
                        guard let self else { return }
                        let updateType = try await self.fetchAppVersionUseCase.execute()
                        observer.onNext(.setUpdateType(updateType))
                    } catch {
                        observer.onError(error)
                    }
                }
                return Disposables.create()
            }
            
        case let .didTapToggleButton(voteTypes):
            return .just(.setVoteTypes(voteTypes))
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setSelectedVoteButton(isSelected, response):
            newState.isSelected = isSelected
            newState.voteResponseEntity = response
        case let .setVoteTypes(voteTypes):
            globalService.event.onNext(.toggleStatus(voteTypes))
            newState.voteTypes = voteTypes
        case let .setShowEffectView(isShowEffectView):
            newState.isShowEffectView = isShowEffectView
        case let .setUpdateType(updateType):
            newState.updateType = updateType
        }
        
        return newState
    }
}
