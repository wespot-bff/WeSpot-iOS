//
//  MessageRepositoryProtocol.swift
//  MessageDomain
//
//  Created by eunseou on 8/8/24.
//

import Foundation

import RxSwift

public protocol MessageRepositoryProtocol {
    func fetchMessagesStatus() -> Single<MessageStatusResponseEntity>
    func fetchReservedMessages() -> Single<ReservedMessageResponseEntity?>
    func fetchReceivedMessages(cursorId: Int) -> Single<ReceivedMessageResponseEntity?>
    func fetchStudentSearchResult(query: SearchStudentRequest) -> Single<StudentListResponseEntity?>
    func checkProfanity(message: String) -> Single<Bool>
    func sendMessage(query: SendMessageRequest) -> RxSwift.Single<SendMessageResponseEntity>
    func getMessage(query: GetMessageRequest) -> Single<ReceivedMessageResponseEntity>
    func readMessage(messageId: Int) -> Single<Bool>
    func deleteMessage(messageId: Int) -> Single<Bool>
    func reportMessage(query: ReportMessageRequest) -> Single<Bool>
    func blockMessage(messageId: Int) -> RxSwift.Single<Bool>
}
