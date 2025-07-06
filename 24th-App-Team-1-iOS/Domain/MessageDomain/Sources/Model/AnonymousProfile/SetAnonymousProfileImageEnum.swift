//
//  SetAnonymousProfileImageEnum.swift
//  MessageDomain
//
//  Created by 최지철 on 6/17/25.
//

import Foundation

public enum SetAnonymousProfileImageEnum: CaseIterable {
    case setGalleryImage
    case setBasicProfileImage
    
    public var title: String {
        switch self {
        case .setGalleryImage:
            return "앨범에서 사진 선택"
        case .setBasicProfileImage:
            return "기본 이미지 적용"
        }
    }
}
