//
//  MessageComponentStrings.swift
//  MessageFeature
//
//  Created by 최지철 on 12/21/24.
//

import Foundation

import Storage

/// 메시지 관련 문자열들을 한 곳에 모아두기 위해 만든 타입
typealias MessageComponentStrings = String.MessageTexts
/// 셀과 같은 곳에서 재사용할 Identifier 모음
typealias MessageIdentifier = String.MessageTexts.Identifier

extension String {
    /// 쪽지(메시지) 관련 텍스트 모음
    enum MessageTexts {
        /// 쪽지(메시지)에서 사용될 Cell, Header, Footer 등 Identifier 모음
        enum Identifier { }
    }
}

// MARK: - 실제 UI에서 사용할 문자열

extension String.MessageTexts {
    
    // 홈, 쪽지함 토글
    static let messageHomeButtonText: String = "쪽지 홈"
    static let messageBoxButtonText: String = "쪽지함"
    
    // MARK: 쪽지 홈 관련 텍스트
    
    static let messageHomePostableTitleText: String = "님을 설레게한 친구에게\n익명 쪽지로 마음을 표현해 보세요"
    static let messageHomeCompeleteTitleText: String = "님의 소중한 마음을 모두 전달해 드렸어요"
    static let messageSendUnavailableButtonText: String = "익명 쪽지함은 매일 밤 10시에 열려요"
    static let messageSendAvailableButtonText: String = "익명 쪽지 보내기"
    static let messageLeftTimeIntroText: String = "쪽지 전달까지 남은 시간"
    static let postableTimeIntroText: String = "서로의 쪽지는 밤 10시에 전달해 드릴게요"
    static let waitTimeIntroText: String = "내일 저녁 5시에 새로운 쪽지를 보낼 수 있어요"
    static let messageSendWaitTimeButtonText: String = "매일 저녁 5시에 새로운 쪽지를 보낼 수 있어요"
    
    // MARK: 쪽지 작성(학생 검색) 관련 텍스트
    
    static let searchNoResultButtonText: String = "찾는 친구가 없다면?"

    // MARK: 쪽지 작성 관련 텍스트

    

    // MARK: 쪽지함 관련 텍스트

}

// MARK: - Identifier(Reuse Identifier 등) 모음

extension String.MessageTexts.Identifier {
    static let studentSearchTableViewCell = "StudentSearchTableViewCell"

}
