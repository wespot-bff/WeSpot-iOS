//
//  MessageStroageUseCase.swift
//  MessageDomain
//
//  Created by 최지철 on 1/13/25.
//

import RxSwift

public protocol MessageStorageUseCase {
    func getMessage() -> Single<[MessageRoomEntity]>
    func bookMark(messageId: Int) -> Single<Bool>
    func deleteMessage(messageId: Int) -> Single<Bool>
    func reportMessage(messageId: Int, content: String) -> Single<Bool>
    func blockMessage(messageId: Int) -> Single<Bool>
    func getDetailMessage(messageId: Int) -> Single<MessageRoomDetailEntity>
}
public final class MessageStorageUseCaseImpl: MessageStorageUseCase {
    public func getDetailMessage(messageId: Int) -> RxSwift.Single<MessageRoomDetailEntity> {
        return repository.fetchDetailMessage(messageId: messageId)
    }
    

    private let repository: MessageRepositoryProtocol
    
    public init(repository: MessageRepositoryProtocol) {
        self.repository = repository
    }
    
    public func getMessage() -> Single<[MessageRoomEntity]> {
        return repository.getMessage()
    }
    
    public func deleteMessage(messageId: Int) -> RxSwift.Single<Bool> {
        return repository.deleteMessage(messageId: messageId)
    }
    
    public func bookMark(messageId: Int) -> RxSwift.Single<Bool> {
        return repository.bookMarkMessage(messageId: messageId)
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
