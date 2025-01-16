//
//  WriteMessageUseCase.swift
//  MessageDomain
//
//  Created by 최지철 on 1/6/25.
//

import RxSwift

public protocol WriteMessageUseCase {
    func checkProfanity(message: String) -> Single<Bool>
    func sendMessage(content: String, receiverId: Int, senderName: String, isAnonymous: Bool) -> Single<SendMessageResponseEntity>
}
public final class WriteMessageUseCaseImpl: WriteMessageUseCase {
    
    public func sendMessage(content: String, receiverId: Int, senderName: String, isAnonymous: Bool) -> RxSwift.Single<SendMessageResponseEntity> {
        let query = SendMessageRequest(content: content, reciverId: receiverId, senderName: senderName, isAnonymous: isAnonymous)
        return repository.sendMessage(query: query)
    }
    
    public func checkProfanity(message: String) -> RxSwift.Single<Bool> {
        return repository.checkProfanity(message: message)
    }
    
    
    private let repository: MessageRepositoryProtocol
    
    public init(repository: MessageRepositoryProtocol) {
        self.repository = repository
    }
}
