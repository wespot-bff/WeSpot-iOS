//
//  UploadPostItemRequest.swift
//  CommunityDomain
//
//  Created by 김도현 on 7/28/25.
//


public struct UploadPostItemRequest: Equatable {
    public let categoryId: Int
    public let title: String
    public let description: String
    public let imagesRequest: [String]
    
    public init(
        categoryId: Int,
        title: String,
        description: String,
        imagesRequest: [String]
    ) {
        self.categoryId = categoryId
        self.title = title
        self.description = description
        self.imagesRequest = imagesRequest
    }
    
}


public struct UploadPostImageItemReqeuest: Equatable {
    public let url: String
    public let width: Int
    public let height: Int
    
    public init(url: String, width: Int, height: Int) {
        self.url = url
        self.width = width
        self.height = height
    }
}
