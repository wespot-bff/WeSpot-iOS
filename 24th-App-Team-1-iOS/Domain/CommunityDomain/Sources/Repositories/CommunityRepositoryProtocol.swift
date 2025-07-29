//
//  CommunityRepositoryProtocol.swift
//  CommunityDomain
//
//  Created by 김도현 on 7/26/25.
//

import Foundation



public protocol CommunityRepositoryProtocol {
    func fetchCategoryItems() async throws -> [FilterChipEntity]
    func fetchCategoryDetailImtes() async throws -> [CategoryDetailEntity]
    func uploadPostItem(body: UploadPostItemRequest) async throws -> Bool
    func fetchPostImagePresignedURL(query: CreatePostImagePresignedURLQuery) async throws -> CreatePostImagePresignedURLEntity
    func fetchPostDetailItems(query: FetchPostDetailItemRequestQuery)
    func uploadPostImages(_ image: Data, presingedURL: String) async throws -> Bool
}
