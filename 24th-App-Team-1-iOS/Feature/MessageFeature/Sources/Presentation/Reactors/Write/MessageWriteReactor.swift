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

public final class MessageWriteReactor: Reactor {
    
    // MARK: - UseCase
    
    private let fetchSearchResultUseCase: FetchStudentSearchResultUseCase
    private let writeMessageUseCase: WriteMessageUseCase

    // MARK: - Properties
    
    let globalState: WSGlobalServiceProtocol = WSGlobalStateService.shared
    public var initialState: State
    
    public struct State {
        // 검색
        @Pulse var serachResult: StudentListResponseEntity?
        var cursorId: Int = 0
        @Pulse var noSearchResult: Bool = false
        var searchText: String = ""
        var selectedUser: StudentListResponseEntity.UserEntity?
        @Pulse var isLoading: Bool = false
        var studentList: [StudentListResponseEntity.UserEntity] = []
        
        // 작성
        @Pulse var message: String = ""
        @Pulse var profanityDetection: Bool = false
        var isAnonymous: Bool = false
        @Pulse var completeSendMessage: Bool = false

    }
    
    public enum Action {
        case searchStudent(String)
        case selectUser(StudentListResponseEntity.UserEntity)
        case writeMessage(String)
        case loadMoreUsers
        case sendMessageTapped
        case anonymousToggle(Bool)
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
        case postMessage(SendMessageResponseEntity)
        case setAnonymous(Bool)
    }
    
    // MARK: - Init
    
    public init(fetchSearchResultUseCase: FetchStudentSearchResultUseCase,
                writeMessageUseCase: WriteMessageUseCase) {
        self.writeMessageUseCase = writeMessageUseCase
        self.fetchSearchResultUseCase = fetchSearchResultUseCase
        self.initialState = State()
    }
}

    // MARK: - Reactor

extension MessageWriteReactor {
    public func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .searchStudent(let name):
            // 새 검색(= 첫 페이지)
            return .merge([
                 searchStudent(name: name, isLoadMore: false),
                 Observable.just(Mutation.setSearchText(name))
             ])
            
        case .selectUser(let user):
            // 셀 선택
            return .just(.selectUser(user))
            
        case .loadMoreUsers:
            // 추가 로드(= 다음 페이지)
            guard let result = currentState.serachResult,
                  result.hasNext == true, // 다음 페이지 있음
                  currentState.isLoading else { // 현재 로딩 중이 아니어야
                return .empty()
            }
            return searchStudent(name: currentState.searchText,
                                 isLoadMore: true)
        case .writeMessage(let content):
            return writeMessage(message: content)
        case .sendMessageTapped:
            return sendMessage(content: currentState.message,
                               receiverId: currentState.selectedUser?.id ?? 0,
                               senderName: "",
                               isAnonymous: currentState.isAnonymous)
        case .anonymousToggle(let value):
            return Observable.just(.setAnonymous(value))
        }
    }
    
    public func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setSearchResult(let result):
            newState.serachResult = result
            // 새 검색 시 studentList 초기화
            if let list = result?.users {
                newState.studentList = list
            }

        case .appendSearchResult(let result):
            // 기존 데이터 + 새 데이터
            if var current = newState.serachResult, let newData = result {
                current.users.append(contentsOf: newData.users)
                current.lastCursorId = newData.lastCursorId
                current.hasNext      = newData.hasNext
                newState.serachResult = current
                // View에 표시할 studentList도 갱신
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
            if result.id != 0 {
                newState.completeSendMessage = true
            }
        case .setAnonymous(let value):
            newState.isAnonymous = value
        }
        return newState
    }
}

    // MARK: - Mutation Logic

extension MessageWriteReactor {
    
    private func sendMessage(content: String, receiverId: Int, senderName: String, isAnonymous: Bool) -> Observable<Mutation> {
        return writeMessageUseCase.sendMessage(content: content, receiverId: receiverId, senderName: senderName, isAnonymous: isAnonymous)
            .asObservable()
            .flatMap { result in
                return Observable.just(Mutation.postMessage(result))
            }
    }
    
    private func writeMessage(message: String) -> Observable<Mutation> {
        // 비속어 검사
        let detectProfanity = writeMessageUseCase.checkProfanity(message: message)
            .asObservable()
            .map { isClean in Mutation.DetectProfanity(isClean) }
        
        // 메시지 설정
        let setMessage = Observable.just(Mutation.setMessage(message))
        
        return Observable.merge(detectProfanity, setMessage)
    }
    
    private func searchStudent(name: String,
                               isLoadMore: Bool) -> Observable<Mutation> {
        
        // 1) 시작 시 로딩 표시
        let startLoading = Observable.just(Mutation.setLoading(false))
        
        // 2) cursorId 결정 (새 검색이면 0, 더 보기면 lastCursorId)
        let cursorId = isLoadMore
            ? (currentState.serachResult?.lastCursorId ?? 0)
            : 0
        
        // 실제 요청 시 cursorId 반영
        let query = SearchStudentRequest(name: name, cursorId: cursorId)

        // 3) 네트워크 요청
        let request = fetchSearchResultUseCase.excute(query: query)
            .asObservable()
            .flatMap { result -> Observable<Mutation> in
                // 결과가 없거나 nil인 경우
                guard let result = result else {
                    return .concat([
                        .just(.setSearchResult(nil)),
                        .just(.setNoResult(true))
                    ])
                }
                
                // users가 비어 있으면 검색 결과 없음
                if result.users.isEmpty {
                    return .concat([
                        .just(.setSearchResult(result)),
                        .just(.setNoResult(true))
                    ])
                } else {
                    // 새 검색 vs. 더 보기
                    if isLoadMore {
                        return .just(.appendSearchResult(result))
                    } else {
                        return .concat([
                            .just(.setSearchResult(result)),
                            .just(.setNoResult(false))
                        ])
                    }
                }
            }
            .catch { _ in
                // 에러 발생 시 noSearchResult = true
                return .just(.setNoResult(true))
            }
        
        // 4) 로딩 해제 (끝날 때)
        let endLoading = Observable.just(Mutation.setLoading(true))
        
        // 5) 순서대로 방출
        return .concat([startLoading, request, endLoading])
    }
}
