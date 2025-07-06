//
//  MessageRepositoryProtocol.swift
//  MessageDomain
//
//  Created by eunseou on 8/8/24.
//

import RxSwift

public protocol MessageRepositoryProtocol {
    func fetchAnonymousProfileList(receiverId: Int) async throws -> [AnonymousProfileEntity]
    func fetchMessagesStatus() -> Single<MessageStatusResponseEntity>
    func fetchReservedMessages() -> Single<ReservedMessageResponseEntity?>
    func fetchReceivedMessages(cursorId: Int) -> Single<ReceivedMessageResponseEntity?>
    func fetchStudentSearchResult(query: SearchStudentRequest) -> Single<StudentListResponseEntity?>
    func checkProfanity(message: String) -> Single<Bool>
    func sendMessage(query: SendMessageRequest) -> RxSwift.Single<Bool>
    func getMessage() -> Single<[MessageRoomEntity]>
    func deleteMessage(messageId: Int) -> Single<Bool>
    func reportMessage(query: ReportMessageRequest) -> Single<Bool>
    func blockMessage(messageId: Int) -> RxSwift.Single<Bool>
    func bookMarkMessage(messageId: Int) -> Single<Bool>
    func fetchDetailMessage(messageId: Int) -> Single<MessageRoomDetailEntity>
    func replyMessage(id: Int, content: String) -> RxSwift.Single<Bool>
    func fetchBlockMessgeList() async throws -> [MessageRoomEntity]
    func messageNoti(status: Bool) -> Single<Bool>
}
