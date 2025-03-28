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
    

    // MARK: 쪽지함 관련 텍스트
    
    static let messageRecievedType: String = "RECEIVED"
    static let messageSentType: String = "SENT"
    
    // MARK: 바텀시트(삭제, 차단, 신고) 관련 텍스트
    
    static let blockMessageAlertTitle: String = "정말 차단하시나요?"
    static let blockMessageAlertDes: String = "해당 친구와의 쪽지 수신 및 발신이 차단돼요\n* 차단 해제 : 전체>설정>차단 목록>차단 해제"
    static let blockMessageBtnTitle: String = "네 차단할래요"
    static let reportMessageAlertTitle: String = "정말 신고하시나요?"
    static let reportMessageAlertDes: String = "허위 신고로 확인될 시 서비스 이용이 제한되며\n쪽지는 신고 즉시 삭제돼요"
    static let reportMessageBtnTitle: String = "네 신고할래요"
    static let deleteMessageAlertTitle: String = "쪽지를 삭제하시나요?"
    static let deleteMessageAlertDes: String = "삭제한 쪽지는 절대 되돌릴 수 없어요"
    static let deleteMessageBtnTitle: String = "네 삭제할래요"


}

// MARK: - Identifier(Reuse Identifier 등) 모음

extension String.MessageTexts.Identifier {
    static let studentSearchTableViewCell = "StudentSearchTableViewCell"
    static let messageCollectionViewCell = "MessageCollectionViewCell"
    static let MessageBottomSheetTabelViewCell = "MessageBottomSheetTabelViewCell"
    static let MessageReportCollectionViewCell = "MessageReportCollectionViewCell"

}
