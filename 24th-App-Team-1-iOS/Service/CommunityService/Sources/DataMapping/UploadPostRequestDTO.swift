//
//  UploadPostRequestDTO.swift
//  CommunityService
//
//  Created by 김도현 on 7/28/25.
//


public struct UploadPostRequestDTO: Encodable {
    public let categoryId: Int
    public let title: String
    public let description: String
    public let imagesRequest: [UploadPostImageRequestDTO]
}

public struct UploadPostImageRequestDTO: Encodable {
    public let url: String
//    public let width: Int
//    public let height: Int
}
