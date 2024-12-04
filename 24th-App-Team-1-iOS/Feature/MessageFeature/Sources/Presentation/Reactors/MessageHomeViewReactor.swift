//
//  MessageHomeViewReactor.swift
//  MessageFeature
//
//  Created by eunseou on 7/20/24.
//

import Foundation
import MessageDomain
import Extensions

import ReactorKit

public final class MessageHomeViewReactor: Reactor {
    
    private let fetchMessagesStatusUseCase: FetchMessagesStatusUseCaseProtocol
    private let fetchReceivedMessageUseCase: FetchReceivedMessageUseCaseProtocol
    public var initialState: State
    private var timer: Timer?
    
    //MARK: - Reactor Properties
    
    public struct State {
        @Pulse var reservedMessages: Int?
        @Pulse var isSendAllowed: Bool?
        @Pulse var recievedMessages: Bool?
        var messageAvailability: MessageHomeTimeStateEntity = MessageHomeTimeStateEntity(messageAvailabilityTime: .waitTime)
        var remainingTime: String?
    }
    
    public enum Action {
        case viewDidLoad
        case checkCurrentTime
    }
    
    public enum Mutation {
        case setReservedMessagesCount(Int)
        case isSendAllowedState(Bool)
        case setRecievedMessagesBool(Bool)
        case setMessageAvailability(MessageHomeTimeStateEntity)
        case setRemainingSeconds(String?)
    }
    
    //MARK: - Init

    public init(
        fetchMessagesStatusUseCase: FetchMessagesStatusUseCaseProtocol,
        fetchReceivedMessageUseCase: FetchReceivedMessageUseCaseProtocol
    ) {
        self.fetchMessagesStatusUseCase = fetchMessagesStatusUseCase
        self.fetchReceivedMessageUseCase = fetchReceivedMessageUseCase
        self.initialState = State()
    }
    
    deinit {
        timer?.invalidate()
    }
}

    //MARK: - Reactor Method

extension MessageHomeViewReactor {
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .viewDidLoad:
            startTimer()
            return Observable.merge(fetchReceivedMessages(),
                                    fetchReservedMessages())
        case .checkCurrentTime:
            return checkCurrentTimeAndUpdateState()
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
        case .setMessageAvailability(let state):
            newState.messageAvailability = state
        case .setRemainingSeconds(let time):
            newState.remainingTime = time
        }
        return newState
    }
}

    //MARK: - Timer Method

extension MessageHomeViewReactor {
    
    private func startTimer() {
        timer?.invalidate()
        let currentHour = Calendar.current.component(.hour, from: Date())
        let isBetween17And22 = (17..<22).contains(currentHour)
        let interval: TimeInterval = isBetween17And22 ? 1 : 60 // 17~22시 사이면 1초마다, 아니면 1분마다
        timer = Timer.scheduledTimer(withTimeInterval: interval,
                                     repeats: true) { [weak self] _ in
            self?.action.onNext(.checkCurrentTime)
        }
        // 초기 호출
        self.action.onNext(.checkCurrentTime)
    }
    
    /// 시간체크하는 함수
    private func determineTimeState(for hour: Int) -> MessageHomeTimeStateEntity.postableTimeState {
        switch hour {
        case 0..<17:
            return .waitTime   // 00:00 ~ 17:00
        case 17..<22:
            return .postableTime   // 17:00 ~ 22:00
        case 22..<24:
            return .etcTime    // 22:00 ~ 24:00
        default:
            return .waitTime
        }
    }
    
    /// 17 ~ 22시 일시, 남은 시간 계산 함수
    private func calculateRemainingTime(currentDate: Date, timeState: MessageHomeTimeStateEntity.postableTimeState) -> String? {
        switch timeState {
        case .postableTime:
            // 오늘 22시의 날짜 생성
            var components = Calendar.current.dateComponents([.year, .month, .day], from: currentDate)
            components.hour = 22
            components.minute = 0
            components.second = 0
            guard let endDate = Calendar.current.date(from: components) else { return nil }
            let remainingSeconds = Int(endDate.timeIntervalSince(currentDate))
            let formattedTime = formatSeconds(remainingSeconds)
            return formattedTime
        default:
            return nil
        }
    }
    
    
    private func isReceivedMessageToday(_ receivedAt: String) -> Bool {
        guard let receivedDate = DateFormatter.iso8601().date(from: receivedAt) else {
            return false
        }
        return receivedDate.isSameDay(as: Date())
    }
    
    private func formatSeconds(_ totalSeconds: Int) -> String {
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}

    //MARK: - Mutaiton Method

extension MessageHomeViewReactor {
    
    private func checkCurrentTimeAndUpdateState() -> Observable<Mutation> {
        let currentDate = Date()
        let currentHour = Calendar.current.component(.hour, from: currentDate)
        let messageAvailabilityTime = determineTimeState(for: currentHour)
        let messageAvailability = MessageHomeTimeStateEntity(messageAvailabilityTime: messageAvailabilityTime)
        
        // 남은 시간 계산
        let remainingSeconds = calculateRemainingTime(currentDate: currentDate,
                                                         timeState: messageAvailabilityTime)
        
        // 타이머 간격 재설정
        startTimer()
        
        return Observable.concat([
            .just(.setMessageAvailability(messageAvailability)),
            .just(.setRemainingSeconds(remainingSeconds))
        ])
    }
    
    ///
    private func fetchReservedMessages() -> Observable<Mutation> {
        return fetchMessagesStatusUseCase
            .execute()
            .asObservable()
            .flatMap { entity -> Observable<Mutation> in
                guard let entity else {
                    return .empty()
                }
                return Observable.concat(
                    .just(.setReservedMessagesCount(entity.remainingMessages)),
                    .just(.isSendAllowedState(entity.isSendAllowed))
                )
            }
    }

    ///
    private func fetchReceivedMessages() -> Observable<Mutation> {
        return fetchReceivedMessageUseCase
            .execute(cursorId: 0)
            .asObservable()
            .flatMap { entity -> Observable<Mutation> in
                guard let entity else {
                    return .empty()
                }
                let hasMessageToday = self.isReceivedMessageToday(entity.messages.first?.receivedAt ?? "")
                return .just(.setRecievedMessagesBool(hasMessageToday))
            }
    }
}
