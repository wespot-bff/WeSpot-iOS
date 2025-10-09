//
//  MessageSettingReactor.swift
//  MessageFeature
//
//  Created by 최지철 on 5/29/25.
//

import MessageDomain
import AllDomain
import Extensions
import Util

import ReactorKit
import RxSwift
import UIKit

public final class MessageSettingReactor: Reactor {
    
    // MARK: - UseCase
    
    public var router: MessageSettingRouting?
    private let usecase: MessageSettingUsecase
    private let notiUsecase: FetchUserAlarmSettingUseCaseProtocol?
    private let uploadNotiUsecase: UpdateUserAlarmSettingUseCaseProtocol?

    // MARK: - Properties
    
    public var initialState: State
    let globalState: WSGlobalServiceProtocol = WSGlobalStateService.shared

    public struct State {
        var settingList: [MessageSettingListEnum] = [.blockList, .incomingOutgoing, .alert]
        var blockList: [MessageRoomEntity] = []
        @Pulse var notificationState: UserAlarmEntity?
        @Pulse var messageNotiStatus: Bool = false
        @Pulse var error: String = ""
        @Pulse var isLoading: Bool = false
        @Pulse var messageAlertState: Bool = false
        @Pulse var compelteUnBlock: Bool = false
    }
    
    public enum Action {
        case routeToList(MessageSettingListEnum, UIViewController)
        case unblcockMessage(Int)
        case toggleMessageStatus(Bool)
        case toggleNotificationStatus(Bool)
        case fetchBlockList
        case fetchMessageStatus
        case fetchNotificationStatus
        
    }

    public enum Mutation {
        case setBlockList([MessageRoomEntity])
        case setMessageStatus(Bool)
        case setNotificationStatus(UserAlarmEntity)
        case removeItem(id: Int)
        case setError(String)
    }
    
    // MARK: - Init
    
    public init(usecase: MessageSettingUsecase,
                router: MessageSettingRouting?,
                notiUsecase: FetchUserAlarmSettingUseCaseProtocol?,
                uploadNotiUsecase: UpdateUserAlarmSettingUseCaseProtocol?) {
        self.router = router
        self.usecase = usecase
        self.notiUsecase = notiUsecase
        self.uploadNotiUsecase = uploadNotiUsecase
        self.initialState = State()
    }
}

    // MARK: - Reactor

extension MessageSettingReactor {
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {

        case .routeToList(let type, let vc):
            router?.goToSetting(type, vc)
            print("MessageSettingReactor: routeToList \(type) called")
            return Observable.empty()
        case .fetchBlockList:
            return Observable.create { [weak self] observer in
                guard let self = self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                Task {
                    do {
                        let entity = try await self.usecase.fetchBlockMessgeList()
                        observer.onNext(Mutation.setBlockList(entity))
                    }
                    observer.onCompleted()
                }
                return Disposables.create()
            }
            
        case .unblcockMessage(let id):
            return usecase.unBlockMessage(messageId: id)
                .asObservable()
                .flatMap { isSuccess -> Observable<Mutation> in
                    if isSuccess {
                        return .just(.removeItem(id: id))
                    } else {
                        return .just(.setError("수신 및 발신 알림 끄기가 실패했습니다."))
                    }
                }
        case .toggleMessageStatus(let isOn):
            return usecase.messsageStatus(status: isOn)
                .asObservable()
                .flatMap {
                    isSuccess -> Observable<Mutation> in
                    if isSuccess {
                        return .just(.setMessageStatus(isOn))
                    } else {
                        return .empty()
                    }
                }
        case .fetchMessageStatus:
            return usecase.fetchMessageStatus()
                .asObservable()
                .flatMap {  entity -> Observable<Mutation> in
                    let isOn = entity.isReceivedAllowed
                    print("======\(entity)")
                    return .just(.setMessageStatus(isOn))
                }
        case .fetchNotificationStatus:
            return notiUsecase!.execute()
                .asObservable()
                .flatMap { entity -> Observable<Mutation> in
                    return .just(.setNotificationStatus(entity ?? UserAlarmEntity(isEnableVoteNotification: false, isEnableMessageNotification: false, isEnableMarketingNotification: false)))
                }
                
        case .toggleNotificationStatus(let status):
            let query = UpdateUserProfileAlarmRequest(isEnableVoteNotification: currentState.notificationState?.isEnableVoteNotification ?? false,
                                                      isEnableMessageNotification: status,
                                                      isEnableMarketingNotification: currentState.notificationState?.isEnableMarketingNotification ?? false)
            return uploadNotiUsecase!.execute(body: query)
                .asObservable()
                .flatMap { isSuccess -> Observable<Mutation> in
                    if isSuccess {
                        return Observable.empty()
                    } else {
                        return Observable.empty()
                    }
                }
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setBlockList(let list):
            newState.blockList = list
        case .removeItem(let id):
            newState.blockList = state.blockList.filter { $0.id != id }
            newState.compelteUnBlock = true
        case .setMessageStatus(let status):
            print("111111 \(status)")
            newState.messageAlertState = status
        case .setError(let errorMsg):
            newState.error = errorMsg
        case .setNotificationStatus(let status):
            newState.notificationState = status
        }
        return newState
    }
}


    // MARK: - Mutation Logic

extension MessageSettingReactor {

}

 
