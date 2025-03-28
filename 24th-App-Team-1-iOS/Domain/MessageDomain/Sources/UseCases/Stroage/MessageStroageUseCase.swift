//
//  MessageStroageUseCase.swift
//  MessageDomain
//
//  Created by 최지철 on 1/13/25.
//

import RxSwift

public protocol MessageStorageUseCase {
    func getMessage(query: GetMessageRequest) -> Single<ReceivedMessageResponseEntity>
    func readMessage(messageId: Int) -> Single<Bool>
    func deleteMessage(messageId: Int) -> Single<Bool>
    func reportMessage(messageId: Int, content: String) -> Single<Bool>
    func blockMessage(messageId: Int) -> Single<Bool>
}
public final class MessageStorageUseCaseImpl: MessageStorageUseCase {
    

    private let repository: MessageRepositoryProtocol
    
    public init(repository: MessageRepositoryProtocol) {
        self.repository = repository
    }
    
    public func getMessage(query: GetMessageRequest) -> Single<ReceivedMessageResponseEntity> {
        return repository.getMessage(query: query)
    }
    
    public func readMessage(messageId: Int) -> RxSwift.Single<Bool> {
        return repository.readMessage(messageId: messageId)
    }
    
    public func deleteMessage(messageId: Int) -> RxSwift.Single<Bool> {
        return repository.deleteMessage(messageId: messageId)
    }
    
    public func reportMessage(messageId: Int, content: String) -> Single<Bool>{
        let query = ReportMessageRequest(targetId: messageId,
                                         content: content,
                                         reportType: "MESSAGE")
        return repository.reportMessage(query: query)
    }
    
    public func blockMessage(messageId: Int) -> RxSwift.Single<Bool> {
        return repository.blockMessage(messageId: messageId)
    }
}
