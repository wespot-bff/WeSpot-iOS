//
//  FetchPostDetailItemRequestQuery.swift
//  CommunityDomain
//
//  Created by 김도현 on 7/29/25.
//


import Foundation

public struct FetchPostDetailItemRequestQuery {
    public let categoryId: Int
    public let inquirySize: Int
    public let cursorId: Int?
    
    public init(categoryId: Int, inquirySize: Int, cursorId: Int?) {
        self.categoryId = categoryId
        self.inquirySize = inquirySize
        self.cursorId = cursorId
    }
}
