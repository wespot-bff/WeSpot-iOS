//
//  MessageRepository.swift
//  MessageService
//
//  Created by eunseou on 8/8/24.
//

import Foundation
import Networking
import MessageDomain
import Util
import Extensions

import RxSwift
import RxCocoa

public final class messageRepository: MessageRepositoryProtocol {
    public func sendMessage(query: SendMessageRequest) -> RxSwift.Single<SendMessageResponseEntity> {
        let query = SendMessageRequestDTO(content: query.content,
                                          receiverId: query.reciverId,
                                          senderName: query.senderName,
                                          isAnonymous: query.isAnonymous)
        let endPoint = MessageEndPoint.sendMessage(query)
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .decodeMap(SendMessageResponseDTO.self)
            .map { $0.toDomain() }
            .asSingle()
    }
    
    
    public func checkProfanity(message: String) -> Single<Bool> {
        let query = CheckProfanityRequestDTO(message: message)
        let endPoint = MessageEndPoint.checkProfanity(query)
        
        return networkService.requestWithStatusCode(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .map { response in
                if response.statusCode == 400 {
                    return true
                } else  {
                    return false
                }
            }
            .asSingle()
    }
    
    
    private let networkService: WSNetworkServiceProtocol = WSNetworkService()
    
    public init() { }
    
    
    public func fetchMessagesStatus() -> Single<MessageStatusResponseEntity?> {
        let endPoint = MessageEndPoint.messagesStatus
        
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .decodeMap(MessagesStatusResponseDTO.self)
            .map { $0.toDomain() }
            .asSingle()
    
    }
    
    public func fetchReservedMessages() -> Single<ReservedMessageResponseEntity?> {
        let endPoint = MessageEndPoint.fetchReservedMessages
        
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .decodeMap(ReservedMessageResponseDTO.self)
            .map { $0.toDomain() }
            .asSingle()
    }
    
    public func fetchReceivedMessages(cursorId: Int) -> Single<ReceivedMessageResponseEntity?> {
        let query = MessageRequest(type: .received, cursorId: cursorId)
        let endPoint = MessageEndPoint.fetchMessages(query)
        
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .decodeMap(ReceievedMessageResponseDTO.self)
            .map { $0.toDomain() }
            .asSingle()
    }
    
    public func fetchStudentSearchResult(query: SearchStudentRequest) -> Single<StudentListResponseEntity?> {
        let query = SearchStudentRequestDTO(name: query.name,
                                            cursorId: query.cursorId)
        let endPoint = MessageEndPoint.searchStudent(query)
        
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .decodeMap(StudentListResponseDTO.self)
            .map {$0.toDomain()}
            .asSingle()
    }
    
    
}
