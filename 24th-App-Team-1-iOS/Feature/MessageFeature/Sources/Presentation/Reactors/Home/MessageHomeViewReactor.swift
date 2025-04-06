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
        @Pulse var postableMessageCount: Int = 0
        @Pulse var isSendAllowed: Bool?
        @Pulse var recievedMessages: Bool?
        var remainingTime: String?
        @Pulse var haveMessage: Bool = false
    }
    
    public enum Action {
        case viewWillAppear
        case viewDisappeared
        case checkCurrentTime
        case sendButtonTapped
    }
    
    public enum Mutation {
        case setPostableMessageCount(Int)
        case isSendAllowedState(Bool)
        case setRecievedMessagesBool(Bool)
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
            return fetchMessagesStatus()
            
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
            
        case .setRecievedMessagesBool(let hasMessages):
            newState.recievedMessages = hasMessages
        case .isSendAllowedState(let isAllowed):
            newState.isSendAllowed = isAllowed
        case .setRemainingSeconds(let time):
            newState.remainingTime = time
        case .checkHaveMessage(let state):
            newState.haveMessage = state
        case .setPostableMessageCount(let count):
            newState.postableMessageCount = count
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
        // 남은 시간 계산
        let remainingTime = calculateRemainingTime(currentDate: currentDate)
        
        // **주의**: Concurrency 기반으로 1초마다 갱신 중이므로
        // checkCurrentTimeAndUpdateState() 내에서 `startTimer()`는 더 이상 호출하지 않습니다.
        
        return Observable.concat([
            .just(.setRemainingSeconds(remainingTime))
        ])
    }
    
    /// 예약된 메시지 정보 불러오기
    private func fetchMessagesStatus() -> Observable<Mutation> {
        print("fetchMessagesStatu11")
        return fetchMessagesStatusUseCase
            .execute()
            .asObservable()
            .do(onError: { error in
                print("fetchMessagesStatus error: \(error)")
            })
            .flatMap { entity -> Observable<Mutation> in
                let messageCountState = entity.countUnReadMessages > 0
                print("Unread message count: \(entity.countUnReadMessages)")
                return Observable.concat(
                    .just(.checkHaveMessage(messageCountState)),
                    .just(.setPostableMessageCount(entity.remainingMessages)),
                    .just(.isSendAllowedState(entity.isSendAllowed))
                )
            }
    }
    

}

// MARK: - Helper Methods

extension MessageHomeViewReactor {

    /// 남은 시간 계산
    private func calculateRemainingTime(currentDate: Date) -> String? {
        let calendar = Calendar.current
        // 내일 날짜를 계산하고, 그 날짜의 자정(시작)을 구합니다.
        guard let tomorrow = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
            return nil
        }
        let startOfTomorrow = calendar.startOfDay(for: tomorrow)
        
        // 현재 시간과 내일 자정 사이의 초 단위 차이 계산
        let interval = startOfTomorrow.timeIntervalSince(currentDate)
        guard interval >= 0 else { return "00:00:00" }
        
        let hours = Int(interval) / 3600
        let minutes = (Int(interval) % 3600) / 60
        let seconds = Int(interval) % 60
        
        // HH:MM:SS 포맷으로 문자열 생성
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
}
