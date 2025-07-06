//
//  MessageEndPoint.swift
//  Networking
//
//  Created by eunseou on 8/8/24.
//

import Foundation

import Alamofire

public enum MessageEndPoint: WSNetworkEndPoint {
    
    // 쪽지 상태 조회 API
    case messagesStatus
    // 예약된 쪽지 조회 API
    case fetchReservedMessages
    // 쪽지 조회 API
    case fetchMessages(Encodable)
    // 학생 조회
    case searchStudent(Encodable)
    // 비속어 체크
    case checkProfanity(Encodable)
    // 쪽지 보내기
    case sendMessage(Encodable)
    // 받은 쪽지
    case getMessageRoomList
    // 쪽지 삭제
    case deleteMessage(Int)
    // 쪽지 차단
    case blockMessage(Int)
    // 쪽지 신고
    case reportMessage(Encodable)

    // 익명프로필 리스트 조회
    case fetchAnonymousProfileList(Int)
    
    case bookMark(Int)
    
    case detailMessage(Int)
    
    case replyMessage(Int, Encodable)
    
    case fetchBlockMessageList
    
    case messageEnable(Encodable)
    
    case fetchMessageNoti
            
    
    public var spec: WSNetworkSpec {
        switch self {
        case .messagesStatus:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURLV2)/messages/status")
        case .fetchReservedMessages:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/messages/scheduled")
        case .fetchMessages:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURLV2)/messages")
        case .searchStudent:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURL)/users/search")
        case .checkProfanity:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURL)/check-profanity")
        case .sendMessage:
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURLV2)/messages")
        case .getMessageRoomList:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURLV2)/messages")
        case .deleteMessage(let messageID):
            return WSNetworkSpec(method: .delete, url: "\(WSNetworkConfigure.baseURLV2)/messages/\(messageID)")
        case .blockMessage(let messageID):
            return WSNetworkSpec(method: .patch, url: "\(WSNetworkConfigure.baseURLV2)/messages/\(messageID)/block")
        case .reportMessage:
            return WSNetworkSpec(method: .post,
                                 url: "\(WSNetworkConfigure.baseURL)/reports")

        case .fetchAnonymousProfileList(let reciverId):
            return WSNetworkSpec(method: .get,
                                    url: "\(WSNetworkConfigure.baseURL)/messages/receiver/\(reciverId)/profiles")
        case .bookMark(let messageID):
            return WSNetworkSpec(method: .patch,
                                 url: "\(WSNetworkConfigure.baseURLV2)/messages/\(messageID)/bookmark")



        case .detailMessage(let id):
            return WSNetworkSpec(method: .get,
                                    url: "\(WSNetworkConfigure.baseURLV2)/messages/\(id)/details")
        case .replyMessage(let messageID, let query):
            return WSNetworkSpec(method: .post, url: "\(WSNetworkConfigure.baseURLV2)/messages/\(messageID)/answer")
        case .fetchBlockMessageList:
            return WSNetworkSpec(method: .get, url: "\(WSNetworkConfigure.baseURLV2)/messages/blocked")

        case .messageEnable:
            return WSNetworkSpec(method: .patch, url: "\(WSNetworkConfigure.baseURLV2)/messages/setting")
        case .fetchMessageNoti:
            return WSNetworkSpec(method: .put, url: "\(WSNetworkConfigure.baseURL)/users/settings")
        }
    }
    
    public var parameters: WSRequestParameters {
        switch self {
        case .messagesStatus:
            return .none
        case .fetchReservedMessages:
            return .none
        case .fetchMessages(let body):
            return .requestQuery(body)
        case .searchStudent(let body):
            return .requestQuery(body)
        case .checkProfanity(let body):
            return .requestBody(body)
        case .sendMessage(let body):
            return .requestBody(body)
        case .getMessageRoomList:
            return .none
        case .deleteMessage:
            return .none
        case .blockMessage:
            return .none
        case .reportMessage(let body):
            return .requestBody(body)
        case .fetchAnonymousProfileList:
            return .none
        case .bookMark:
            return .none

        case .detailMessage:
            return .none
        case .replyMessage(_, let body):
            return .requestBody(body)
        case .fetchBlockMessageList:
            return .none
        case .messageEnable(let body):
            return .requestBody(body)
        case .fetchMessageNoti:
            return .none
        }
    }
    
    public var headers: HTTPHeaders {
        return [
            "Content-Type": "application/json",
            "Authorization": "Bearer testToken"
        ]
    }
    
}
