//
//  ProfileSettingViewReactor.swift
//  AllFeature
//
//  Created by Kim dohyun on 8/12/24.
//

import Foundation
import CommonDomain
import AllDomain

import ReactorKit

public final class ProfileSettingViewReactor: Reactor {
    private let createCheckProfanityUseCase: CreateCheckProfanityUseCaseProtocol
    private let updateUserProfileUseCase: UpdateUserProfileUseCaseProtocol
    private let fetchUserProfileUseCase: FetchUserProfileUseCaseProtocol
    private let updateUserProfileImageUseCase: UpdateUserProfileImageUseCaseProtocol
    private let updateUserProfileUploadUseCase :UpdateUserProfileUploadUseCaseProtocol
    private let createPresignedURLUseCase: CreatePresigendURLUseCaseProtocol
    
    
    
    
    public struct State {
        @Pulse var isProfanity: Bool
        @Pulse var userProfileImageEntity: UpdateUserProfileImageEntity?
        @Pulse var userProfileEntity: UserProfileEntity?
        @Pulse var isUpdate: Bool
        @Pulse var isLoading: Bool
        @Pulse var imageData: Data?
        @Pulse var isEnabled: Bool
        var isSelected: Bool
        var errorMessage: String
        var introudce: String
    }
    
    public enum Action {
        case didUpdateIntroduceProfile(String)
        case didTappedProfileEditButton(Data)
        case didTappedRemoveProfileImage
        case didTapUpdateUserButton
        case viewWillAppear
    }
    
    public enum Mutation {
        case setCheckProfanityValidation(Bool)
        case setProfileImage(Data)
        case setButtonEnabled(Bool)
        case setErrorDescriptionMessage(String)
        case setUpdateUserProfileItem(UserProfileEntity)
        case setUserProfileImageItem(UpdateUserProfileImageEntity)
        case setUpdateIntroduce(String)
        case setUpdateUserProfile(Bool)
        case setLoading(Bool)
        case setSelectedImage(Bool)
    }
    
    public let initialState: State
    
    public init(
        createCheckProfanityUseCase: CreateCheckProfanityUseCaseProtocol,
        updateUserProfileUseCase: UpdateUserProfileUseCaseProtocol,
        fetchUserProfileUseCase: FetchUserProfileUseCaseProtocol,
        updateUserProfileImageUseCase: UpdateUserProfileImageUseCaseProtocol,
        createPresignedURLUseCase: CreatePresigendURLUseCaseProtocol,
        updateUserProfileUploadUseCase: UpdateUserProfileUploadUseCaseProtocol
    ) {
        self.createCheckProfanityUseCase = createCheckProfanityUseCase
        self.updateUserProfileUseCase = updateUserProfileUseCase
        self.fetchUserProfileUseCase = fetchUserProfileUseCase
        self.updateUserProfileImageUseCase = updateUserProfileImageUseCase
        self.createPresignedURLUseCase = createPresignedURLUseCase
        self.updateUserProfileUploadUseCase = updateUserProfileUploadUseCase
        self.initialState = State(
            isProfanity: false,
            isUpdate: false,
            isLoading: false,
            isEnabled: false,
            isSelected: false,
            errorMessage: "",
            introudce: ""
        )
    }
    
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            return fetchUserProfileUseCase
                .execute()
                .asObservable()
                .compactMap { $0 }
                .flatMap { entity -> Observable<Mutation> in
                    return .concat(
                        .just(.setLoading(false)),
                        .just(.setUpdateUserProfileItem(entity)),
                        .just(.setLoading(true))
                    )
                }
        case let .didUpdateIntroduceProfile(introduce):
            let checkProfanityBody = CreateCheckProfanityRequest(message: introduce)
            return createCheckProfanityUseCase
                .execute(body: checkProfanityBody)
                .asObservable()
                .withUnretained(self)
                .flatMap { owner, isProfanity -> Observable<Mutation> in
                    if isProfanity {
                        return .concat(
                            .just(.setButtonEnabled(false)),
                            .just(.setErrorDescriptionMessage("비속어가 포함되어 있어요")),
                            .just(.setCheckProfanityValidation(isProfanity))
                        )
                    } else {
                        
                        let isChanged = introduce != self.currentState.userProfileEntity?.introduction
                        let isValid = introduce.count <= 20
                        
                        let isDisabled = !isChanged || !isValid
                        let errorMessage = isValid ? "" : "20자 이내로 입력 가능해요"
                        return .concat(
                            .just(.setCheckProfanityValidation(!isValid)),
                            .just(.setErrorDescriptionMessage(errorMessage)),
                            .just(.setButtonEnabled(!isDisabled)),
                            .just(.setUpdateIntroduce(introduce))
                        )
                    }
                }
        case .didTapUpdateUserButton:
            if currentState.isSelected == false {
                let body = UpdateUserProfileRequest(introduction: currentState.introudce)
                return updateUserProfileUseCase.execute(body: body)
                    .asObservable()
                    .flatMap { isProfileUpdate -> Observable<Mutation> in
                        return .concat(
                            .just(.setLoading(false)),
                            .just(.setButtonEnabled(false)),
                            .just(.setUpdateUserProfile(isProfileUpdate)),
                            .just(.setLoading(true))
                        )
                    }

            } else {
                let query = CreateProfilePresignedURLQuery(imageExtension: "jpeg")
                
                return createPresignedURLUseCase.execute(query: query)
                    .asObservable()
                    .withUnretained(self)
                    .flatMap { owner, presignedInfo -> Observable<Mutation> in
                        guard let entity = presignedInfo else {
                            return .empty()
                        }
                        
                        return owner.updateUserProfileUploadUseCase.execute(owner.currentState.imageData ?? .empty, presigendURL: entity.presignedURL)
                            .asObservable()
                            .flatMap { isUpload -> Observable<Mutation> in
                                let profileQuery = UpdateUserProfileImageRequestQuery(url: entity.imageURL)
                                return owner.updateUserProfileImageUseCase.execute(query: profileQuery)
                                    .asObservable()
                                    .flatMap { entity -> Observable<Mutation> in
                                        guard let entity else{
                                            return .empty()
                                        }
                                        return .concat(
                                            .just(.setLoading(false)),
                                            .just(.setUserProfileImageItem(entity)),
                                            .just(.setUpdateUserProfile(true)),
                                            .just(.setLoading(true))
                                        )
                                    }
                            }
                    }
            }
            
        case let .didTappedProfileEditButton(binaryData):
            return .concat(
                .just(.setProfileImage(binaryData)),
                .just(.setSelectedImage(true)),
                .just(.setButtonEnabled(true))
            )
        case .didTappedRemoveProfileImage:
            let query = UpdateUserProfileImageRequestQuery(url: nil)
            
            return updateUserProfileImageUseCase.execute(query: query)
                .asObservable()
                .flatMap { entity -> Observable<Mutation> in
                    guard let entity else {
                        return .empty()
                    }
                    
                    return .concat(
                        .just(.setLoading(false)),
                        .just(.setUpdateUserProfile(true)),
                        .just(.setUserProfileImageItem(entity)),
                        .just(.setLoading(true))
                    )
                }
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case let .setCheckProfanityValidation(isProfanity):
            newState.isProfanity = isProfanity
        case let .setErrorDescriptionMessage(errorMessage):
            newState.errorMessage = errorMessage
        case let .setUpdateIntroduce(introduce):
            newState.introudce = introduce
        case let .setUpdateUserProfile(isUpdate):
            newState.isUpdate = isUpdate
        case let .setUpdateUserProfileItem(userProfileEntity):
            newState.userProfileEntity = userProfileEntity
        case let .setButtonEnabled(isEnabled):
            newState.isEnabled = isEnabled
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
        case let .setProfileImage(imageData):
            newState.imageData = imageData
        case let .setUserProfileImageItem(userProfileImageEntity):
            newState.userProfileImageEntity = userProfileImageEntity
        case let .setSelectedImage(isSelected):
            newState.isSelected = isSelected
        }
        
        return newState
    }
}

extension ProfileSettingViewReactor {
    
    private func validationIntroduce(_ introduce: String) -> Bool {
        let regex = "^[가-힣!_@$%^&+=A-Za-z0-9]{1,20}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: introduce)
    }
    
}
