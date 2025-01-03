//
//  AllMainProfilePresentationAssembly.swift
//  wespot
//
//  Created by Kim dohyun on 8/12/24.
//

import Foundation
import AllFeature
import AllDomain
import CommonDomain

import Swinject


struct AllMainProfilePresentationAssembly: Assembly {
    
    func assemble(container: Container) {
        container.register(ProfileSettingViewReactor.self) { (resolver) in
            let createCheckProfanityUseCase = resolver.resolve(CreateCheckProfanityUseCaseProtocol.self)!
            let fetchUserProfileUseCase = resolver.resolve(FetchUserProfileUseCaseProtocol.self)!
            let updateUserProfileUseCase = resolver.resolve(UpdateUserProfileUseCaseProtocol.self)!
            let updateUserImageProfileUseCase = resolver.resolve(UpdateUserProfileImageUseCaseProtocol.self)!
            let createPresignedURLUseCase = resolver.resolve(CreatePresigendURLUseCaseProtocol.self)!
            let updateUserProfileUploadUseCase = resolver.resolve(UpdateUserProfileUploadUseCaseProtocol.self)!
            return ProfileSettingViewReactor(
                createCheckProfanityUseCase: createCheckProfanityUseCase,
                updateUserProfileUseCase: updateUserProfileUseCase,
                fetchUserProfileUseCase: fetchUserProfileUseCase,
                updateUserProfileImageUseCase: updateUserImageProfileUseCase,
                createPresignedURLUseCase: createPresignedURLUseCase,
                updateUserProfileUploadUseCase: updateUserProfileUploadUseCase
            )
        }
        
        container.register(ProfileSettingViewController.self) { resolver in
            let reactor = resolver.resolve(ProfileSettingViewReactor.self)!
            
            return ProfileSettingViewController(reactor: reactor)
        }
    }
}
