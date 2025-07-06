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
    
    static let messageHomePostableTitleText: String = "\(UserDefaultsManager.shared.userName ?? "")님을 설레게 한 친구에게\n쪽지로 마음을 표현해 보세요"
    static let messageHomeCompeleteTitleText: String = "님의 소중한 마음을 모두 전달해 드렸어요"
    static let messageSendUnavailableButtonText: String = "내일 새로운 쪽지를 작성할 수 있어요"
    static let messageSendAvailableButtonText: String = "새로운 쪽지 보내기"
    static let postableMessageCount: String = "오늘 보낼 수 있는 남은 쪽지"
    static let messageLeftTimeIntroText: String = "새 쪽지 생성까지 남은 시간"
    static let waitRepeatMessage: String = "답장을 기다리는 쪽지가 있어요"
    static let checkMessageButtonText: String = "눌러서 바로 확인하기"
    
    // MARK: 쪽지 작성(학생 검색) 관련 텍스트
    
    static let searchNoResultButtonText: String = "찾는 친구가 없다면?"
    static let messageWriteTitle: String = "쪽지를 작성해 주세요\n에버가 전달해 드릴게요"
    

    // MARK: 쪽지함 관련 텍스트
    
    static let messageRecievedType: String = "RECEIVED"
    static let messageSentType: String = "SENT"
    static let messageInventoryAllButton: String = "전체"
    static let messageInventoryFavoriteButton: String = "즐겨찾기"
    static let reportMessage: String = "신고 접수된 쪽지입니다"
    static let blockMessage: String = "차단된 쪽지입니다"

    
    // MARK: 바텀시트(삭제, 차단, 신고, 익명 프로필) 관련 텍스트
    
    static let blockMessageAlertTitle: String = "정말 차단하시나요?"
    static let blockMessageAlertDes: String = "해당 친구와의 쪽지 수신 및 발신이 차단돼요\n* 차단 해제 : 전체>설정>차단 목록>차단 해제"
    static let blockMessageBtnTitle: String = "네 차단할래요"
    static let reportMessageAlertTitle: String = "정말 신고하시나요?"
    static let reportMessageAlertDes: String = "허위 신고로 확인될 시 서비스 이용이 제한되며\n쪽지는 신고 즉시 삭제돼요"
    static let reportMessageBtnTitle: String = "네 신고할래요"
    static let deleteMessageAlertTitle: String = "쪽지를 삭제하시나요?"
    static let deleteMessageAlertDes: String = "삭제한 쪽지는 절대 되돌릴 수 없어요"
    static let deleteMessageBtnTitle: String = "네 삭제할래요"
    
    static let anonymousProfileTitle: String = "익명 프로필을 선택해 주세요"
    static let anonymousProfileDes: String = "아래의 여러 프로필을 사용하여 상대방과 대화했어요\n어떤 프로필로 대화할 지 쪽지를 선택해 주세요"
    static let anonymousProfileMakeButton: String = "새로운 익명 프로필로 보내기"
    static let makeAnonymousProfilePopTitle: String = "받는 사람에게 보여질\n익명 프로필을 설정해 주세요"
    
    // MARK: 쪽지 설정(차단, 알림설정) 관련 텍스트
    
    static let messageSettingTitle: String = "쪽지 설정"
    static let messageSettingBlockTitle: String = "쪽지 차단"
    static let messageNotificationTitle: String = "쪽지 알림"
    static let getNotiAlertText: String = "쪽지 받기"
    static let messageNotitDes: String = "설정 해제 시, 쪽지를 보내거나 받을 수 없어요"
    static let messageAlertTitle: String = "쪽지 수신 및 발신"
    static let getMessageAlertText: String = "알림 받기"
    static let messageAlertDes: String = "쪽지 수신 알림 및 쪽지 관련 알림"


}

// MARK: - Identifier(Reuse Identifier 등) 모음

extension String.MessageTexts.Identifier {
    static let studentSearchTableViewCell = "StudentSearchTableViewCell"
    static let messageCollectionViewCell = "MessageCollectionViewCell"
    static let MessageBottomSheetTabelViewCell = "MessageBottomSheetTabelViewCell"
    static let MessageReportCollectionViewCell = "MessageReportCollectionViewCell"
    static let AnonymousProfileCell = "AnonymousProfileCell"
    static let MessageHistoryCollectionViewCell = "MessageHistoryCollectionViewCell"
    static let MessageSettingTableViewCell = "MessageSettingTableViewCell"
}
