//
//  ReportFeature.swift
//  CommunityFeature
//
//  Created by 김도현 on 9/3/25.
//

import ComposableArchitecture
import Foundation
import CommunityDomain


@Reducer
public struct ReportFeature {
    @Dependency(\.fetchReportReasonItemUseCase) var fetchReportReasonItemUseCase: FetchReportReasonItemUseCaseProtocol
    @Dependency(\.updatePostReportUseCase) var updatePostReportUseCase: UpdatePostReportUseCaseProtocol
    @Dependency(\.updateCommentReportUseCase) var updateCommentReportUseCase: UpdateCommentReportUseCaseProtocol
    
    
    @ObservableState
    public struct State: Equatable {
        var shouldDismiss: Bool = false
        var reportEntity: [ReportReason] = []
        var postId: String?
        var selectedReasonIds: Set<Int> = []
        var etcText: String = ""
        var commentId: String?
        
        var isEtcSelected: Bool {
            let etcReasonId = reportEntity.first { $0.isEditable }?.id
            return etcReasonId.map { selectedReasonIds.contains($0) } ?? false
        }
        
        var canSubmit: Bool {
            if isEtcSelected {
                return !etcText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            }
            return !selectedReasonIds.isEmpty
        }
        
        
        public init(postId: String? = nil, commentId: String? = nil) {
            self.postId = postId
            self.commentId = commentId
        }
    }
    
    public enum Action: ViewAction {
        case view(View)
        case inner(Inner)
        case binding(BindingAction<State>)
    }
    
    @CasePathable
    public enum View: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case didTappedCommentReport(Int)
        case onAppear
        case didTapReason(Int)
        case didTapSubmit
        case updateEtcText(String)
    }
    
    public enum Inner: Equatable {
        case didFetchReportReasons([ReportReason])
        case fetchReportFailed(String)
        case didFinishReporting
    }
    
    public var body: some ReducerOf<Self> {
        BindingReducer(action: /Action.view)
        
        Reduce { state, action in
            switch action {
            case .view(.onAppear):
                return .run { send in
                    do {
                        let reasons = try await fetchReportReasonItemUseCase.execute()
                        await send(.inner(.didFetchReportReasons(reasons)))
                    } catch {
                        await send(.inner(.fetchReportFailed(error.localizedDescription)))
                    }
                }
                
            case let .inner(.didFetchReportReasons(reasons)):
                state.reportEntity = reasons
                return .none
                
                
            case let .inner(.fetchReportFailed(error)):
                print("Fetch failed: \(error)")
                return .none
                
            case let .view(.didTapReason(id)):
                if state.selectedReasonIds.contains(id) {
                    state.selectedReasonIds.remove(id)
                } else {
                    state.selectedReasonIds.insert(id)
                }
                return .none
                
            case let .view(.updateEtcText(text)):
                state.etcText = text
                return .none
                
                
                
            case .view(.didTapSubmit):
                if state.postId != nil {
                    let selectedReasons = state.reportEntity.filter { state.selectedReasonIds.contains($0.id) }
                    
                    let requestItems: [ReportReasonRequestItem] = selectedReasons.map {
                        ReportReasonRequestItem(
                            reportReasonId: $0.id,
                            customReason: state.etcText.isEmpty ? nil : state.etcText
                        )
                    }
                    
                    let request = ReportReasonRequest(reportReasonRequests: requestItems)
                    

                    return .run { [postId = state.postId] send in
                        _ = try await updatePostReportUseCase.execute(postId ?? "", body: request)
                    }
                } else {
                    let selectedReasons = state.reportEntity.filter {
                        state.selectedReasonIds.contains($0.id) }
                    
                    let requestItems: [ReportReasonRequestItem] = selectedReasons.map {
                        ReportReasonRequestItem(
                            reportReasonId: $0.id,
                            customReason: state.etcText.isEmpty ? nil : state.etcText
                        )
                    }
                    
                    let request = ReportReasonRequest(reportReasonRequests: requestItems)
                    
                    print("신고 값을 확인합니다 : \(request)")
                    return .run { [commentId = state.commentId] send in
                        _ = try await updateCommentReportUseCase.execute(commentId ?? "", body: request)
                    }
                }
                
                
                
            case .inner(.didFinishReporting):
                state.shouldDismiss = true
                return .none
                
            default:
                return .none
            }
        }
    }
    
    
}
