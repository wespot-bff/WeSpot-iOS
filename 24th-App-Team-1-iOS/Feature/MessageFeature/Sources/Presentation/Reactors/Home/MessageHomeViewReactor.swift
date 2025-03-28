//
//  MessageHomeViewReactor.swift
//  MessageFeature
//
//  Created by eunseou on 7/20/24.
//

import Foundation
import MessageDomain
import Extensions
import Util

import ReactorKit

public final class MessageHomeViewReactor: Reactor {
    
    // MARK: - UseCase
    
    private let fetchMessagesStatusUseCase: FetchMessagesStatusUseCaseProtocol
    private let fetchReservedMessageUseCase: FetchReservedMessageUseCaseProtocol
    
    // MARK: - Timer Task (Swift Concurrency)
    
    private var timerTask: Task<Void, Never>?
    
    // MARK: - Reactor Properties
    
    public var initialState: State
    
    public struct State {
        @Pulse var reservedMessages: Int?
        @Pulse var isSendAllowed: Bool?
        @Pulse var recievedMessages: Bool?
        @Pulse var messageAvailability: MessageHomeTimeStateEntity = MessageHomeTimeStateEntity(messageAvailabilityTime: .waitTime)
        var remainingTime: String?
        var haveMessage: Bool = false
    }
    
    public enum Action {
        case viewWillAppear
        case viewDisappeared
        case checkCurrentTime
        case sendButtonTapped
    }
    
    public enum Mutation {
        case setReservedMessagesCount(Int)
        case isSendAllowedState(Bool)
        case setRecievedMessagesBool(Bool)
        case setMessageAvailability(MessageHomeTimeStateEntity)
        case setRemainingSeconds(String?)
        case checkHaveMessage(Bool)
    }
    
    // MARK: - Init

    public init(
        fetchMessagesStatusUseCase: FetchMessagesStatusUseCaseProtocol,
        fetchReservedMessageUseCase: FetchReservedMessageUseCaseProtocol
    ) {
        self.fetchMessagesStatusUseCase = fetchMessagesStatusUseCase
        self.fetchReservedMessageUseCase = fetchReservedMessageUseCase
        self.initialState = State()
    }
    
    deinit {
        stopTimer()
    }
}

// MARK: - Reactor

extension MessageHomeViewReactor {
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewWillAppear:
            startTimer()
            // 최초 진입 시 서버 데이터 로드
            return Observable.merge(
                fetchMessagesStatus(),
                fetchReservedMessages()
            )
            
        case .checkCurrentTime:
            return checkCurrentTimeAndUpdateState()
        case .sendButtonTapped:
            NotificationCenter.default.post(name: .showMessageWriteViewController, object: nil)
            return .empty()
        case .viewDisappeared:
            stopTimer()
            return .empty()
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .setReservedMessagesCount(let count):
            newState.reservedMessages = count
            
        case .setRecievedMessagesBool(let hasMessages):
            newState.recievedMessages = hasMessages
            
        case .isSendAllowedState(let isAllowed):
            newState.isSendAllowed = isAllowed
            
        case .setMessageAvailability(let availabilityState):
            newState.messageAvailability = availabilityState
        case .setRemainingSeconds(let time):
            newState.remainingTime = time
        case .checkHaveMessage(let state):
            newState.haveMessage = state
        }
        
        return newState
    }
}

// MARK: - Timer

extension MessageHomeViewReactor {
    /// Task 기반 1초 타이머
    private func startTimer() {
        stopTimer() // 기존 Task가 있으면 중단
        timerTask = Task {
            while !Task.isCancelled {
                // 1초마다 checkCurrentTime 액션 트리거
                action.onNext(.checkCurrentTime)
                
                // 1초 대기
                try? await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }
    
    private func stopTimer() {
        timerTask?.cancel()
        timerTask = nil
    }
}

// MARK: - Mutation Logic

extension MessageHomeViewReactor {
    /// 시간 체크 후 Mutation 반환
    private func checkCurrentTimeAndUpdateState() -> Observable<Mutation> {
        let currentDate = Date()
        let currentHour = Calendar.current.component(.hour, from: currentDate)
        let messageAvailabilityTime = determineTimeState(for: currentHour)
        let messageAvailability = MessageHomeTimeStateEntity(messageAvailabilityTime: messageAvailabilityTime)
        // 남은 시간 계산
        let remainingTime = calculateRemainingTime(currentDate: currentDate, timeState: messageAvailabilityTime)

        
        // **주의**: Concurrency 기반으로 1초마다 갱신 중이므로
        // checkCurrentTimeAndUpdateState() 내에서 `startTimer()`는 더 이상 호출하지 않습니다.
        
        return Observable.concat([
            .just(.setMessageAvailability(messageAvailability)),
            .just(.setRemainingSeconds(remainingTime))
        ])
    }
    
    /// 예약된 메시지 정보 불러오기
    private func fetchMessagesStatus() -> Observable<Mutation> {
        return fetchMessagesStatusUseCase
            .execute()
            .asObservable()
            .flatMap { entity -> Observable<Mutation> in
                guard let entity else {
                    return .just(.setReservedMessagesCount(0)) 
                }
                let messageCountState = entity.countUnReadMessages > 0
                return Observable.concat(
                    .just(.checkHaveMessage(messageCountState)),
                    .just(.setReservedMessagesCount(entity.remainingMessages)),
                    .just(.isSendAllowedState(entity.isSendAllowed))
                )
            }
    }
    
    /// 받은 메시지 정보 불러오기
    private func fetchReservedMessages() -> Observable<Mutation> {
        return fetchReservedMessageUseCase
            .execute()
            .asObservable()
            .flatMap { entity -> Observable<Mutation> in
                guard let entity else {
                    return .empty()
                }
                let messageCount = entity.messages.count
     
                return .just(.setReservedMessagesCount(messageCount))
            }
    }
}

// MARK: - Helper Methods

extension MessageHomeViewReactor {
    /// 시간 체크
    private func determineTimeState(for hour: Int) -> MessageHomeTimeStateEntity.PostableTimeState {
        switch hour {
        case 0..<17:
            return .postableTime       // 00:00 ~ 17:00
        case 17..<22:
            return .postableTime   // 17:00 ~ 22:00
        case 22..<24:
            return .postableTime        // 22:00 ~ 24:00
        default:
            return .waitTime
        }
    }
    
    /// 남은 시간 계산
    private func calculateRemainingTime(
        currentDate: Date,
        timeState: MessageHomeTimeStateEntity.PostableTimeState
    ) -> String? {
        switch timeState {
        case .postableTime:
            var components = Calendar.current.dateComponents([.year, .month, .day], from: currentDate)
            components.hour = 22
            components.minute = 0
            components.second = 0
            guard let endDate = Calendar.current.date(from: components) else { return nil }
            
            let remainingSeconds = Int(endDate.timeIntervalSince(currentDate))
            return formatSeconds(remainingSeconds)
        default:
          return "00:00:00"
        }
    }
    
    /// 오늘 받은 메시지인지 체크
    private func isReceivedMessageToday(_ receivedAt: String) -> Bool {
        guard let receivedDate = DateFormatter.iso8601().date(from: receivedAt) else {
            return false
        }
        return receivedDate.isSameDay(as: Date())
    }
    
    /// 초 -> HH:mm:ss 포맷 변환
    private func formatSeconds(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
