//
//  MessageStorageReactor.swift
//  MessageFeature
//
//  Created by eunseou on 7/20/24.
//

import MessageDomain
import Foundation
import Util

import ReactorKit
import RxSwift

public final class MessageStorageReactor: Reactor {
    private let usecase: MessageStorageUseCase

    // MARK: - State
    public struct State {
        var messageCount: Int = 0
        var tabState: MessageButtonTabEnum = .received
        @Pulse var recivedMessageList: [MessageContentModel] = []
        @Pulse var favoriteMessageList: [MessageContentModel] = []
        @Pulse var toastMessage: MessageContentModel?
        @Pulse var messageMode: MessageContentModel?
        // 페이징 관리: 각각 Received와 Sent의 커서 및 추가 데이터 여부
        @Pulse var receivedCursorId: Int = 0
        @Pulse var hasNextReceived: Bool = true
        @Pulse var sentCursorId: Int = 0
        @Pulse var hasNextSent: Bool = true
        @Pulse var disMissBottomSheet: Bool = false
    }

    // MARK: - Action
    public enum Action {
        case loadMessages(type: String)              // 초기 데이터 로드
        case receivedMessageButtonTapped             // 받은 메시지 탭 전환
        case favoriteMessageButtonTapped                 // 즐겨찾기 메시지 탭 전환
        case readMessage(MessageContentModel, tpye: String)        // 메시지 읽기
        case moreButtonTapped(MessageContentModel)   // More 버튼 탭(추가 옵션) 요청
        case loadMoreMessages(type: String)          // 스크롤 하단 도달 시 추가 데이터 로드
        case buttonTapped(MessageContentModel, MessageBottomSheetButtonList)
        case reportMessage(MessageContentModel, String)
    }

    // MARK: - Mutation
    public enum Mutation {
        case setMessageCount(Int)
        case setButtonTabState(MessageButtonTabEnum)
        case setRecievedMessageList([MessageContentModel])
        case appendRecievedMessageList([MessageContentModel])
        case setSentMessageList([MessageContentModel])
        case appendSentMessageList([MessageContentModel])
        case setMessageToast(MessageContentModel)
        case setModeInfoMessage(MessageContentModel)
        case setReadMessage(MessageContentModel, type: String)
        case setFavoriteMessage(MessageContentModel)
        case setDeleteMessage(MessageContentModel)
        case setReportMessage(MessageContentModel)
        case setBlockMessage(MessageContentModel)

        case updateReceivedCursor(Int, Bool)
        case updateSentCursor(Int, Bool)

    }

    public var initialState: State

    public init(usecase: MessageStorageUseCase) {
        self.usecase = usecase
        self.initialState = State()
    }

    // MARK: - Action -> Mutation
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .receivedMessageButtonTapped:
            return Observable.just(.setButtonTabState(.received))
        case .loadMessages(let type):
            // 초기 데이터 로드: 해당 모드의 커서를 기준으로 호출
            return fetchMessageList(type: type, append: false)
        case .favoriteMessageButtonTapped:
            return Observable.just(.setButtonTabState(.favorite))
        case .loadMoreMessages(let type):
            if type == String.MessageTexts.messageRecievedType,
               !currentState.hasNextReceived {
                return Observable.empty()
            } else if type == String.MessageTexts.messageSentType,
                      !currentState.hasNextSent {
                return Observable.empty()
            }
            return fetchMessageList(type: type, append: true)
        case .readMessage(let message, let type):
            return Observable.merge([
                .just(.setMessageToast(message)),
                setReadMessage(message: message, type: type)
            ])
        case .moreButtonTapped(let message):
            return Observable.just(.setModeInfoMessage(message))
            
        case .buttonTapped(let message, let type):
            switch type {
            
            case .block:
                return setBlockMessage(message)
            case .delete:
                return setDeleteMessage(message)
            case .report:
                return .empty()
            }
        case .reportMessage(let message, let reportContent):
            return setReportMessage(message, reportContent)
        }
    }

    // MARK: - Mutation -> State
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setMessageCount(let count):
            newState.messageCount = count
        case .setButtonTabState(let tab):
            newState.tabState = tab
        case .setRecievedMessageList(let messages):
            newState.recivedMessageList = messages
        case .appendRecievedMessageList(let messages):
            newState.recivedMessageList += messages
        case .setSentMessageList(let messages):
            newState.favoriteMessageList = messages
        case .appendSentMessageList(let messages):
            newState.favoriteMessageList += messages
        case .setMessageToast(let message):
            newState.toastMessage = message
        case .setModeInfoMessage(let message):
            newState.messageMode = message
        case .updateReceivedCursor(let newCursor, let hasNext):
            newState.receivedCursorId = newCursor
            newState.hasNextReceived = hasNext
        case .updateSentCursor(let newCursor, let hasNext):
            newState.sentCursorId = newCursor
            newState.hasNextSent = hasNext
        case .setReadMessage(let updatedMessage, let type):
            if type == String.MessageTexts.messageRecievedType {
                newState.recivedMessageList = upadateReadMessages(
                    in: newState.recivedMessageList,
                    with: updatedMessage
                )
            } else if type == String.MessageTexts.messageSentType {
                newState.favoriteMessageList = upadateReadMessages(
                    in: newState.favoriteMessageList,
                    with: updatedMessage
                )
            }
        case .setDeleteMessage(let deleteMessage):
            if currentState.tabState == .received {
                newState.recivedMessageList = updateDeleteMessage(in: state.recivedMessageList,
                                                                  with: deleteMessage)
            }
            else {
                newState.favoriteMessageList = updateDeleteMessage(in: state.favoriteMessageList,
                                                                        with: deleteMessage)
            }
            newState.disMissBottomSheet = true
        case .setReportMessage(let reportMessage):
            if currentState.tabState == .received {
                newState.recivedMessageList = updateDeleteMessage(in: state.recivedMessageList,
                                                                  with: reportMessage)
            }
            else {
                newState.favoriteMessageList = updateDeleteMessage(in: state.favoriteMessageList,
                                                                        with: reportMessage)
            }
            newState.disMissBottomSheet = true
        case .setBlockMessage(let blockMessage):
            if currentState.tabState == .received {
                newState.recivedMessageList = updateDeleteMessage(in: state.recivedMessageList,
                                                                  with: blockMessage)
            }
            else {
                newState.favoriteMessageList = updateDeleteMessage(in: state.favoriteMessageList,
                                                                        with: blockMessage)
            }
            newState.disMissBottomSheet = true
        case .setFavoriteMessage(let message):
            if currentState.tabState == .received {
                newState.recivedMessageList = updateDeleteMessage(in: state.recivedMessageList,
                                                                  with: message)
            }
            else {
                newState.favoriteMessageList = updateDeleteMessage(in: state.favoriteMessageList,
                                                                        with: message)
            }

        }
        return newState
    }
}

// MARK: - Mutation Method

extension MessageStorageReactor {
    /// API 호출 및 페이징 처리를 담당하는 함수입니다.
    /// - Parameters:
    ///   - type: "RECEIVED" 또는 "SENT"
    ///   - append: 기존 목록에 추가할지 여부 (초기 로드이면 false, 페이징이면 true)
    /// - Returns: 목록 갱신과 커서 업데이트 Mutation을 merge하여 반환합니다.
    private func fetchMessageList(type: String, append: Bool = false) -> Observable<Mutation> {
        // 사용 모드에 따라 현재 커서를 결정
        let currentCursor: Int = (type == "RECEIVED") ? currentState.receivedCursorId : currentState.sentCursorId
        let query = GetMessageRequest(cursorId: currentCursor, type: type)
        
        return usecase.getMessage(query: query)
            .asObservable()
            .flatMap { response -> Observable<Mutation> in
                // API 응답을 모델 배열로 매핑
                let messages = self.mapToMessageContentModel(response.messages)
                // 새로운 커서와 hasNext는 API 응답에서 받음
                let newCursor = response.lastCursorId
                let hasNext = response.hasNext
                
                // 선택한 모드에 따라 목록 Mutation 결정
                let listMutation: Observable<Mutation> = {
                    if type == "RECEIVED" {
                        return append ?
                            Observable.just(.appendRecievedMessageList(messages)) :
                            Observable.just(.setRecievedMessageList(messages))
                    } else {
                        return append ?
                            Observable.just(.appendSentMessageList(messages)) :
                            Observable.just(.setSentMessageList(messages))
                    }
                }()
                
                // Received와 Sent 각각의 커서를 업데이트하는 Mutation 생성
                let cursorMutation: Observable<Mutation> = {
                    if type == "RECEIVED" {
                        return Observable.just(.updateReceivedCursor(newCursor, hasNext))
                    } else {
                        return Observable.just(.updateSentCursor(newCursor, hasNext))
                    }
                }()
                
                // 두 Mutation을 merge하여 동시에 발행
                return Observable.merge(listMutation, cursorMutation)
            }
            .catch { error in
                print("❌ Error: \(error.localizedDescription)")
                return Observable.empty()
            }
    }
    
    private func setReadMessage(message: MessageContentModel,
                                type: String) -> Observable<Mutation> {
        return usecase.readMessage(messageId: message.messageId)
            .asObservable()
            .flatMap {  _ in
                return Observable.just(Mutation.setReadMessage(message,
                                                               type: type))
            }
    }
    
    private func setDeleteMessage(_ message: MessageContentModel) -> Observable<Mutation> {
        return usecase.deleteMessage(messageId: message.messageId)
            .asObservable()
            .flatMap {  _ in
                return Observable.just(Mutation.setDeleteMessage(message))
            }
    }
    
    private func setReportMessage(_ message: MessageContentModel, _ content: String) -> Observable<Mutation> {
        return usecase.reportMessage(messageId: message.messageId,
                                     content: content)
            .asObservable()
            .flatMap {  _ in
                return Observable.just(Mutation.setReportMessage(message))
            }
    }
    
    private func setBlockMessage(_ message: MessageContentModel) -> Observable<Mutation> {
        return usecase.blockMessage(messageId: message.messageId)
            .asObservable()
            .flatMap {  _ in
                return Observable.just(Mutation.setBlockMessage(message))
            }
    }
}
    
    //MARK: - Reduce Method

extension MessageStorageReactor {
    
    private func updateDeleteMessage(in messages: [MessageContentModel],
                                     with updatedMessage: MessageContentModel) -> [MessageContentModel] {
        // 1. 기존 메시지 배열의 인덱스를 Dictionary로 매핑 (O(n))
        var indexDict: [Int: Int] = [:]
        for (index, message) in messages.enumerated() {
            indexDict[message.messageId] = index
        }
        // 2. 업데이트할 메시지의 인덱스를 O(1)로 조회
        if let index = indexDict[updatedMessage.messageId] {
            var newMessages = messages
            // 해당 인덱스의 요소를 삭제
            newMessages.remove(at: index)
            return newMessages
        } else {
            // 삭제할 메시지가 없으면 원본 배열 그대로 반환
            return messages
        }
    }
    
    private func upadateReadMessages(in messages: [MessageContentModel],
                                with updatedMessage: MessageContentModel) -> [MessageContentModel] {
        // messageId를 key, index를 value로 하는 Dictionary 생성 (한 번에 O(n))
        var indexDict: [Int: Int] = [:]
        for (index, message) in messages.enumerated() {
            indexDict[message.messageId] = index
        }
        // 업데이트할 메시지의 인덱스를 O(1) 조회
        if let index = indexDict[updatedMessage.messageId] {
            var newMessages = messages
            // 만약 이미 읽음이라면 그대로, 아니면 읽음(true)로 업데이트
            var messageToUpdate = newMessages[index]
            if !messageToUpdate.isRead {
                messageToUpdate.isRead = true
                newMessages[index] = messageToUpdate
            }
            return newMessages
        } else {
            // 해당 메시지가 없으면 원본 배열 그대로 반환
            return messages
        }
    }
}

    // MARK: - Helper Method

extension MessageStorageReactor {
    /// 메시지 엔티티를 MessageContentModel로 매핑하는 함수입니다.
    private func mapToMessageContentModel(_ messages: [ReceivedMessageEntity]) -> [MessageContentModel] {
        return messages.map { message in
            let studentInfo = "\(message.receiver.schoolName)\n\(message.receiver.grade)학년 \(message.receiver.classNumber)반"
            let date = convertDate(message.receivedAt)
            return MessageContentModel(
                studentInfo: studentInfo,
                date: date,
                isRead: message.isRead,
                isBlocked: message.isBlocked,
                isReported: message.isReported,
                content: message.content,
                senderName: message.senderName,
                reciverName: message.receiver.name,
                messageId: message.id
            )
        }
    }
    
    /// API의 날짜 문자열을 "yyyy. MM. dd" 형식으로 변환합니다.
    private func convertDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = inputFormatter.date(from: dateString) else {
            return dateString
        }
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy. MM. dd"
        return outputFormatter.string(from: date)
    }
    
    private func readMessage(_ message: MessageContentModel, _ type: String) -> Observable<Mutation> {
        return Observable.just(.setReadMessage(message, type: type))
    }
    
    private func pushToReportMessage(message: MessageContentModel) {
        
    }
}
