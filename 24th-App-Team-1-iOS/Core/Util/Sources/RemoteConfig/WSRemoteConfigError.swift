//
//  WSRemoteConfigError.swift
//  Util
//
//  Created by 김도현 on 11/29/24.
//

import Foundation

//MARK: WSRemoteConfig Error
public enum WSRemoteConfigError: Error {
    /// 업데이트가 필요하지 않은 경우
    case noUpdateNeeded
    /// 최신 버전을 가져오지 못한 경우
    case notFoundVersion
    /// Firebase App Configure Setting이 잘못된 경우
    case invalidFirebaseConfigure
}

//MARK: WSRemoteConfigError description
extension WSRemoteConfigError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noUpdateNeeded:
            return "업데이트가 필요하지 않습니다."
        case .notFoundVersion:
            return "버전 정보를 가져오지 못했습니다."
        case .invalidFirebaseConfigure:
            return "Firebase 앱이 아직 구성되지 않았습니다."
        }
    }
}
