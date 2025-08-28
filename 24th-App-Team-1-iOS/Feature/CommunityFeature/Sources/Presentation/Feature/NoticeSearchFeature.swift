//
//  NoticeSearchFeature.swift
//  CommunityFeature
//
//  Created by 김도현 on 8/3/25.
//

import ComposableArchitecture

import CommunityDomain

private enum SearchID { static let keyword = "search-keyword" }

@Reducer
public struct NoticeSearchFeature {
    @Dependency(\.fetchSearchPostItemUseCase) var fetchSearchPostItemUseCase: FetchSearchPostItemUseCaseProtocol
    @Dependency(\.updatePostScrapUseCase) var updatePostScrapUseCase: UpdatePostScrapUseCaseProtocol
    @Dependency(\.updatePostLikeUseCase) var updatePostLikeUseCase: UpdatePostLikeUseCaseProtocol

    public struct State: Equatable {
        var postListEntity: PostListEntity? = nil
        var rawPostListItems: PostListEntity? = nil
        var searchKeyword: String = ""
        var overrides: [Int: PostLocalOverride] = [:]
    }

    public enum Action: ViewAction {
        case view(View)
        case inner(Inner)
        case binding(BindingAction<State>)
    }

    @CasePathable
    public enum View: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case didSearchKeyword(String)
        case likeResponseSuccess(postId: Int)
        case likeResponseFailure(postId: Int, errorMessage: String)
        case scrapResponseSuccess(postId: Int)
        case scrapResponseFailure(postId: Int, errorMessage: String)
        case didTappedLike(Int)
        case didTappedScrap(Int)
    }

    public enum Inner {
        case postListResponse(TaskResult<PostListEntity>)
    }

    public var body: some ReducerOf<Self> {
        BindingReducer(action: /Action.view)

        Reduce { state, action in
            switch action {
            case .view(.didSearchKeyword(let keyword)):
                state.searchKeyword = keyword
                
                guard !keyword.isEmpty, keyword.count >= 2 else {
                    return .none
                }

                return .run { send in
                    try await Task.sleep(nanoseconds: 300_000_000)
                    let query = FetchPostSearchKeywordQuery(keyword: keyword)
                    do {
                        let posts = try await fetchSearchPostItemUseCase.execute(query: query)
                        await send(.inner(.postListResponse(.success(posts))))
                    } catch {
                        await send(.inner(.postListResponse(.failure(error))))
                    }
                }
                .cancellable(id: SearchID.keyword, cancelInFlight: true)
            case .inner(.postListResponse(.success(let posts))):
                var merged = posts
                merged.items = merged.items.map { element in
                    switch element {
                    case .post(var post):
                        guard let content = post.content else { return element }
                        if let override = state.overrides[post.id] {
                            var newFooter = content.footer
                            
                            if let isLiked = override.isLiked,
                               let likeIdx = newFooter.reactions.firstIndex(where: { $0.type == "Like" }) {
                                var like = newFooter.reactions[likeIdx]
                                like.selected = isLiked
                                if let baseCount = Int(like.count.text.replacingOccurrences(of: ",", with: "")) {
                                    let final = baseCount + override.likeCountDelta
                                    like.count = StyledText(
                                        text: "\(max(0, final))",
                                        color: like.count.color,
                                        typography: like.count.typography,
                                        maxLine: like.count.maxLine
                                    )
                                }
                                newFooter.reactions[likeIdx] = like
                            }
                            
                            if let isScrapped = override.isScrapped {
                                let old = newFooter.scrap
                                newFooter.scrap = Scrap(
                                    iconURL: old.iconURL,
                                    iconColor: old.iconColor,
                                    selected: isScrapped
                                )
                            }
                            
                            let newContent = PostContent(
                                category: content.category,
                                header: content.header,
                                info: content.info,
                                contentSection: content.contentSection,
                                footer: newFooter,
                                button: content.button
                            )
                            post = PostItem(id: post.id, type: post.type, content: newContent)
                            return .post(post)
                        }
                        state.rawPostListItems = posts
                        applyOverrides(to: &state)
                        return .post(post)
                    default:
                        return element
                    }
                }
                state.postListEntity = merged
                return .none

            case .inner(.postListResponse(.failure)):
                return .none

            case .view(.binding):
                return .none

            case .binding:
                return .none
            case .view(.didTappedLike(let postId)):
                if var override = state.overrides[postId] {
                    let wasLiked = override.isLiked ?? false
                    override.isLiked = !wasLiked
                    override.likeCountDelta += wasLiked ? -1 : 1
                    state.overrides[postId] = override
                } else {
                    state.overrides[postId] = PostLocalOverride(isLiked: true, likeCountDelta: 1, isScrapped: nil)
                }
                applyOverrides(to: &state)
                
                return .run { send in
                    do {
                        print("낙관적 업데이트 좋아요 ID : \(postId)")
                        try await updatePostLikeUseCase.execute(postId: postId)
                        await send(.view(.likeResponseSuccess(postId: postId)))
                    } catch {
                        await send(.view(.likeResponseFailure(postId: postId, errorMessage: error.localizedDescription)))
                    }
                }
                
            case .view(.didTappedScrap(let postId)):
                if var override = state.overrides[postId] {
                    if let current = override.isScrapped {
                        override.isScrapped = !current
                    } else {
                        override.isScrapped = true
                    }
                    state.overrides[postId] = override
                } else {
                    state.overrides[postId] = PostLocalOverride(isLiked: nil, likeCountDelta: 0, isScrapped: true)
                }
                applyOverrides(to: &state)
                
                return .run { send in
                    do {
                        try await updatePostScrapUseCase.execute(postId: postId)
                        await send(.view(.scrapResponseSuccess(postId: postId)))
                    } catch {
                        await send(.view(.scrapResponseFailure(postId: postId, errorMessage: error.localizedDescription)))
                    }
                }
            case .view(.likeResponseSuccess(postId: let postId)):
                return .none
            case .view(.likeResponseFailure(postId: let postId, errorMessage: let errorMessage)):
                if var override = state.overrides[postId] {
                    if let isLiked = override.isLiked {
                        override.isLiked = !isLiked
                        override.likeCountDelta += isLiked ? -1 : 1
                        state.overrides[postId] = override
                    }
                }
                applyOverrides(to: &state)
                return .none
            case .view(.scrapResponseSuccess(postId: let postId)):
                return .none
            case .view(.scrapResponseFailure(postId: let postId, errorMessage: let errorMessage)):
                if var override = state.overrides[postId] {
                    if let isScrapped = override.isScrapped {
                        override.isScrapped = !isScrapped
                        state.overrides[postId] = override
                    }
                }
                applyOverrides(to: &state)
                return .none
            }
        }
    }
}


extension NoticeSearchFeature {
    func applyOverrides(to state: inout State) {
        guard let raw = state.rawPostListItems else {
            state.postListEntity = nil
            return
        }
        var merged = raw
        
        for (index, element) in merged.items.enumerated() {
            if case .post(var post) = element, let content = post.content {
                if let override = state.overrides[post.id] {
                    var newFooter = content.footer
                    
                    if let isScrapped = override.isScrapped {
                        let old = newFooter.scrap
                        newFooter.scrap = Scrap(
                            iconURL: old.iconURL,
                            iconColor: old.iconColor,
                            selected: isScrapped
                        )
                    }
                    
                    if let isLiked = override.isLiked,
                       let likeIdx = newFooter.reactions.firstIndex(where: { $0.type == "Like" }) {
                        var like = newFooter.reactions[likeIdx]
                        let baseCount = Int(like.count.text.replacingOccurrences(of: ",", with: "")) ?? 0
                        let adjustedCount = baseCount + override.likeCountDelta
                        like.selected = isLiked
                        like.count = StyledText(
                            text: "\(max(0, adjustedCount))",
                            color: like.count.color,
                            typography: like.count.typography,
                            maxLine: like.count.maxLine
                        )
                        newFooter.reactions[likeIdx] = like
                    }
                    
                    let newContent = PostContent(
                        category: content.category,
                        header: content.header,
                        info: content.info,
                        contentSection: content.contentSection,
                        footer: newFooter,
                        button: content.button
                    )
                    post = PostItem(id: post.id, type: post.type, content: newContent)
                    merged.items[index] = .post(post)
                }
            }
        }
        state.postListEntity = merged
    }
}
