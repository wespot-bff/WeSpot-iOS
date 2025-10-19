//
//  FetchPostDetailItemRequestDTO.swift
//  CommunityService
//
//  Created by 김도현 on 7/29/25.
//


import Foundation

public struct FetchPostDetailItemRequestDTO: Encodable {
    let categoryId: Int
    let inquirySize: Int
    let cursorId: Int?
    
    public init(categoryId: Int, inquirySize: Int, cursorId: Int?) {
        self.categoryId = categoryId
        self.inquirySize = inquirySize
        self.cursorId = cursorId
    }
}
