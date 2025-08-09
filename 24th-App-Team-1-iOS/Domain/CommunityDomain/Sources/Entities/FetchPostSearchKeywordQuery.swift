//
//  FetchPostSearchKeywordQuery.swift
//  CommunityDomain
//
//  Created by 김도현 on 8/3/25.
//

import Foundation


public struct FetchPostSearchKeywordQuery {
    public let keyword: String
    
    public init(keyword: String) {
        self.keyword = keyword
    }
}
