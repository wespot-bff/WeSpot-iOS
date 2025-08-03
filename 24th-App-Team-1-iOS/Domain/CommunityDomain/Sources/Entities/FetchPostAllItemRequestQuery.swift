//
//  FetchPostAllItemRequestQuery.swift
//  CommunityDomain
//
//  Created by 김도현 on 7/31/25.
//



public struct FetchPostAllItemRequestQuery {
    public let majorCategoryName: String
    public let countOfPostsViewed: Int?
    public let inquirySize: Int
    public let cursorId: Int?
    
    public init(
        majorCategoryName: String,
        countOfPostsViewed: Int? = nil,
        inquirySize: Int,
        cursorId: Int? = nil
    ) {
        self.majorCategoryName = majorCategoryName
        self.countOfPostsViewed = countOfPostsViewed
        self.inquirySize = inquirySize
        self.cursorId = cursorId
    }
}
