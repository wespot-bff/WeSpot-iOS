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
import UIKit

public final class MessageStorageReactor: Reactor {
    private let usecase: MessageStorageUseCase
    private let router: MessageStorageRouting

    // MARK: - State
    public struct State {
        var messageCount: Int = 0
        var tabState: MessageButtonTabEnum = .received
        @Pulse var roomList: [MessageRoomEntity] = []
        @Pulse var favoriteMessageList: [MessageRoomEntity] = []
        @Pulse var toastMessage: MessageRoomEntity?
        @Pulse var messageMode: MessageRoomEntity? // More 버튼 탭 시 표시할 메시지 정보

        @Pulse var receivedCursorId: Int = 0
        @Pulse var hasNextReceived: Bool = true
        @Pulse var sentCursorId: Int = 0
        @Pulse var hasNextSent: Bool = true
        @Pulse var disMissBottomSheet: Bool = false
        @Pulse var anonymousProfileStatus: AnonymousProfileStatusEnum = .oneOrNone
        
        @Pulse var bottomSheetButtonList: [MessageBottomSheetButtonList] = []
    }

    // MARK: - Action
    public enum Action {
        case goToMessageRoom(MessageRoomEntity, UIViewController)             // 초기 데이터 로드
        case receivedMessageButtonTapped            // 받은 메시지 탭 전환
        case favoriteMessageButtonTapped                  // 즐겨찾기 메시지 탭 전환
        case moreButtonTapped(MessageRoomEntity, Bool)    // More 버튼 탭(추가 옵션) 요청
        case loadMessagesRoom       // 스크롤 하단 도달 시 추가 데이터 로드
        case buttonTapped(MessageRoomEntity, MessageBottomSheetButtonList)
        case bookMarked(MessageRoomEntity) // 즐겨찾기 추가 (서버 연동)
        case blockMessage(MessageRoomEntity)
        case unBookMarked(MessageRoomEntity) // 즐겨찾기 해제 (로컬에서만 처리)
        case unBlockMessage(MessageRoomEntity)
        case setBottomSheetButtonList(MessageRoomEntity)
        
    }

    // MARK: - Mutation
    public enum Mutation {
        case setMessageCount(Int)
        case setButtonTabState(MessageButtonTabEnum)
        case fetchMessageRoomList([MessageRoomEntity]) // 받은 메시지 목록
        case setBookMarkMessageList([MessageRoomEntity]) // 보낸 메시지 목록 (현재 favoriteMessageList로 사용되는 듯함)
        case appendSentMessageList([MessageRoomEntity]) // 보낸 메시지 목록 추가
        case setMessageToast(MessageRoomEntity)
        case setModeInfoMessage(MessageRoomEntity)
        case updateReceivedCursor(Int, Bool)
        case updateSentCursor(Int, Bool)
        case setBlockMessage(MessageRoomEntity)
        case setBookMarkMessage(MessageRoomEntity, Bool) // isBookMark 상태를 포함
        case setUnBlockMessage(MessageRoomEntity) // 차단 해제 뮤테이션
        case updateBottomSheetButtonList([MessageBottomSheetButtonList])
        case setDetaillRoom(MessageRoomDetailEntity, MessageRoomEntity, UIViewController) // 상세 메시지 방 정보 설정
    }

    public var initialState: State

    public init(usecase: MessageStorageUseCase, router: MessageStorageRouting) {
        self.usecase = usecase
        self.router = router
        self.initialState = State()
    }

    // MARK: - Action -> Mutation
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .receivedMessageButtonTapped:
            return Observable.just(.setButtonTabState(.received))
        case .loadMessagesRoom:
            // 초기 데이터 로드: 해당 모드의 커서를 기준으로 호출
            return fetchMessageList()
        case .favoriteMessageButtonTapped:
            return Observable.just(.setButtonTabState(.favorite))

        case .moreButtonTapped(let message, _): // all 파라미터는 현재 사용되지 않으므로 제거 가능
            return Observable.just(.setModeInfoMessage(message))
            
        case .buttonTapped(let message, let type):
            // showAlert에서 넘어온 buttonTapped 액션 처리 (필요시 추가 로직)
            switch type {
            case .block: return setBlockMessage(message) // 차단하기
            case .favorite: return bookMarkMessage(message, true) // 즐겨찾기 해제 (이미 즐겨찾기됨)
            case .unFavorite: return bookMarkMessage(message, false) // 즐겨찾기 (즐겨찾기 안됨)
            }
            
        case .goToMessageRoom(let room, let vc):
            
            return usecase.getDetailMessage(messageId: room.id)
                .asObservable()
                .flatMap { detailRoom in
                    return Observable.just(Mutation.setDetaillRoom(detailRoom, room, vc))
                }
            
        case .bookMarked(let message): // 서버에 즐겨찾기 요청
            let updatedMessage = MessageRoomEntity(
                id: message.id,
                senderProfile: message.senderProfile,
                isMeMessageRoomOwner: message.isMeMessageRoomOwner,
                isExistsUnreadMessage: message.isExistsUnreadMessage,
                latestChatTime: message.latestChatTime,
                receiverProfile: message.receiverProfile,
                isBookmarked: true, // <-- 여기서 isBookmarked를 true로 설정
                isBlocked: message.isBlocked,
                isEver: message.isEver
            )
            return usecase.bookMark(messageId: updatedMessage.id)
                .asObservable()
                .flatMap { _ in
                    // 서버 요청 성공 시, 로컬에서 즐겨찾기 리스트에 추가
                    return Observable.just(Mutation.setBookMarkMessage(updatedMessage, true))
                }
                .catch { error in
                    print("Error bookmarking message: \(error)")
                    // 오류 처리 (예: 토스트 메시지)
                    return .empty()
                }

        case .blockMessage(let message):
            return setBlockMessage(message)

        case .unBookMarked(let message):
            return Observable.just(Mutation.setBookMarkMessage(message, false))
            
        case .unBlockMessage(let message):
            return usecase.blockMessage(messageId: message.id)
                .asObservable()
                .flatMap { _ in
                    return Observable.just(Mutation.setUnBlockMessage(message))
                }
                .catch { error in
                    print("Error unblocking message: \(error)")
                    return .empty()
                }
            
        case .setBottomSheetButtonList(let message):
            // 메시지 상태에 따라 바텀 시트 버튼 목록을 결정
            var buttons: [MessageBottomSheetButtonList] = [.block] // 기본적으로 차단은 포함
            if message.isBookmarked {
                buttons.append(.unFavorite) // 즐겨찾기 되어 있으면 해제 옵션
            } else {
                buttons.append(.favorite) // 즐겨찾기 안 되어 있으면 추가 옵션
            }

            return Observable.just(Mutation.updateBottomSheetButtonList(buttons))
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
        case .fetchMessageRoomList(let messages):
            newState.roomList = messages
        case .setBookMarkMessageList(let messages):
            newState.favoriteMessageList = messages // 현재 보낸 메시지 대신 즐겨찾기로 사용
        case .appendSentMessageList(let messages):
            newState.favoriteMessageList += messages // 현재 보낸 메시지 대신 즐겨찾기로 사용
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
            
        case .setBlockMessage(let blockMessage):
            // 차단된 메시지를 목록에서 제거하는 로직
            if newState.tabState == .received {
                newState.roomList = updateDeleteMessage(in: state.roomList, with: blockMessage)
            } else { // favorite 탭일 경우
                newState.favoriteMessageList = updateDeleteMessage(in: state.favoriteMessageList, with: blockMessage)
            }
            newState.disMissBottomSheet = true
            newState.toastMessage = blockMessage // 차단 완료 토스트 메시지
            
        case let .setBookMarkMessage(message, isBookMark):
            newState.disMissBottomSheet = true // 바텀 시트 닫기
            
            if isBookMark {
                // 즐겨찾기 추가 (이미 목록에 없으면 추가)
                if !newState.favoriteMessageList.contains(where: { $0.id == message.id }) {
                    newState.favoriteMessageList.append(message)
                }
                newState.toastMessage = message // 즐겨찾기 추가 토스트
            } else {
                // 즐겨찾기 해제 (목록에서 제거)
                newState.favoriteMessageList.removeAll { $0.id == message.id }
                newState.toastMessage = message // 즐겨찾기 해제 토스트
            }
            
        case let .setUnBlockMessage(message):
            newState.disMissBottomSheet = true // 바텀 시트 닫기
            // 차단 해제 시 메시지를 다시 목록에 표시하거나, isBlocked 상태를 업데이트 (MessageRoomEntity에 isBlocked 속성이 있다면)
            // 예를 들어, 해당 메시지가 차단 해제되었음을 알리는 토스트 메시지를 띄우거나,
            // isBlocked 상태를 false로 변경하고 해당 메시지를 다시 roomList나 favoriteMessageList에 포함시킬 수 있습니다.
            // 현재 MessageRoomEntity에 isBlocked가 명시적으로 없으므로, ID 기반으로만 처리합니다.
            
            // roomList에서 isBlocked 상태 업데이트 (만약 MessageRoomEntity에 isBlocked가 있다면)
            if let index = newState.roomList.firstIndex(where: { $0.id == message.id }) {
                // var updatedMessage = newState.roomList[index]
                // updatedMessage.isBlocked = false
                // newState.roomList[index] = updatedMessage
            }
            // favoriteMessageList에서 isBlocked 상태 업데이트
            if let index = newState.favoriteMessageList.firstIndex(where: { $0.id == message.id }) {
                // var updatedMessage = newState.favoriteMessageList[index]
                // updatedMessage.isBlocked = false
                // newState.favoriteMessageList[index] = updatedMessage
            }
            newState.toastMessage = message // 차단 해제 토스트 메시지
        case .updateBottomSheetButtonList(let buttonList):
            newState.bottomSheetButtonList = buttonList
        case .setDetaillRoom(let room, let roomInfo, let vc):
            router.goToDetailMessage(room: room, info: roomInfo, vc: vc)
        }
        return newState
    }
}

// MARK: - Mutation Method (Private)

extension MessageStorageReactor {
    /// API 호출 및 페이징 처리를 담당하는 함수입니다.
    /// - Parameters:
    ///   - type: "RECEIVED" 또는 "SENT"
    ///   - append: 기존 목록에 추가할지 여부 (초기 로드이면 false, 페이징이면 true)
    /// - Returns: 목록 갱신과 커서 업데이트 Mutation을 merge하여 반환합니다.
    private func fetchMessageList() -> Observable<Mutation> {
        return usecase.getMessage() // 모든 메시지를 가져오는 API 호출
            .asObservable()
            .flatMap { [weak self] allMessages in
                // MARK: 각 MessageRoomEntity의 latestChatTime을 변환합니다.
                let mappedMessages = allMessages.map { message in
                    let convertedDateString = self?.convertDate(message.latestChatTime)
                    // latestChatTime만 변경된 새로운 MessageRoomEntity 인스턴스 생성
                    return MessageRoomEntity(
                        id: message.id,
                        senderProfile: message.senderProfile,
                        isMeMessageRoomOwner: message.isMeMessageRoomOwner,
                        isExistsUnreadMessage: message.isExistsUnreadMessage,
                        latestChatTime: convertedDateString ?? message.latestChatTime, // 변환된 날짜 문자열 사용
                        receiverProfile: message.receiverProfile,
                        isBookmarked: message.isBookmarked,
                        isBlocked: message.isBlocked,
                        isEver: message.isEver
                    )
                }
                
                // 1. 차단되지 않은 '받은 메시지' 목록 필터링
                let unblockedMessages = mappedMessages.filter { !$0.isBlocked }

                // 2. '즐겨찾기' 메시지 목록 필터링
                // 즐겨찾기된 메시지는 차단 상태와 관계없이 보여줄지,
                // 아니면 '차단되지 않은 메시지' 중에서 즐겨찾기된 메시지만 보여줄지 정책에 따라 달라집니다.
                // 현재는 '차단되지 않은 메시지' 중에서 즐겨찾기된 메시지를 필터링합니다.
                let favoritedMessages = unblockedMessages.filter { $0.isBookmarked }

                // 두 개의 Mutation을 동시에 방출 (concat을 사용하여 순서 보장)
                return Observable.concat([
                    .just(Mutation.fetchMessageRoomList(unblockedMessages)),  // roomList 업데이트 (받은 메시지 탭용)
                    .just(Mutation.setBookMarkMessageList(favoritedMessages)) // favoriteMessageList 업데이트 (즐겨찾기 탭용)
                ])
            }
            .catch { error in
                print("Error fetching messages: \(error)")
                // 에러 발생 시, 두 목록 모두 비어있는 상태로 초기화하는 뮤테이션 방출
                return Observable.concat([
                    .just(Mutation.fetchMessageRoomList([])),
                    .just(Mutation.setBookMarkMessageList([]))
                ])
            }
    }
    
    // bookMarkMessage 메서드 이름 변경 (Action에 bookMarked/unBookMarked가 있으므로)
    // 이 함수는 서버 API를 호출하고 성공 시 로컬 상태를 업데이트하는 용도.
    // unBookMarked 액션은 이 함수를 호출하지 않습니다.
    private func bookMarkMessage(_ message: MessageRoomEntity, _ isBookMark: Bool) -> Observable<Mutation> {
        return usecase.bookMark(messageId: message.id) // bookMark API가 토글 기능을 한다고 가정
            .asObservable()
            .flatMap { _ in
                return Observable.just(Mutation.setBookMarkMessage(message, isBookMark))
            }
            .catch { error in
                print("Error bookmarking message: \(error)")
                return .empty()
            }
    }
    
    private func setBlockMessage(_ message: MessageRoomEntity) -> Observable<Mutation> {
        return usecase.blockMessage(messageId: message.id)
            .asObservable()
            .flatMap { _ in
                return Observable.just(Mutation.setBlockMessage(message))
            }
            .catch { error in
                print("Error blocking message: \(error)")
                return .empty()
            }
    }
}
    
//MARK: - Reduce Method (Private)

extension MessageStorageReactor {
    /// 메시지 목록에서 특정 메시지를 삭제 또는 업데이트합니다.
    /// (로컬에서만 처리되는 경우 활용)
    private func updateDeleteMessage(in messages: [MessageRoomEntity],
                                     with updatedMessage: MessageRoomEntity) -> [MessageRoomEntity] {
        // ID를 기반으로 메시지를 찾아서 제거합니다.
        return messages.filter { $0.id != updatedMessage.id }
    }
}

// MARK: - Helper Method (Private)

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
                messageId: message.id,
                isFavorite: currentState.tabState == .favorite ? true : false // 이 부분은 실제 메시지의 즐겨찾기 상태를 반영해야 합니다.
            )
        }
    }
    
    /// API의 날짜 문자열을 "yyyy. MM. dd" 형식으로 변환합니다.
    private func convertDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        inputFormatter.locale = Locale(identifier: "en_US_POSIX")

        guard let date = inputFormatter.date(from: dateString) else {
            print("Error: Could not parse date string: \(dateString)")
            return dateString // 파싱 실패 시 원본 문자열을 반환
        }

        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy. MM. dd"
        outputFormatter.timeZone = TimeZone.current

        let finalDateString = outputFormatter.string(from: date)
        print("DEBUG: Original Date String: \(dateString)")
        print("DEBUG: Parsed Date: \(date)")
        print("DEBUG: Formatted Date String: \(finalDateString)") // <-- 이 값 확인
        
        return finalDateString
    }
    
    private func pushToReportMessage(message: MessageContentModel) {
        // 이 함수는 사용되지 않으므로 제거하거나 ReporterRouter 같은 것으로 대체하는 것이 좋습니다.
    }
}

