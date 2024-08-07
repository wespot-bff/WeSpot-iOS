//
//  SignUpNameViewReactor.swift
//  LoginFeature
//
//  Created by eunseou on 7/12/24.
//

import Foundation
import CommonDomain
import ReactorKit
import RxSwift

public final class SignUpNameViewReactor: Reactor {
    
    private let createCheckProfanityUseCase: CreateCheckProfanityUseCaseProtocol
    public var initialState: State
    
    public struct State {
        var name: String = ""
        var errorMessage: String?
        var isButtonEnabled: Bool = false
        var isWarningHidden: Bool = true
    }
    
    public enum Action {
        case inputName(String)
    }
    
    public enum Mutation {
        case setName(String)
        case setErrorMessage(String?)
        case setButtonEnabled(Bool)
        case setWarningHidden(Bool)
    }
    
    public init(createCheckProfanityUseCase: CreateCheckProfanityUseCaseProtocol) {
        self.createCheckProfanityUseCase = createCheckProfanityUseCase
        self.initialState = State()
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .inputName(let name):
            
            let body = CreateCheckProfanityRequest(message: name)
            
            return createCheckProfanityUseCase
                .execute(body: body)
                .asObservable()
                .flatMap { isProfane -> Observable<Mutation> in
                    if isProfane {
                        return Observable.concat([
                            .just(Mutation.setName(name)),
                            .just(Mutation.setErrorMessage("비속어가 포함되어 있어요")),
                            .just(Mutation.setButtonEnabled(false)),
                            .just(Mutation.setWarningHidden(false))
                        ])
                    } else {
                        let isValid = self.validateName(name)
                        let errorMessage = isValid ? nil : (name.count <= 1 ? nil : "2~5자의 한글만 입력 가능해요")
                        let isButtonEnabled = name.count >= 2 && isValid
                        let isWarningHidden = name.count <= 1
                        
                        return Observable.concat([
                            .just(Mutation.setName(name)),
                            .just(Mutation.setErrorMessage(errorMessage)),
                            .just(Mutation.setButtonEnabled(isButtonEnabled)),
                            .just(Mutation.setWarningHidden(isWarningHidden))
                        ])
                    }
                }
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setName(let name):
            newState.name = name
            
        case .setErrorMessage(let errorMessage):
            newState.errorMessage = errorMessage
            
        case .setButtonEnabled(let isEnabled):
            newState.isButtonEnabled = isEnabled
            
        case .setWarningHidden(let isHidden):
            newState.isWarningHidden = isHidden
        }
        
        return newState
    }
    
    private func validateName(_ name: String) -> Bool {
        let regex = "^[가-힣]{2,5}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: name)
    }
}
