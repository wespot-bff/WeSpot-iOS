//
//  SignUpPresntationAssembly.swift
//  wespot
//
//  Created by eunseou on 7/31/24.
//

import Foundation
import CommonDomain
import LoginFeature
import LoginDomain

import Swinject


/// SignUpSchool DIContainer
struct SignUpSchoolPresentationAssembly: Assembly {
    func assemble(container: Container) {
        
        container.register(SignUpSchoolViewReactor.self) { (resolver,
                                                            accountRequest: SignUpUserRequest,
                                                            schoolName: String)  in
            let fetchSchoolListUseCase = resolver.resolve(FetchSchoolListUseCaseProtocol.self)!
            return SignUpSchoolViewReactor(fetchSchoolListUseCase: fetchSchoolListUseCase, accountRequest: accountRequest, schoolName: schoolName)
        }

        container.register(SignUpSchoolViewController.self) { (resolver, accountRequest: SignInUserRequest, schoolName: String) in
            let reactor = resolver.resolve(SignUpSchoolViewReactor.self, arguments: accountRequest, schoolName)!
            
            return SignUpSchoolViewController(reactor: reactor)
        }

    }
}

/// SignUpGrade DIContainer
struct SignUpGradePresentationAssembly: Assembly {
    func assemble(container: Container) {

        container.register(SignUpGradeViewReactor.self) {(resolver, accountRequest: SignUpUserRequest, schoolName: String) in
            return SignUpGradeViewReactor(accountRequest: accountRequest, schoolName: schoolName)
        }

        container.register(SignUpGradeViewController.self) { (resolver, accountRequest: SignUpUserRequest, schoolName: String) in
            let reactor = resolver.resolve(SignUpGradeViewReactor.self, arguments: accountRequest, schoolName)!
            return SignUpGradeViewController(reactor: reactor)
        }

    }
}

/// SignUpClass DIContainer
struct SignUpClassPresentationAssembly: Assembly {
    func assemble(container: Container) {

        container.register(SignUpClassViewReactor.self) {(resolver, accountRequest: SignUpUserRequest, schoolName: String) in
            return SignUpClassViewReactor(accountRequest: accountRequest, schoolName: schoolName)
        }

        container.register(SignUpClassViewController.self) { (resolver, argument: SignUpUserRequest, schollName: String) in
            let reactor = resolver.resolve(SignUpClassViewReactor.self, arguments: argument, schollName)!
            return SignUpClassViewController(reactor: reactor)
        }

    }
}


/// SignUpGender DIContainer
struct SignUpGenderPresentationAssembly: Assembly {
    func assemble(container: Container) {

        container.register(SignUpGenderViewReactor.self) { (resolver, accountRequest: SignUpUserRequest, schoolName: String) in
            return SignUpGenderViewReactor(accountRequest: accountRequest, schoolName: schoolName)
        }

        container.register(SignUpGenderViewController.self) { (resolver, argument: SignUpUserRequest , schoolName: String) in
            let reactor = resolver.resolve(SignUpGenderViewReactor.self, arguments: argument, schoolName)!
            return SignUpGenderViewController(reactor: reactor)
        }

    }
}

/// SignUpName DIContainer
struct SignUpNamePresentationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(SignUpNameViewReactor.self) { (resolver, accountRequest: SignUpUserRequest, schoolName: String) in
            let createCheckProfanityUseCase = resolver.resolve(CreateCheckProfanityUseCaseProtocol.self)!
            return SignUpNameViewReactor(createCheckProfanityUseCase: createCheckProfanityUseCase, accountRequest: accountRequest, schoolName: schoolName)
        }

        container.register(SignUpNameViewController.self) { (resolver, argument: SignUpUserRequest, schoolName: String) in
            let reactor = resolver.resolve(SignUpNameViewReactor.self, arguments: argument, schoolName)!
            return SignUpNameViewController(reactor: reactor)
        }

    }
}


/// SignUpResult DIContainer
struct SignUpResultPresentationAssembly: Assembly {
    func assemble(container: Container) {
        
        container.register(SignUpInfoBottomSheetViewReactor.self) { (_, accountRequest: SignUpUserRequest, schoolName: String, profileImage: Data?) in
            
            return SignUpInfoBottomSheetViewReactor(accountRequest: accountRequest, schoolName: schoolName, profileImage: profileImage)
        }
        
        container.register(SignUpInfoBottomSheetViewController.self) { (resolver, argument: SignUpUserRequest, schoolName: String, profileImage: Data?) in
            let reactor = resolver.resolve(SignUpInfoBottomSheetViewReactor.self, arguments: argument, schoolName, profileImage)!
            
            return SignUpInfoBottomSheetViewController(reactor: reactor)
        }

        container.register(PolicyAgreementBottomSheetViewReactor.self) { _ in
            return PolicyAgreementBottomSheetViewReactor()
        }
        
        container.register(PolicyAgreementBottomSheetViewController.self) { resolver in
            let reactor = resolver.resolve(PolicyAgreementBottomSheetViewReactor.self)!
            
            return PolicyAgreementBottomSheetViewController(reactor: reactor)
        }
        
        container.register(SignUpResultViewReactor.self) { (resolver, accountRequest: SignUpUserRequest, schoolName: String, profileImage: Data?) in
            return SignUpResultViewReactor(accountRequest: accountRequest, schoolName: schoolName, profileImage: profileImage)
        }
        
        container.register(SignUpResultViewController.self) { (resolver, argument: SignUpUserRequest, schoolName: String, profileImage: Data?) in
            let reactor = resolver.resolve(SignUpResultViewReactor.self, arguments: argument, schoolName, profileImage)!
            return SignUpResultViewController(reactor: reactor)
        }

    }
}

/// SignUpComplete DIContainer
struct SignUpCompletePresentationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(SignUpCompleteViewReactor.self) { (resolver, accountRequest: SignUpUserRequest) in
            let createAccountUseCase = resolver.resolve(SignUpUserUseCaseProtocol.self)!
            return SignUpCompleteViewReactor(signUpUseCase: createAccountUseCase, accountRequest: accountRequest)
        }
        
        container.register(SignUpCompleteViewController.self) { (resolver, accountRequest: SignUpUserRequest) in
            let reactor = resolver.resolve(SignUpCompleteViewReactor.self, argument: accountRequest)!
            return SignUpCompleteViewController(reactor: reactor)
        }
        
        container.register(SignUpIntroduceViewReactor.self) { (resolver, accountRequest: SignUpUserRequest, schoolName: String) in
            let createPresignedURLUseCase = resolver.resolve(CreatePresigendURLUseCaseProtocol.self)!
            let createCheckProfanityUseCase = resolver.resolve(CreateCheckProfanityUseCaseProtocol.self)!
            let updateUserProfileUploadUseCase = resolver.resolve(UpdateUserProfileUploadUseCaseProtocol.self)!
            return SignUpIntroduceViewReactor(
                accountReqeust: accountRequest,
                createCheckProfanityUseCase: createCheckProfanityUseCase,
                createPresignedURLUseCase: createPresignedURLUseCase,
                updateUserProfileUploadUseCaseProtocol: updateUserProfileUploadUseCase,
                schoolName: schoolName
            )
        }
        
        container.register(SignUpIntroduceViewController.self) { (resolver, accountRequest: SignUpUserRequest, schoolName: String) in
            let reactor = resolver.resolve(SignUpIntroduceViewReactor.self, arguments: accountRequest, schoolName)!
            
            return SignUpIntroduceViewController(reactor: reactor)
        }
    }
}
