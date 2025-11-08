//
//  CategoryPostFeature.swift
//  CommunityFeature
//
//  Created by 김도현 on 8/3/25.
//

import ComposableArchitecture
import CommunityDomain

public enum ReturnSource: Equatable {
    case none
    case feedDetail(needsRefresh: Bool)
    case postWrite
}



@Reducer
public struct CategoryPostFeature {
    
    @Dependency(\.fetchPostItemListUseCase) var fetchPostDetailListUseCase: FetchPostItemListUseCaseProtocol
    @Dependency(\.fetchCategoryDetailItemUseCase) var fetchCategoryDetailUseCase: FetchCategoryDetailItemUseCaseProtocol
    @Dependency(\.updatePostScrapUseCase) var updatePostScrapUseCase: UpdatePostScrapUseCaseProtocol
    @Dependency(\.updatePostLikeUseCase) var updatePostLikeUseCase: UpdatePostLikeUseCaseProtocol
    
    @ObservableState
    public struct State: Equatable {
        var chipDetails: [CategoryDetailEntity] = []
        var category: CategoryChipsEntity
        var rawPostListItems: PostListEntity? = nil
        var postListEntity: PostListEntity? = nil
        var overrides: [Int: PostLocalOverride] = [:]
        var isShowingCategorySheet: Bool = false
        var isScrap: Bool = false
        var isLike: Bool = false
        var isLoadingPage = false
        var nextCursor: Int? = nil
        var hasNext: Bool = false
        var returnSource: ReturnSource = .none
    }

    public enum Action: ViewAction {
        case view(View)
        case inner(Inner)
        case binding(BindingAction<State>)
        case `internal`(Internal)
    }
    
    @CasePathable
    public enum View: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case onAppear
        case onAppearWithRefresh
        case didSelectChip(CategoryChipsEntity)
        case didTappedCategoryButton
        case dismissCategorySheet
        case didTappedLike(Int)
        case didTappedScrap(Int)
        case likeResponseSuccess(postId: Int)
        case likeResponseFailure(postId: Int, errorMessage: String)
        case scrapResponseSuccess(postId: Int)
        case scrapResponseFailure(postId: Int, errorMessage: String)
        case loadNextPage
        case willNavigateToFeedDetail
        case didReturnFromFeedDetail(needsRefresh: Bool)
        case willNavigateToPostWrite
        case didReturnFromPostWrite
    }
    
    public enum Internal {}
    
    public enum Inner {
        case postListResponse(TaskResult<PostListEntity>, isLoadMore: Bool)
        case detailsResponse(TaskResult<[CategoryDetailEntity]>)
    }

    public init() {}

    public var body: some ReducerOf<Self> {
        BindingReducer(action: /Action.view)
        
        Reduce { state, action in
            switch action {
            case .view(.willNavigateToFeedDetail):
                state.returnSource = .feedDetail(needsRefresh: false)
                return .none
            
            case .view(.didReturnFromFeedDetail(let needsRefresh)):
                state.returnSource = .feedDetail(needsRefresh: needsRefresh)
                return .none
            
            case .view(.willNavigateToPostWrite):
                state.returnSource = .postWrite
                return .none
            
            case .view(.didReturnFromPostWrite):
                state.returnSource = .postWrite
                return .none
                
            case .view(.onAppear):
                
                switch state.returnSource {
                case .none:
                    // 최초 진입
                    guard state.postListEntity == nil else {
                        return .none
                    }
                    return loadInitialData(state: &state)
                    
                case .feedDetail(let needsRefresh):
                    state.returnSource = .none
                    if needsRefresh {
                        return loadInitialData(state: &state)
                    } else {
                        // 스크롤 위치 유지
                        return .none
                    }
                    
                case .postWrite:
                    state.returnSource = .none
                    return loadInitialData(state: &state)
                }
                
            case .view(.onAppearWithRefresh):
                return loadInitialData(state: &state)
                
            case .inner(.postListResponse(.success(let posts), let isLoadMore)):
                state.isLoadingPage = false
                state.nextCursor = posts.lastCursorId
                state.hasNext = posts.hasNext

                
                if isLoadMore {
                    if var raw = state.rawPostListItems {
                        let beforeCount = raw.items.count
                        raw.items.append(contentsOf: posts.items)
                        raw.lastCursorId = posts.lastCursorId
                        raw.hasNext = posts.hasNext
                        state.rawPostListItems = raw
                    } else {
                        state.rawPostListItems = posts
                    }
                } else {
                    state.rawPostListItems = posts
                }
                
                applyOverrides(to: &state)
                return .none
                
            case .inner(.postListResponse(.failure, _)):
                state.isLoadingPage = false
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
                
            case .view(.likeResponseSuccess(postId: _)):
                return .none
                
            case .view(.likeResponseFailure(postId: let postId, errorMessage: _)):
                if var override = state.overrides[postId] {
                    if let isLiked = override.isLiked {
                        override.isLiked = !isLiked
                        override.likeCountDelta += isLiked ? -1 : 1
                        state.overrides[postId] = override
                    }
                }
                applyOverrides(to: &state)
                return .none
                
            case .view(.scrapResponseSuccess(postId: _)):
                return .none
                
            case .view(.scrapResponseFailure(postId: let postId, _)):
                if var override = state.overrides[postId] {
                    if let isScrapped = override.isScrapped {
                        override.isScrapped = !isScrapped
                        state.overrides[postId] = override
                    }
                }
                applyOverrides(to: &state)
                return .none
                
            case .view(.didTappedCategoryButton):
                state.isShowingCategorySheet = true
                return .run { send in
                    async let detailsUseCase = fetchCategoryDetailUseCase.execute()
                    do {
                        let detailsResponse = try await detailsUseCase
                        await send(.inner(.detailsResponse(.success(detailsResponse))))
                    } catch {
                        await send(.inner(.detailsResponse(.failure(error))))
                    }
                }
                
            case .view(.dismissCategorySheet):
                state.isShowingCategorySheet = false
                return .none
                
            case .inner(.detailsResponse(.failure)):
                return .none
                
            case .inner(.detailsResponse(.success(let chipDetails))):
                state.chipDetails = chipDetails
                return .none
                
            case .view(.didSelectChip(let chip)):
                state.category = chip
                state.isShowingCategorySheet = false
                
                state.nextCursor = nil
                state.hasNext = false
                state.rawPostListItems = nil
                state.postListEntity = nil
                
                return .run { send in
                    let query = FetchPostDetailItemRequestQuery(
                        categoryId: chip.id,
                        inquirySize: 20,
                        cursorId: nil
                    )
                    async let postsUsecase = fetchPostDetailListUseCase.execute(query: query)

                    do {
                        let posts = try await postsUsecase
                        await send(.inner(.postListResponse(.success(posts), isLoadMore: false)))
                    } catch {
                        await send(.inner(.postListResponse(.failure(error), isLoadMore: false)))
                    }
                }
                
            case .view(.loadNextPage):
                guard !state.isLoadingPage, state.hasNext else {
                    return .none
                }
                
                state.isLoadingPage = true
                
                let query = FetchPostDetailItemRequestQuery(
                    categoryId: state.category.id,
                    inquirySize: 20,
                    cursorId: state.nextCursor
                )
                
                return .run { send in
                    do {
                        let response = try await fetchPostDetailListUseCase.execute(query: query)
                        await send(.inner(.postListResponse(.success(response), isLoadMore: true)))
                    } catch {
                        await send(.inner(.postListResponse(.failure(error), isLoadMore: true)))
                    }
                }
            }
        }
    }
}

extension CategoryPostFeature {
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


extension CategoryPostFeature {
    private func loadInitialData(state: inout State) -> Effect<Action> {
        state.nextCursor = nil
        state.hasNext = false
        state.rawPostListItems = nil
        state.postListEntity = nil
        
        let categoryId = state.category.id
        return .run { send in
            let query = FetchPostDetailItemRequestQuery(
                categoryId: categoryId,
                inquirySize: 20,
                cursorId: nil
            )
            do {
                let posts = try await fetchPostDetailListUseCase.execute(query: query)
                await send(.inner(.postListResponse(.success(posts), isLoadMore: false)))
            } catch {
                await send(.inner(.postListResponse(.failure(error), isLoadMore: false)))
            }
        }
    }
}
