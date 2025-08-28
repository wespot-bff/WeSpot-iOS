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
    func fetchMyPostCommentItem() async throws -> PostListEntity
    func fetchMyPostScrapItem() async throws -> PostListEntity
    func fetchMyPostWrittenItem() async throws -> PostListEntity
    func fetchSearchPostItems(query: FetchPostSearchKeywordQuery) async throws -> PostListEntity
    func fetchPostImagePresignedURL(query: CreatePostImagePresignedURLQuery) async throws -> CreatePostImagePresignedURLEntity
    func fetchPostDetailItems(query: FetchPostDetailItemRequestQuery) async throws -> PostListEntity
    func fetchPostAllItems(query: FetchPostAllItemRequestQuery) async throws -> PostListEntity
    func fetchFeedDetailItem(postId: String) async throws -> PostItem
    
    func updateCommentNotification(_ postId: String) async throws -> Bool
    func uploadPostImages(_ image: Data, presingedURL: String) async throws -> Bool
    func updatePostLike(_ postId: Int) async throws -> Bool
    func updatePostScrap(_ postId: Int) async throws -> Bool
    func updateCommentReport(_ commentId: String) async throws -> Bool
    func updateCommentLike(_ commentId: String) async throws -> Bool
    func updatePostReport(_ postId: String) async throws -> Bool
    func updatePostBlock(_ postId: String) async throws -> Bool
    func fetchCommentItem(_ query: FetchCommentRequestQuery) async throws -> [CommentEntity]
    func createPostComment(_ body: CreatePostCommentRequest) async throws -> Bool
    
    
}
