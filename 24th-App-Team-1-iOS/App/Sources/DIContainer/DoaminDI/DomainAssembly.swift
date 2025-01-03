//
//  DomainAssembly.swift
//  wespot
//
//  Created by Kim dohyun on 7/23/24.
//

import Foundation
import CommonDomain
import CommonService
import SplashDomain
import VoteDomain
import LoginDomain
import MessageDomain
import AllDomain
import NotificationDomain

import Swinject

struct DomainAssembly: Assembly {
    func assemble(container: Container) {
        //common
        container.register(CreateCheckProfanityUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(CommonRepositoryProtocol.self)!
            return createCheckProfanityUseCase(commonRepository: repository)
        }
        
        container.register(FetchMajorAppVersionUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(CommonRepositoryProtocol.self)!
            return FetchMajorAppVersionUseCase(commonRepository: repository)
        }
        
        container.register(FetchMinorAppVersionUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(CommonRepositoryProtocol.self)!
            return FetchMinorAppVersionUseCase(commonRepository: repository)
        }
        
        container.register(CreateReportUserUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(CommonRepositoryProtocol.self)!
            return CreateReportUserUseCase(commonRepositroy: repository)
        }
        
        container.register(CreatePresigendURLUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(CommonRepositoryProtocol.self)!
            return CreatePresigendURLUseCase(commonRepository: repository)
        }
        
        container.register(UpdateUserProfileUploadUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(CommonRepositoryProtocol.self)!
            return UpdateUserProfileUploadUseCase(commonRepository: repository)
        }
        
        // login
        container.register(SignInUserUseCaseProtocol.self) { resovler in
            let repository = resovler.resolve(LoginRepositoryProtocol.self)!
            return SignInUserUseCase(loginRepository: repository)
        }
        
        
        container.register(SignUpUserUseCaseProtocol.self) { resovler in
            let repository = resovler.resolve(LoginRepositoryProtocol.self)!
            return SignUpUserUseCase(loginRepository: repository)
        }
        
        container.register(FetchSchoolListUseCaseProtocol.self) { resovler in
            let repository = resovler.resolve(LoginRepositoryProtocol.self)!
            return FetchSchoolListUseCase(loginRepository: repository)
        }
        
        container.register(FetchVoteOptionsUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(CommonRepositoryProtocol.self)!
            return FetchVoteOptionsUseCase(commonRepository: repository)
        }
        
        container.register(CreateVoteUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(VoteRepositoryProtocol.self)!
            return CreateVoteUseCase(repository: repository)
        }
        
        container.register(FetchWinnerVoteOptionsUseCaseProtocol.self) { resovler in
            let repository = resovler.resolve(VoteRepositoryProtocol.self)!
            return FetchWinnerVoteOptionsUseCase(voteRepository: repository)
        }
        
        container.register(FetchAllVoteOptionsUseCaseProtocol.self) { resovler in
            let repository = resovler.resolve(VoteRepositoryProtocol.self)!
            return FetchAllVoteOptionsUseCase(voteRepositroy: repository)
        }
        
        container.register(FetchVoteReceiveItemUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(VoteRepositoryProtocol.self)!
            return FetchVoteReceiveItemUseCase(voteRepository: repository)
        }
        
        container.register(FetchVoteSentItemUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(VoteRepositoryProtocol.self)!
            return FetchVoteSentItemUseCase(voteRepository: repository)
        }
        
        container.register(FetchIndividualItemUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(VoteRepositoryProtocol.self)!
            
            return FetchIndividualItemUseCase(voteRepository: repository)
        }

        // message
        container.register(FetchReservedMessageUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(MessageRepositoryProtocol.self)!
            return FetchReservedMessageUseCase(repository: repository)
        }
        
        container.register(FetchMessagesStatusUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(MessageRepositoryProtocol.self)!
            return FetchMessagesStatusUseCase(repository: repository)
        }
        
        container.register(FetchReceivedMessageUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(MessageRepositoryProtocol.self)!
            return FetchReceivedMessageUseCase(repository: repository)
        }
        
        // Profile
        container.register(FetchUserProfileUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(CommonRepositoryProtocol.self)!
            return FetchUserProfileUseCase(commonRepository: repository)
        }
        
        container.register(UpdateUserProfileImageUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(ProfileRepositoryProtocol.self)!
            return UpdateUserProfileImageUseCase(profileRepository: repository)
        }
        
        container.register(UpdateUserProfileUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(CommonRepositoryProtocol.self)!
            return UpdateUserProfileUseCase(commonRepository: repository)
        }
        
        container.register(FetchUserAlarmSettingUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(ProfileRepositoryProtocol.self)!
            return FetchUserAlarmSettingUseCase(profileRepository: repository)
        }
        
        container.register(UpdateUserAlarmSettingUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(ProfileRepositoryProtocol.self)!
            return UpdateUserAlarmSettingUseCase(profileRepository: repository)
        }
        
        container.register(FetchUserBlockUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(ProfileRepositoryProtocol.self)!
            return FetchUserBlockUseCase(profileRepository: repository)
        }
        
        container.register(UpdateUserBlockUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(ProfileRepositoryProtocol.self)!
            return UpdateUserBlockUseCase(profileRepository: repository)
        }
        
        container.register(FetchUserNotificationItemUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(NotificationRepositoryProtocol.self)!
            return FetchUserNotificationItemUseCase(notificationRepository: repository)
        }
        
        container.register(UpdateUserNotificationItemUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(NotificationRepositoryProtocol.self)!
            return UpdateUserNotificationItemUseCase(notificationRepository: repository)
        }
                                                                            
        container.register(CreateUserResignUseCaseProtocol.self) { resolver in
            let repository = resolver.resolve(ProfileRepositoryProtocol.self)!
            return CreateUserResignUseCase(profileRepository: repository)

        }
    }
}
