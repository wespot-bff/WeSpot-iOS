//
//  FetchPostSearchKeywordRequestDTO.swift
//  CommunityService
//
//  Created by 김도현 on 8/3/25.
//



public struct FetchPostSearchKeywordRequestDTO: Encodable {
    public let keyword: String
    
    public init(keyword: String) {
        self.keyword = keyword
    }
}
