//
//  UserDefaultsManager.swift
//  Util
//
//  Created by eunseou on 7/30/24.
//

import Foundation
import LoginDomain
import VoteDomain

public class UserDefaultsManager {
    
    public static let shared = UserDefaultsManager()
    
    private init() {}
    
    enum Key: String {
        case isAccessed // 앱에 처음 접근했는지 확인(Bool)
        case accessToken // access token
        case refreshToken // 재발행 토큰
        case userName // 사용자 이름
        case socialType // 사용자 로그인 타입
        case userProfileImage
        case userBackgroundColor
        case fcmToken
        case voteStub
        case expiredDate
        case lastPromptedVersion
    }
    
    @UserDefaultsWrapper(key: Key.isAccessed.rawValue, defaultValue: false)
       public var isAccessed: Bool?
    
    @UserDefaultsWrapper(key: Key.accessToken.rawValue, defaultValue: "")
        public var accessToken: String?
    
    @UserDefaultsWrapper(key: Key.refreshToken.rawValue, defaultValue: "")
        public var refreshToken: String?
    
    @UserDefaultsWrapper(key: Key.userName.rawValue, defaultValue: "")
        public var userName: String?
    
    @UserDefaultsWrapper(key: Key.socialType.rawValue, defaultValue: "")
        public var socialType: String?
    
    @UserDefaultsWrapper(key: Key.userProfileImage.rawValue, defaultValue: "")
        public var userProfileImage: String?
    
    @UserDefaultsWrapper(key: Key.userBackgroundColor.rawValue, defaultValue: "")
        public var userBackgroundColor: String?
    
    @UserDefaultsWrapper(key: Key.expiredDate.rawValue, defaultValue: Date())
        public var expiredDate: Date
    
    @UserDefaultsWrapper(key: Key.fcmToken.rawValue, defaultValue: "")
        public var fcmToken: String?
    
    @UserDefaultsWrapper(key: Key.voteStub.rawValue, defaultValue: [])
        public var voteRequest: [CreateVoteItemReqeuest]
    
    @UserDefaultsWrapper(key: Key.lastPromptedVersion.rawValue, defaultValue: "")
        public var lastPromptedVersion: String
    
    public func clearAllData() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
}
