//
//  MessageNetworkError.swift
//  MessageService
//
//  Created by 최지철 on 10/12/25.
//

import Foundation
import MessageDomain

public struct MessageNetworkError: Decodable {
    public let status: Int
    public let title: String
    public let view: String
    public let type: String
    public let detail: String
    public let instance: String
}
public extension MessageNetworkError {
    
    func toDomain() -> MessagePostError {
        let viewType: MessageErrorViewType
        
        // 서버에서 받은 view 문자열을 MessageErrorViewType enum으로 변환
        switch self.view.uppercased() {
        case "TOAST":
            viewType = .toast
        case "ALERT":
            viewType = .alert
        case "NONE":
            viewType = .none
        default:
            viewType = .unknown
        }
        
        return MessagePostError(
            errorDescription: self.detail, // 'detail' 필드를 사용자에게 보여줄 설명으로 사용
            errorView: viewType
        )
    }
}
