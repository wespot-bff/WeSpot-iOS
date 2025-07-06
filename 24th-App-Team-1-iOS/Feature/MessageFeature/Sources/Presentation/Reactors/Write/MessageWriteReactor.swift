//
//  MessageWriteReactor.swift
//  MessageFeature
//
//  Created by 최지철 on 12/22/24.
//

import MessageDomain
import Extensions
import Util

import ReactorKit
import RxSwift
import UIKit

public final class MessageWriteReactor: Reactor {
    
    // MARK: - UseCase
    
    private let fetchSearchResultUseCase: FetchStudentSearchResultUseCase
    private let writeMessageUseCase: WriteMessageUseCase
    private let bottomSheetRouter: AnonymousProfileBottomSheetRouting?
    private let anonmousProfileUseCase: AnonymousProfileUseCase?

    // MARK: - Properties
    
    let globalState: WSGlobalServiceProtocol = WSGlobalStateService.shared
    public var initialState: State
    private let disposeBag = DisposeBag()

    public struct State {
        @Pulse var serachResult: StudentListResponseEntity?
        var cursorId: Int = 0
        @Pulse var noSearchResult: Bool = false
        var searchText: String = ""
        var selectedUser: StudentListResponseEntity.UserEntity?
        @Pulse var isLoading: Bool = true
        var studentList: [StudentListResponseEntity.UserEntity] = []
        @Pulse var completSetSenderProfile: Bool = false

        @Pulse var message: String = ""
        @Pulse var profanityDetection: Bool = false
        var isAnonymous: Bool = false
        @Pulse var completeSendMessage: Bool = false
        @Pulse var anonymousProfileStatus: AnonymousProfileStatusEnum = .oneOrNone
        @Pulse var successDelete: Bool?
        var profileImageURL: String = ""
        var profileImage: UIImage?
        var userName: String = ""
        
        var isReply: Bool = false
        
        var replyMessage: MessageRoomEntity?
        @Pulse var meesageRoom: MessageRoomEntity?
        var detailMessage: MessageDetailEntity?
    }
    
    public enum Action {
        case searchStudent(String)
        case selectUser(StudentListResponseEntity.UserEntity)
        case writeMessage(String)
        case loadMoreUsers
        case sendMessageTapped
        case presentAnonymousBottomSheet(Int, UIViewController)
        case setAnonymousProfile(name: String, imageUrl: String, image: UIImage)
        case anonymousProfileCreationCompleted
        case setMessageRoom(MessageRoomEntity)
        
        case setndReplyMessgaeTapped
        case setReplyMessage(MessageRoomEntity)
        case tappedMessage(MessageDetailEntity)
        case deleteMessage(MessageDetailEntity)
    }

    public enum Mutation {
        case setSearchResult(StudentListResponseEntity?)
        case appendSearchResult(StudentListResponseEntity?)
        case selectUser(StudentListResponseEntity.UserEntity)
        case setSearchText(String)
        case setNoResult(Bool)
        case setLoading(Bool)
        case DetectProfanity(Bool)
        case setMessage(String)
        case postMessage(Bool)
        case setAnonymous(Bool)
        case setBottomSheet(AnonymousProfileStatusEnum)
        case setAnonymousProfile(name: String, imageUrl: String, image: UIImage)
        case completeSenderProfileSetup(Bool)
        case setRoom(MessageRoomEntity)
        case setDetailMessage(MessageDetailEntity)
        case setDeleeteMessage(Bool)
        case setReplyMessage(MessageRoomEntity)
        case replyMessage(Bool)
    }
    
    // MARK: - Init
    
    public init(fetchSearchResultUseCase: FetchStudentSearchResultUseCase,
                bottomSheetRouter: AnonymousProfileBottomSheetRouting?,
                anonmousProfileUseCase: AnonymousProfileUseCase?,
                writeMessageUseCase: WriteMessageUseCase) {
        self.anonmousProfileUseCase = anonmousProfileUseCase
        self.writeMessageUseCase = writeMessageUseCase
        self.bottomSheetRouter = bottomSheetRouter
        self.fetchSearchResultUseCase = fetchSearchResultUseCase
        self.initialState = State()
        
        // globalState.event를 구독하도록 변경
        globalState.event
            .asObservable()
            .flatMap { globalEvent -> Observable<Action> in // globalEvent로 이름 변경
                switch globalEvent { // globalAction 대신 globalEvent 사용
                case .setAnonymousProfileData(let name, let imageUrl, let image):
                    return .just(.setAnonymousProfile(name: name, imageUrl: imageUrl, image: image))
                case .anonymousProfileSetupComplete:
                    return .just(.anonymousProfileCreationCompleted)
                default:
                    return .empty()
                }
            }
            .bind(to: self.action)
            .disposed(by: disposeBag)
    }
}

// MARK: - Reactor Logic

extension MessageWriteReactor {
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .searchStudent(let name):
            return .merge([
                searchStudent(name: name, isLoadMore: false),
                Observable.just(Mutation.setSearchText(name))
            ])
            
        case .selectUser(let user):
            return .just(.selectUser(user))
            
        case .loadMoreUsers:
            guard let result = currentState.serachResult,
                  result.hasNext == true,
                  currentState.isLoading else {
                return .empty()
            }
            return searchStudent(name: currentState.searchText,
                                 isLoadMore: true)
        case .writeMessage(let content):
            return writeMessage(message: content)
        case .sendMessageTapped:
            return sendMessage(content: currentState.message,
                               receiverId: currentState.selectedUser?.id ?? 0,
                               senderName: currentState.userName,
                               senderImageURL: currentState.profileImageURL,
                               isAnonymous: currentState.isAnonymous)

        case .presentAnonymousBottomSheet(let id, let vc):
            return calculateBottomSheetList(receiverId: id, presentingVC: vc)
                .flatMap { statusMutation -> Observable<Mutation> in
                    guard case let .setBottomSheet(status) = statusMutation else { return .empty() }
                    
                    self.bottomSheetRouter?.presentAnonymousProfileBottomSheet(status, vc: vc, onProfileCreated: { name, imageUrl, isAnonymous, profileImg in
                        print("Anonymous Profile Created: \(name), \(imageUrl)")
                        self.globalState.event.onNext(.setAnonymousProfileData(name: name, imageUrl: imageUrl, image: profileImg))
                        self.globalState.event.onNext(.anonymousProfileSetupComplete)
                        NotificationCenter.default.post(name: .showInputMessageWirteViewController, object: nil)
                    })
                    return .empty()
                }
            
        case .setAnonymousProfile(let name, let imageUrl, let image):
            return Observable.just(.setAnonymousProfile(name: name, imageUrl: imageUrl, image: image))
    
            
        case .anonymousProfileCreationCompleted:
            return .just(.completeSenderProfileSetup(true))
        case .setMessageRoom(let room):
            return .just(.setRoom(room))
        case .tappedMessage(let message):
            return .just(.setDetailMessage(message))
        case .deleteMessage(let message):
            return writeMessageUseCase.deleteMessage(messageId: message.id)
                .asObservable()
                .flatMap { result -> Observable<Mutation> in
                    if result {
                        return .just(.setDeleeteMessage(true))
                    } else {
                        return .just(.setDeleeteMessage(false))
                    }
                }
  
        case .setReplyMessage(let message):
            return Observable.just(.setReplyMessage(message))
        case .setndReplyMessgaeTapped:
            return writeMessageUseCase.replyMessage(id: currentState.replyMessage?.id ?? 0,
                                                    content: currentState.message)
                .asObservable()
                .flatMap {  result -> Observable<Mutation> in
                    return Observable.just(Mutation.replyMessage(result))
                    
                }
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setSearchResult(let result):
            newState.serachResult = result
            if let list = result?.users {
                newState.studentList = list
            }

        case .appendSearchResult(let result):
            if var current = newState.serachResult, let newData = result {
                current.users.append(contentsOf: newData.users)
                current.lastCursorId = newData.lastCursorId
                current.hasNext      = newData.hasNext
                newState.serachResult = current
                newState.studentList = current.users
            }
            
        case .selectUser(let user):
            newState.selectedUser = user

        case .setNoResult(let toggle):
            newState.noSearchResult = toggle

        case .setLoading(let isLoading):
            newState.isLoading = isLoading
        case .setSearchText(let text):
            newState.searchText = text
        case .setMessage(let text):
            newState.message = text
        case .DetectProfanity(let result):
            newState.profanityDetection = result
        case .postMessage(let result):
            newState.completeSendMessage = result
        case .setAnonymous(let value):
            newState.isAnonymous = value
        case .setBottomSheet(let status):
            newState.anonymousProfileStatus = status
            
        case .setAnonymousProfile(let name, let imageUrl, let image):
            newState.userName = name
            newState.profileImageURL = imageUrl
            newState.isAnonymous = true
            newState.profileImage = image
        case .completeSenderProfileSetup(let completed):
            newState.completSetSenderProfile = completed
            newState.isReply = false

            
        case .setRoom(let room):
            newState.meesageRoom = room
            newState.userName = room.senderProfile.name
            newState.profileImageURL = room.senderProfile.iconUrl

        case .setDetailMessage(let message):
            newState.detailMessage = message
        case .setDeleeteMessage(let success):
            newState.successDelete = success
        case .setReplyMessage(let info):
            newState.isReply = true
            newState.replyMessage = info

        case .replyMessage(let result):
            newState.completeSendMessage = result
        }
        return newState
    }
}

// MARK: - Mutation Logic

extension MessageWriteReactor {
    
    private func sendMessage(content: String, receiverId: Int, senderName: String, senderImageURL: String, isAnonymous: Bool) -> Observable<Mutation> {
        return writeMessageUseCase.sendMessage(content: content, receiverId: receiverId, senderName: senderName, senderImageURL: senderImageURL, isAnonymous: isAnonymous)
            .asObservable()
            .flatMap { result in
                return Observable.just(Mutation.postMessage(result))
            }
    }
    
    private func writeMessage(message: String) -> Observable<Mutation> {
        let detectProfanity = writeMessageUseCase.checkProfanity(message: message)
            .asObservable()
            .map { isClean in Mutation.DetectProfanity(isClean) }
        
        let setMessage = Observable.just(Mutation.setMessage(message))
        
        return Observable.merge(detectProfanity, setMessage)
    }
    
    private func searchStudent(name: String,
                               isLoadMore: Bool) -> Observable<Mutation> {
        let startLoading = Observable.just(Mutation.setLoading(false))
        
        let cursorId = isLoadMore
            ? (currentState.serachResult?.lastCursorId ?? 0)
            : 0
        
        let query = SearchStudentRequest(name: name, cursorId: cursorId)

        let request = fetchSearchResultUseCase.excute(query: query)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                guard let result = result else {
                    return .concat([
                        .just(.setSearchResult(nil)),
                        .just(.setNoResult(true))
                    ])
                }
                
                if result.users.isEmpty {
                    return .concat([
                        .just(.setSearchResult(result)),
                        .just(.setNoResult(true))
                    ])
                } else {
                    if isLoadMore {
                        return .just(.appendSearchResult(result))
                    } else {
                        return .concat([
                            .just(.setSearchResult(result)),
                            .just(.setNoResult(false)) // 이전 답변에서 .just(.just(.setNoResult(false))) 였던 것을 수정했습니다.
                        ])
                    }
                }
            }
            .catch { _ in
                return .just(.setNoResult(true))
            }
        
        let endLoading = Observable.just(Mutation.setLoading(true))
        
        return .concat([startLoading, request, endLoading])
    }
    
    private func calculateBottomSheetList(receiverId: Int, presentingVC: UIViewController) -> Observable<Mutation> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            Task {
                do {
                    let entity = try await self.anonmousProfileUseCase?.getAnonymousProfileList(receiverId: receiverId)
                    var status: AnonymousProfileStatusEnum
                    if entity?.count == 0 || entity?.count == 1 {
                        status = .oneOrNone
                    } else if entity?.count == 2 {
                        status = .two
                    } else if entity?.count == 3 {
                        status = .third
                    } else {
                        status = .full
                    }
                    observer.onNext(Mutation.setBottomSheet(status))
                    observer.onCompleted()
                } catch {
                    print("Error fetching anonymous profile list: \(error)")
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }
    }
}
