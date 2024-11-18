//
//  SignUpIntroduceViewReactor.swift
//  LoginFeature
//
//  Created by Kim dohyun on 8/28/24.
//

import Foundation
import Util
import CommonDomain
import LoginDomain

import ReactorKit

public final class SignUpIntroduceViewReactor: Reactor {
    
    let globalService: WSGlobalServiceProtocol = WSGlobalStateService.shared
    private let createCheckProfanityUseCase: CreateCheckProfanityUseCaseProtocol
    private let createPresignedURLUseCase: CreatePresigendURLUseCaseProtocol
    private let updateUserProfileUploadUseCaseProtocol: UpdateUserProfileUploadUseCaseProtocol
    
    public struct State {
        @Pulse var accountReqeust: CreateAccountRequest
        var introduce: String
        var schoolName: String
        @Pulse var imageData: Data?
        @Pulse var errorMessage: String
        @Pulse var isLoading: Bool
        @Pulse var isValidation: Bool
        @Pulse var isUpload: Bool
        @Pulse var imageURL: String?
    }
    
    public enum Action {
        case didUpdateIntroduce(String)
        case didSelectedImage(Data)
    }
    
    public enum Mutation {
        case setIntroduce(String)
        case setErrorMessage(String)
        case setProfileImageData(Data)
        case setIntroduceValidation(Bool)
        case setProfileImageURL(String)
        case setLoading(Bool)
    }
    
    public let initialState: State
    
    
    public init(
        accountReqeust: CreateAccountRequest,
        createCheckProfanityUseCase: CreateCheckProfanityUseCaseProtocol,
        createPresignedURLUseCase: CreatePresigendURLUseCaseProtocol,
        updateUserProfileUploadUseCaseProtocol: UpdateUserProfileUploadUseCaseProtocol,
        schoolName: String
    ) {
        self.createCheckProfanityUseCase = createCheckProfanityUseCase
        self.createPresignedURLUseCase = createPresignedURLUseCase
        self.updateUserProfileUploadUseCaseProtocol = updateUserProfileUploadUseCaseProtocol
        self.initialState = State(
            accountReqeust: accountReqeust,
            introduce: "",
            schoolName: schoolName,
            errorMessage: "",
            isLoading: true,
            isValidation: true,
            isUpload: false
        )
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        
        switch action {
        case let .didUpdateIntroduce(introduce):
            let checkIntroduceProfanityBody = CreateCheckProfanityRequest(message: introduce)
            return createCheckProfanityUseCase
                .execute(body: checkIntroduceProfanityBody)
                .asObservable()
                .flatMap { isProfanity -> Observable<Mutation> in
                    if isProfanity {
                        return .concat(
                            .just(.setErrorMessage("비속어가 포함되어 있어요")),
                            .just(.setIntroduceValidation(false))
                        )
                    }
                   
                    let isValidation = introduce.count > 20 ? false : true
                    let errorMessage = introduce.count > 20 ? "20자 이내로 입력 가능해요" : ""
                    
                    return .concat(
                        .just(.setIntroduceValidation(isValidation)),
                        .just(.setIntroduce(introduce))
                    )
                }
        case let .didSelectedImage(binaryData):
            let profilePresignedURLRequest = CreateProfilePresignedURLQuery(imageExtension: "jpeg")
            return createPresignedURLUseCase
                .execute(query: profilePresignedURLRequest)
                .asObservable()
                .withUnretained(self)
                .flatMap { owner, presignedInfo -> Observable<Mutation> in
                    guard let entity = presignedInfo else {
                        return .empty()
                    }
                    return owner.updateUserProfileUploadUseCaseProtocol
                        .execute(binaryData, presigendURL: entity.presignedURL)
                        .asObservable()
                        .flatMap { isUpload -> Observable<Mutation> in
                            return .concat(
                                .just(.setLoading(false)),
                                .just(.setProfileImageData(binaryData)),
                                .just(.setProfileImageURL(entity.imageURL)),
                                .just(.setLoading(true))
                            )
                        }
                }
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setIntroduce(introduce):
            newState.accountReqeust.introduction = introduce
            newState.introduce = introduce
        case let .setErrorMessage(errorMessage):
            newState.errorMessage = errorMessage
        case let .setIntroduceValidation(isValidation):
            newState.isValidation = isValidation
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
        case let .setProfileImageData(imageData):
            newState.imageData = imageData
        case let .setProfileImageURL(imageURL):
            newState.imageURL = imageURL
            newState.accountReqeust.profileUrl = imageURL
        }
        
        return newState
    }
}
