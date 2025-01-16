//
//  MessageRepositoryProtocol.swift
//  MessageDomain
//
//  Created by eunseou on 8/8/24.
//

import Foundation

import RxSwift

public protocol MessageRepositoryProtocol {
    func fetchMessagesStatus() -> Single<MessageStatusResponseEntity?>
    func fetchReservedMessages() -> Single<ReservedMessageResponseEntity?>
    func fetchReceivedMessages(cursorId: Int) -> Single<ReceivedMessageResponseEntity?>
    func fetchStudentSearchResult(query: SearchStudentRequest) -> Single<StudentListResponseEntity?>
    func checkProfanity(message: String) -> Single<Bool>
    func sendMessage(query: SendMessageRequest) -> RxSwift.Single<SendMessageResponseEntity>
}
