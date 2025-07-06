//
//  MessageMainPresentationAssembly.swift
//  wespot
//
//  Created by eunseou on 8/7/24.
//

import Foundation
import MessageFeature
import MessageDomain
import CommonDomain

import Swinject
import UIKit

struct MessageHomePresentationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MessageHomeViewReactor.self) { resolver in
            let fetchMessagesStatusUseCase = resolver.resolve(FetchMessagesStatusUseCaseProtocol.self)!
            let fetchReservedMessageUseCase = resolver.resolve(FetchReservedMessageUseCaseProtocol.self)!
             
            return MessageHomeViewReactor(fetchMessagesStatusUseCase: fetchMessagesStatusUseCase, fetchReservedMessageUseCase: fetchReservedMessageUseCase)
        }
        
        container.register(MessageHomeViewController.self) { resolver in
            let reactor = resolver.resolve(MessageHomeViewReactor.self)!
            
            return MessageHomeViewController(reactor: reactor)
        }
        
    }
}

struct MessageBottomSheetPresentationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MessageStorageBottomSheetViewController.self) { (resolver: Resolver, message: MessageRoomEntity, isFavorite: Bool, reactor: MessageStorageReactor) in
            return MessageStorageBottomSheetViewController(message: message, isFavorite: isFavorite, reactor: reactor)
        }
    }
}

@available(iOS 16.0, *)
struct AnonymousProfileBottomSheetAssembly: Assembly {
    func assemble(container: Container) {
        // 1) Reactor 등록 (router는 일단 nil)
        container.register(AnonymousProfileReactor.self) { resolver in
            let usecase = resolver.resolve(AnonymousProfileUseCase.self)!
            return AnonymousProfileReactor(usecase: usecase,
                                           router: nil)
        }
        // Reactor 생성 완료 후 Router 주입
        .initCompleted { resolver, reactor in
            reactor.router = resolver.resolve(AnonymousProfileBottomSheetRouting.self)
        }

        // 2) Router 등록
        container.register(AnonymousProfileBottomSheetRouting.self) { resolver in
            let reactor = resolver.resolve(AnonymousProfileReactor.self)!
            return AnonymousProfileBottomSheetRouter(reactor: reactor)
        }
    }
}

struct MessageReportPresentationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MesssageReportViewController.self) { (resolver: Resolver, message: MessageContentModel, reactor: MessageStorageReactor) in
            return MesssageReportViewController(message: message).then {
                $0.reactor = reactor
            }
        }
    }
}

struct MessageStroagePresentationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MessageStorageReactor.self) { resolver in
            let messageStroageUsecase =  resolver.resolve(MessageStorageUseCase.self)!
            let router = MessageStorageRouter()
            return MessageStorageReactor(usecase: messageStroageUsecase, router: router)
        }
        
        container.register(MessageStorageViewController.self) { resolver in
            let reactor = resolver.resolve(MessageStorageReactor.self)!
            return MessageStorageViewController(reactor: reactor)
        }
    }
}

struct MessageWritePresentationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MessageWriteReactor.self) { resolver in
            let fetchSearchResultUseCase = resolver.resolve(FetchStudentSearchResultUseCase.self)!
            let writeMessageUseCase =  resolver.resolve(WriteMessageUseCase.self)!
            let bottomSheetRouter = resolver.resolve(AnonymousProfileBottomSheetRouting.self)!
            let usecase = resolver.resolve(AnonymousProfileUseCase.self)!
            return MessageWriteReactor(fetchSearchResultUseCase: fetchSearchResultUseCase,
                                       bottomSheetRouter: bottomSheetRouter,
                                       anonmousProfileUseCase: usecase,
                                       writeMessageUseCase: writeMessageUseCase)
        }
        
        container.register(MessageWriteViewController.self) { resolver in
            let reactor = resolver.resolve(MessageWriteReactor.self)!
            return MessageWriteViewController(reactor: reactor)
        }
        
        container.register(SearchStudentForMessageWriteViewController.self) { resolver in
            let reactor = resolver.resolve(MessageWriteReactor.self)!
            return SearchStudentForMessageWriteViewController(reactor: reactor)
        }
    }
}

struct MessagePagePresentationAssembly: Assembly {
    func assemble(container: Container) {
        container.register(MessagePageViewReactor.self) { _ in
            return MessagePageViewReactor()
        }
        
        container.register(MessagePageViewController.self) { resolver in
            let reactor = resolver.resolve(MessagePageViewReactor.self)!
            
            return MessagePageViewController(reactor: reactor)
        }
    }
}


struct MessageMainPresentationAssembly: Assembly {
        func assemble(container: Container) {
            container.register(MessageMainViewReactor.self) { resolver in
                return MessageMainViewReactor()
            }
            
            container.register(MessageMainViewController.self) { resovler in
                let reactor = resovler.resolve(MessageMainViewReactor.self)!
                
                return MessageMainViewController(reactor: reactor)
            }
        }
        
}

struct MessageSettingAssembly: Assembly {
    func assemble(container: Container) {
        // MessageSettingReactor 등록 (문제 없어 보임)
        container.register(MessageSettingReactor.self) { resolver in
            let router = MessageSettingRouter()
            let usecase = resolver.resolve(MessageSettingUsecase.self)!


            return MessageSettingReactor(
               usecase: usecase,
               router: router,
               notiUsecase: nil,
               uploadNotiUsecase: nil
            )
        }
        
        // MessageSettingViewController 등록 (문제 없어 보임)
        container.register(MessageSettingViewController.self) { resolver in
            // MessageSettingReactor는 위에서 등록되므로, 여기서 resolve는 이론상 가능해야 합니다.
            let reactor = resolver.resolve(MessageSettingReactor.self)!
            return MessageSettingViewController(reactor: reactor)
        }
    }
}


    
    
