//
//  DataAssembly.swift
//  wespot
//
//  Created by Kim dohyun on 7/23/24.
//

import Foundation
import CommonDomain
import CommonService
import LoginDomain
import LoginService
import VoteDomain
import VoteService
import MessageDomain
import MessageService
import AllDomain
import AllService
import NotificationDomain
import NotificationService

import Networking

import Swinject


struct DataAssembly: Assembly {
    func assemble(container: Container) {
        
        container.register(CommonRepositoryProtocol.self) { _ in
            return CommonRepository()
        }
        
        container.register(VoteRepositoryProtocol.self) { _ in
            return VoteRepository()
        }
        
        container.register(LoginRepositoryProtocol.self) { _ in
            return LoginRepository()
        }
        
        container.register(MessageRepositoryProtocol.self) { _ in
            return messageRepository()
        }
        
        container.register(ProfileRepositoryProtocol.self) { _ in
            return ProfileRepository()
        }
        
        container.register(NotificationRepositoryProtocol.self) { _ in
            return NotificationRepository()
        }
    }
}
