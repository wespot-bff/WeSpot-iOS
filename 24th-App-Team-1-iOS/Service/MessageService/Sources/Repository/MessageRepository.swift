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
    
    
    public func messageNoti(status: Bool) -> RxSwift.Single<Bool> {
        let query = MessageStatusToggleRequestDTO(isEnableMessage: status)
        let endPoint = MessageEndPoint.messageEnable(query)
        return networkService.requestWithStatusCode(endPoint: endPoint)
            .flatMap { response -> Single<Bool> in
                if response.statusCode == 204 {
                    return Single.just(true)
                } else  {
                    return Single.just(false)
                }
            }
    }
    
    public func fetchBlockMessgeList() async throws -> [MessageRoomEntity] {
        let endPoint = MessageEndPoint.fetchBlockMessageList
        let data = try await networkService.requestAsync(endPoint: endPoint)
        let dtoList = try JSONDecoder().decode([MessageRoomDTO].self, from: data)
        return dtoList.map { $0.toDomain() }
    }
    
    public func fetchDetailMessage(messageId: Int) -> RxSwift.Single<MessageRoomDetailEntity> {
        let endPoint = MessageEndPoint.detailMessage(messageId)
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .decodeMap(DetailMessageResponseDTO.self)
            .map { $0.toDomain() }
            .asSingle()
    }
    
    public func bookMarkMessage(messageId: Int) -> RxSwift.Single<Bool> {
        let endPoint = MessageEndPoint.bookMark(messageId)
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .map { _ in true }
            .asSingle()
    }
    
    public func fetchAnonymousProfileList(receiverId: Int) async throws -> [AnonymousProfileEntity] {
        let endPoint = MessageEndPoint.fetchAnonymousProfileList(receiverId)
        let data = try await networkService.requestAsync(endPoint: endPoint)
        let dtoList = try JSONDecoder().decode([AnonymousProfileListDTO].self, from: data)
        return dtoList.map { $0.toDomain() }
    }
    
    public func blockMessage(messageId: Int) -> RxSwift.Single<Bool> {
        let endPoint = MessageEndPoint.blockMessage(messageId)
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .map { _ in true }
            .asSingle()
    }
    
    public func readMessage(messageId: Int) -> RxSwift.Single<Bool> {
        let endPoint = MessageEndPoint.bookMark(messageId)
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .map { _ in true }
            .asSingle()
    }
    
    public func deleteMessage(messageId: Int) -> RxSwift.Single<Bool> {
        let endPoint = MessageEndPoint.deleteMessage(messageId)
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .map { _ in true }
            .asSingle()
    }
    
    public func getMessage() -> Single<[MessageRoomEntity]> {
        let endPoint = MessageEndPoint.getMessageRoomList

        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .decodeMap([MessageRoomDTO].self)
            .map { dtoArray in
                dtoArray.map { $0.toDomain() }
            }
            .asSingle()
    }
    
    public func sendMessage(query: SendMessageRequest) -> RxSwift.Single<Bool> {
        let query = SendMessageRequestDTO(content: query.content, receiverId: query.reciverId,
                                          anonymousProfileName: query.anonymousProfileName, isAnonymous: query.isAnonymous, anonymousImageUrl: query.anonymousImageUrl)
        let endPoint = MessageEndPoint.sendMessage(query)
        return networkService.requestWithStatusCode(endPoint: endPoint)
            .flatMap { response -> Single<Bool> in
                if response.statusCode == 201 {
                    return Single.just(true)
                } else  {
                    return Single.just(false)
                }
            }
    }
    
    public func replyMessage(id: Int, content: String) -> RxSwift.Single<Bool> {
        let query = ReplyMessageRequestDTO(content: content)
        let endPoint = MessageEndPoint.replyMessage(id, query)
        return networkService.requestWithStatusCode(endPoint: endPoint)
            .flatMap { response -> Single<Bool> in
                if response.statusCode == 201 {
                    return Single.just(true)
                } else  {
                    return Single.just(false)
                }
            }
    }
    
    public func reportMessage(query: ReportMessageRequest) -> Single<Bool> {
        let queryDTO = ReportMessageRequestDTO(targetId: query.targetId, content: query.content, reportType: query.reportType)
        let endPoint = MessageEndPoint.reportMessage(queryDTO)
        return networkService.request(endPoint: endPoint)
            .asObservable()
            .logErrorIfDetected(category: Network.error)
            .map { _ in true }
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
    
    
    public func fetchMessagesStatus() -> Single<MessageStatusResponseEntity> {
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
