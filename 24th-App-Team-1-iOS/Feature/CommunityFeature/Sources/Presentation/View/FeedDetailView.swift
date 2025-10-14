//
//  FeedDetailView.swift
//  CommunityFeature
//
//  Created by 김도현 on 8/18/25.
//



import SwiftUI
import DesignSystem
import ComposableArchitecture
import CommunityDomain
import Perception

class ImageViewerStore: ObservableObject {
    @Published var showImageViewer = false
    @Published var selectedImageIndex = 0
    @Published var currentImageUrls: [String] = []
    
    func showViewer(with urls: [String], at index: Int) {
        currentImageUrls = urls
        selectedImageIndex = index
        showImageViewer = true
    }
}

enum FeedAlertType: Equatable {
    case deletePost(postId: Int)
    case deleteComment(commentId: Int)
    case blockUser(userId: String)

    var title: String {
        switch self {
        case .deletePost:
            return "게시글을 삭제할까요?"
        case .deleteComment:
            return "댓글을 삭제할까요?"
        case .blockUser:
            return "해당 유저를 차단할까요?"
        }
    }

    var subtitle: String {
        switch self {
        case .deletePost:
            return "삭제된 게시글은 되돌릴 수 없어요."
        case .deleteComment:
            return "삭제된 댓글도 되돌릴 수 없어요."
        case .blockUser:
            return "해당 유저가 작성한 게시글이 보이지 않도록 숨겨드릴게요.다만, 차단 해제는 불가해요."
        }
    }
}



struct FeedDetailView: View {
    @Perception.Bindable
    public var store: StoreOf<FeedDetailFeature>
    @Environment(\.presentationMode) private var presentationMode
    @State private var showNormalAlert = false
    @StateObject private var viewStore: ViewStore<FeedDetailFeature.State, FeedDetailFeature.Action>
    @State private var currentAlertType: FeedAlertType? = nil
    @State private var showPostReportView = false
    @State private var showCommentReportView = false
    @State private var currentCommentId: String? = nil
    @State private var showCategoryMain = false
    @State private var showPostWriteView = false
    @State private var showBottomSheet = false
    @StateObject private var imageViewerStore = ImageViewerStore()
    public init(store: StoreOf<FeedDetailFeature>) {
        self.store = store
        self._viewStore = StateObject(wrappedValue: ViewStore(store, observe: \.self))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            DesignSystemAsset.Colors.gray900.swiftUIColor
                .ignoresSafeArea()
            
            NavigationLink(
                destination: PostWriteView(
                    store: .init(
                        initialState: PostWriteFeature.State(editingPost: viewStore.postEntity, isEditing: true),
                        reducer: {PostWriteFeature()})),
                isActive: $showPostWriteView,
                label: { EmptyView()}
            )
            if let categoryId = Int(viewStore.postEntity?.content?.category?.target ?? "1"),
               let categoryText = viewStore.postEntity?.content?.category?.text {
                NavigationLink(
                    destination: CategoryMainView(store: .init(initialState: CategoryMainFeature.State(category: .init(id: categoryId, text: categoryText)), reducer: {CategoryMainFeature()})),
                    isActive: $showCategoryMain,
                    label: { EmptyView()}
                )
            }
        
            GeometryReader { geometry in
                let statusBarHeight = geometry.safeAreaInsets.top
                let navBarTotalHeight = statusBarHeight + 8 + 44 + 12
                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        if let postEntity = viewStore.postEntity {
                            VStack(spacing: 0) {
                                headerView(postEntity: postEntity)
                                contentView(postEntity: postEntity)
                                footerView(postEntity: postEntity)
                                
                                Divider()
                                    .frame(height: 8)
                                    .background(DesignSystemAsset.Colors.gray700.swiftUIColor)
                                    .padding(.horizontal, -16)
                                    .padding(.vertical, 16)
                                
                                commentsSection(comments: viewStore.commentItem)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .safeAreaInset(edge: .top, spacing: 0) {
                        Color.clear.frame(height: 120)
                    }
                    .safeAreaInset(edge: .bottom, spacing: 0) {
                        Color.clear.frame(height: 60)
                    }
                }
            }
            .customAlert(
                isPresented: $showNormalAlert,
                title: currentAlertType?.title ?? "",
                message: currentAlertType?.subtitle ?? "",
                primaryButtonText: "네",
                secondaryButtonText: "아니요",
                style: .normal,
                primaryAction: {
                    switch currentAlertType {
                    case .deleteComment(let id):
                        viewStore.send(.view(.didTappedDeleteComment(id)))
                        
                    case .deletePost(let id):
                        viewStore.send(.view(.didTappedDeletePost(id)))
                        
                    case .blockUser(let userId):
                        showPostReportView = true
                        
                    case .none:
                        break
                    }
                },
                secondaryAction: {
                    viewStore.send(.view(.cancelDeleteComment))
                }
            )
            .background(
                Group {
                    NavigationLink(
                        destination: ReportReasonView(
                            store: .init(
                                initialState: ReportFeature.State(postId: viewStore.postId),
                                reducer: { ReportFeature() }
                            )
                        ),
                        isActive: $showPostReportView
                    ) {
                        EmptyView()
                    }
                    
                    // 댓글 신고용 NavigationLink
                    NavigationLink(
                        destination: ReportReasonView(
                            store: .init(
                                initialState: ReportFeature.State(commentId: currentCommentId),
                                reducer: { ReportFeature() }
                            )
                        ),
                        isActive: $showCommentReportView
                    ) {
                        EmptyView()
                    }
                }
            )
            VStack {
                ChatInputView(
                    text: viewStore.binding(
                        get: \.chatInputText,
                        send: { text in
                            FeedDetailFeature.Action.view(.chatInputTextChanged(text))
                        }
                    ),
                    isActive: viewStore.binding(
                        get: \.isShowingChatTextField,
                        send: { isActive in
                            if isActive {
                                return FeedDetailFeature.Action.view(.didTappedChat)
                            } else {
                                return FeedDetailFeature.Action.view(.dismissChatTextField)
                            }
                        }
                    ),
                    onSend: { message in
                        viewStore.send(.view(.didTappedSendChat(viewStore.postId, message)))
                    },
                    onDismiss: {
                        viewStore.send(.view(.dismissChatTextField))
                    }
                )
                .keyboardAware()
            }
            .ignoresSafeArea(.keyboard)
            
            .sheet(isPresented: $showBottomSheet) {
                VStack(spacing: 0) {
                    if viewStore.postEntity?.isMyPost == true {
                        Button {
                            showBottomSheet = false
                            showPostWriteView = true
                        } label: {
                            Text("수정하기")
                                .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                .frame(maxWidth: .infinity, minHeight: 52)
                        }
                        .background(DesignSystemAsset.Colors.gray600.swiftUIColor)
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 0.5)
                        
                        Button {
                            showBottomSheet = false
                            if let postId = viewStore.postEntity?.id {
                                currentAlertType = .deletePost(postId: postId)
                                showNormalAlert = true
                            }
                        } label: {
                            Text("삭제하기")
                                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                                .frame(maxWidth: .infinity, minHeight: 52)
                        }
                        .background(DesignSystemAsset.Colors.gray600.swiftUIColor)
                    } else {
                        Button {
                            showBottomSheet = false
                            if let postEntity = viewStore.postEntity {
                                currentAlertType = .blockUser(userId: String(postEntity.id))
                                showNormalAlert = true
                            }
                        } label: {
                            Text("신고하기")
                                .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                .frame(maxWidth: .infinity, minHeight: 52)
                        }
                        .background(DesignSystemAsset.Colors.gray600.swiftUIColor)
                        
                        Rectangle()
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 0.5)
                        
                        Button {
                            showBottomSheet = false
                            if let postEntity = viewStore.postEntity {
                                currentAlertType = .blockUser(userId: String(postEntity.id))
                                showNormalAlert = true
                            }
                        } label: {
                            Text("차단하기")
                                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 16))
                                .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                                .frame(maxWidth: .infinity, minHeight: 52)
                        }
                        .background(DesignSystemAsset.Colors.gray600.swiftUIColor)
                    }
                }
                .frame(maxWidth: .infinity)
                .background(DesignSystemAsset.Colors.gray600.swiftUIColor)
                .presentationDragIndicator(.visible)
                .presentationDetents([.height(156)])
                .presentationBackground(DesignSystemAsset.Colors.gray600.swiftUIColor)
                .presentationCornerRadius(25)
                .interactiveDismissDisabled(false)
            }
            if let toast = viewStore.toast {
                BBToastView(type: toast)
                    .padding(.top, (UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0) + 40)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: viewStore.toast)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            viewStore.send(.view(.hideToast))
                        }
                    }
            }
        }
        .fullScreenCover(isPresented: $imageViewerStore.showImageViewer) {
            ImageViewerView(
                imageUrls: imageViewerStore.currentImageUrls,
                initialIndex: imageViewerStore.selectedImageIndex,
                isPresented: $imageViewerStore.showImageViewer
            )
        }
        .onChange(of: viewStore.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                presentationMode.wrappedValue.dismiss()
            }
        }
        .wsNavigationBar(left: {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                DesignSystemAsset.Images.arrow.swiftUIImage
            }
        }, title: {
            HStack(spacing: 5) {
                if let category = viewStore.postEntity?.content?.category {
                    Button {
                        showCategoryMain = true
                    } label: {
                        HStack(spacing: 4) {
                            Text(category.text)
                                .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 14))

                            DesignSystemAsset.Images.icCommuntyCategoryChipFiled.swiftUIImage
                        }
                    }
                }
            }
        }, right: {
            Button {
                showBottomSheet = true
            } label: {
                DesignSystemAsset.Images.icCommunityDotFiled.swiftUIImage
            }
        })
        .onAppear {
            NotificationCenter.default.post(name: .hideTabBar, object: nil)
            viewStore.send(.view(.onAppear))
            viewStore.send(.view(.didTappedChat))
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(true)
    }
    
    @ViewBuilder
    private func headerView(postEntity: PostItem) -> some View {
        if let content = postEntity.content {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    AsyncImage(url: URL(string: content.header.profileImageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: CGFloat(content.header.profileImageWidth),
                           height: CGFloat(content.header.profileImageHeight))
                    .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(content.header.nickname.text)
                            .foregroundColor(.token(content.header.nickname.color))
                            .font(.typography(content.header.nickname.typography))
                        
                        Text(content.header.createdAt.text)
                            .foregroundColor(.token(content.header.createdAt.color))
                            .font(.typography(content.header.createdAt.typography))
                    }
                    
                    Spacer()
                    
                    if let button = content.header.button {
                        headerButtonView(button: button)
                    }
                }
            }
            .padding(.top, 16)
        } else {
            EmptyView()
        }
    }
    
    
    @ViewBuilder
    private func headerButtonView(button: ButtonEntity) -> some View {
        HStack(spacing: 4) {
            if let icon = button.icon {
                AsyncImage(url: URL(string: icon.url)) { image in
                    image
                        .resizable()
                        .renderingMode(.template)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(button.isSelected ?? false ? DesignSystemAsset.Colors.primary300.swiftUIColor : DesignSystemAsset.Colors.gray400.swiftUIColor)
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.3))
                }
                .frame(width: 16, height: 16)
            }
            
            if let title = button.title {
                Text(title.text)
                    .foregroundColor(.token(title.color))
                    .font(.typography(title.typography))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 82, height: 30)
                .onTapGesture {
                    if viewStore.isNotification {
                        viewStore.send(.view(.showToast(.success("이 글의 댓글 업데이트 알림을 받습니다."))))
                    } else {
                        viewStore.send(.view(.showToast(.error("이 글의 댓글 업데이트 알림을 받습니다."))))
                    }
                    
                    viewStore.send(.view(.didTappedCommentNotification(Int(viewStore.postId) ?? 0)))
                }
        )
    }
    
    @ViewBuilder
    private func contentView(postEntity: PostItem) -> some View {
        if let content = postEntity.content {
            VStack(alignment: .leading, spacing: 12) {
                let _ = print("본문 텍스트 폰트 확인합니다 \(content.info.title?.typography)")
                if let title = content.info.title {
                    Text(title.text)
                        .foregroundColor(.token(title.color))
                        .font(.typography(title.typography))
                        .lineLimit(title.maxLine)
                }
                
                Text(content.info.description.text)
                    .foregroundColor(.token(content.info.description.color))
                    .font(.typography(content.info.description.typography))
                    .lineLimit(content.info.description.maxLine)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                if let contentSection = content.contentSection {
                    switch contentSection {
                    case .images(let imageResources):
                        let urls = imageResources.map { $0.url }
                        imageGridView(imageUrls: urls)
                    }
                }
            }
            .padding(.vertical, 16)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func imageGridView(imageUrls: [String]) -> some View {
        if imageUrls.count == 1 {
            AsyncImage(url: URL(string: imageUrls.first ?? "")) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle().fill(Color.gray.opacity(0.3))
            }
            .frame(width: 336, height: 336)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onTapGesture {
                imageViewerStore.showViewer(with: imageUrls, at: 0)
            }
        } else {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(imageUrls.enumerated()), id: \.offset) { index, url in
                        AsyncImage(url: URL(string: url)) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle().fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 336, height: 336)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .onTapGesture {
                            imageViewerStore.showViewer(with: imageUrls, at: index)
                        }
                    }
                }
                .padding(.horizontal, 10)
            }
        }
    }

    @ViewBuilder
    private func footerView(postEntity: PostItem) -> some View {
        if let content = postEntity.content {
            HStack(spacing: 10) {
                ForEach(Array(content.footer.reactions.enumerated()), id: \.offset) { index, reaction in
                    let reaction = content.footer.reactions[index]
                    Button {
                        if reaction.type == "Like" {
                            viewStore.send(.view(.didTappedLike(postEntity.id)))
                        }
                    } label: {
                        HStack(spacing: 4) {
                            AsyncImage(url: URL(string: reaction.iconURL)) { image in
                                image
                                    .resizable()
                                    .renderingMode(.template)
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(reaction.selected ? DesignSystemAsset.Colors.primary300.swiftUIColor : DesignSystemAsset.Colors.gray100.swiftUIColor)
                            } placeholder: {
                                Rectangle().fill(Color.gray.opacity(0.3))
                            }
                            .frame(width: 20, height: 20)
                            
                            Text(reaction.count.text)
                                .foregroundColor(.token(reaction.count.color))
                                .font(.typography(reaction.count.typography))
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                
                Spacer()
                
                Button {
                    viewStore.send(.view(.didTappedScrap(postEntity.id)))
                } label: {
                    AsyncImage(url: URL(string: content.footer.scrap.iconURL)) { image in
                        image
                            .resizable()
                            .renderingMode(.template)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(content.footer.scrap.selected ? DesignSystemAsset.Colors.primary300.swiftUIColor : DesignSystemAsset.Colors.gray100.swiftUIColor)
                    } placeholder: {
                        Rectangle().fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 24, height: 24)
                    Text("스크랩")
                        .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                        .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 13))
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, 16)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func commentsSection(comments: [CommentEntity]) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(comments, id: \.id) { comment in
                commentBubbleView(comment: comment)
            }
        }
    }
    
    @ViewBuilder
    private func commentBubbleView(comment: CommentEntity) -> some View {
        let updatedComment = store.commentsForUI.first(where: { $0.id == comment.id }) ?? comment
        
        HStack(alignment: .top, spacing: 0) {
            
            
            if updatedComment.isDeleted {
                HStack {
                    if updatedComment.isMine { Spacer() }

                    VStack(alignment: updatedComment.isMine ? .trailing : .leading, spacing: 4) {
                        
                        Text("익명")
                            .foregroundColor(DesignSystemAsset.Colors.gray200.swiftUIColor)
                            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 14))

                        Text("작성자가 삭제한 댓글입니다.")
                            .foregroundColor(DesignSystemAsset.Colors.white.swiftUIColor)
                            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(DesignSystemAsset.Colors.gray600.swiftUIColor)
                            )
                            .frame(
                                maxWidth: UIScreen.main.bounds.width * 0.7,
                                alignment: updatedComment.isMine ? .trailing : .leading
                            )

                        Text(updatedComment.createdAt)
                            .foregroundColor(DesignSystemAsset.Colors.gray400.swiftUIColor)
                            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                    }

                    if !updatedComment.isMine { Spacer() }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                Circle()
                    .fill(DesignSystemAsset.Colors.gray300.swiftUIColor)
                    .frame(width: 32, height: 32)
                
                

            } else {
                if updatedComment.isMine {
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(updatedComment.nickname)
                            .foregroundColor(updatedComment.nickname == "익명의 글쓴이" ? DesignSystemAsset.Colors.primary300.swiftUIColor : DesignSystemAsset.Colors.gray200.swiftUIColor)
                            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                        
                        Text(updatedComment.content)
                            .foregroundColor(DesignSystemAsset.Colors.white.swiftUIColor)
                            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(DesignSystemAsset.Colors.gray600.swiftUIColor)
                            )
                            .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .trailing)
                        
                        HStack(spacing: 8) {
                            Text(updatedComment.createdAt)
                                .foregroundColor(DesignSystemAsset.Colors.gray400.swiftUIColor)
                                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                            
                            HStack(spacing: 4) {
                                Button {
                                    viewStore.send(.view(.didTappedCommentLike(String(updatedComment.id))))
                                } label: {
                                    updatedComment.isLiked ? DesignSystemAsset.Images.icCommunityLikeFiled.swiftUIImage : DesignSystemAsset.Images.icCommunityUnlikeFiled.swiftUIImage
                                }
                                
                                Text("\(updatedComment.likeCount)")
                                    .foregroundColor(DesignSystemAsset.Colors.gray200.swiftUIColor)
                                    .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                            }
                            
                            Button {
                                showNormalAlert = true
                                currentAlertType = .deleteComment(commentId: updatedComment.id)
                            } label: {
                                Text("・ 삭제")
                                    .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                                    .foregroundColor(DesignSystemAsset.Colors.gray400.swiftUIColor)
                            }

                        }
                    }
                    AsyncImage(url: updatedComment.profileImageURL) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Circle().fill(Color.gray.opacity(0.3))
                    }
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .padding(.leading, 8)
                    
                } else {
                    if updatedComment.isReported {
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 32, height: 32)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("익명")
                                    .foregroundColor(DesignSystemAsset.Colors.gray400.swiftUIColor)
                                    .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 13))

                                Text("신고 누적으로 숨김 처리된 채팅입니다.")
                                    .foregroundColor(DesignSystemAsset.Colors.gray400.swiftUIColor)
                                    .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(DesignSystemAsset.Colors.gray500.swiftUIColor)
                                    )
                                    .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)

                                Text(updatedComment.createdAt)
                                    .foregroundColor(DesignSystemAsset.Colors.gray400.swiftUIColor)
                                    .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                            }

                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    } else {
                        AsyncImage(url: updatedComment.profileImageURL) { image in
                            image.resizable().aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle().fill(Color.gray.opacity(0.3))
                        }
                        .frame(width: 32, height: 32)
                        .clipShape(Circle())
                        .padding(.trailing, 8)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(updatedComment.nickname)
                                .foregroundColor(updatedComment.nickname == "익명의 글쓴이" ? DesignSystemAsset.Colors.primary300.swiftUIColor : DesignSystemAsset.Colors.gray200.swiftUIColor)
                                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                            
                            Text(updatedComment.content)
                                .foregroundColor(DesignSystemAsset.Colors.white.swiftUIColor)
                                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(DesignSystemAsset.Colors.gray600.swiftUIColor)
                                )
                                .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: .leading)
                            
                            HStack(spacing: 8) {
                                Text(updatedComment.createdAt)
                                    .foregroundColor(DesignSystemAsset.Colors.gray400.swiftUIColor)
                                    .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                                
                                HStack(spacing: 4) {
                                    Button {
                                        viewStore.send(.view(.didTappedCommentLike(String(comment.id))))
                                    } label: {
                                        updatedComment.isLiked ? DesignSystemAsset.Images.icCommunityLikeFiled.swiftUIImage : DesignSystemAsset.Images.icCommunityUnlikeFiled.swiftUIImage
                                    }
                                    
                                        
                                    Text("\(updatedComment.likeCount)")
                                        .foregroundColor(DesignSystemAsset.Colors.gray200.swiftUIColor)
                                        .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                                    }
                                
                                if !updatedComment.isReported {
                                    Button("신고") {
                                        currentCommentId = String(updatedComment.id)
                                        showCommentReportView = true
                                    }
                                    .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                                    .foregroundColor(DesignSystemAsset.Colors.gray400.swiftUIColor)
                                }
                            }
                        }
                    }

                    
                    Spacer()
                }
            }
            

        }
    }
}


public enum ToastType: Equatable {
    case success(String)
    case error(String)

    var icon: Image {
        switch self {
        case .success: return DesignSystemAsset.Images.checkmarkFillPositive.swiftUIImage
        case .error: return DesignSystemAsset.Images.exclamationmarkFillDestructive.swiftUIImage
        }
    }

    var backgroundColor: Color {
        switch self {
        case .success: return DesignSystemAsset.Colors.gray100.swiftUIColor
        case .error: return DesignSystemAsset.Colors.gray100.swiftUIColor
        }
    }

    var text: String {
        switch self {
        case let .success(message): return message
        case let .error(message): return message
        }
    }
}


struct BBToastView: View {
    let type: ToastType

    var body: some View {
        HStack(spacing: 8) {
            type.icon
                .resizable()
                .frame(width: 20, height: 20)
            
            Text(type.text)
                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                .foregroundColor(DesignSystemAsset.Colors.gray900.swiftUIColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(type.backgroundColor)
        )
        .padding(.top, 20)
        .padding(.horizontal, 20)
    }
}





struct ChatInputView: View {
    @Binding var text: String
    @Binding var isActive: Bool
    let onSend: (String) -> Void
    let onDismiss: () -> Void

    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            if isActive {
                HStack {
                    HStack(spacing: 12) {
                        TextField("익명으로 자유롭게 의견을 나눠보세요", text: $text)
                            .textFieldStyle(PlainTextFieldStyle())
                            .foregroundColor(.white)
                            .font(.system(size: 16))
                            .focused($isTextFieldFocused)
                            .onSubmit {
                                sendMessage()
                            }

                        Button {
                            sendMessage()
                            
                        } label: {
                            Image(systemName: "arrow.up")
                                .foregroundColor(.black)
                                .font(.system(size: 16, weight: .medium))
                                .frame(width: 24, height: 24)
                                .background(
                                    Circle()
                                        .fill(hasText ? Color(red: 0.9, green: 1.0, blue: 0.4) : Color.gray.opacity(0.3))
                                )
                        }
                        .disabled(!hasText)
                    }
                    .padding(.horizontal, 16)
                    .frame(height: 42)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(Color(red: 0.2, green: 0.2, blue: 0.2))
                    )
                }
                .padding(.horizontal, 16)
                .background(DesignSystemAsset.Colors.gray900.swiftUIColor)
                .animation(.easeInOut(duration: 0.2), value: isActive)
            }
        }
        .clipped()
        .onChange(of: isActive) { newValue in
            if !newValue {
                isTextFieldFocused = false
                onDismiss()
            }
        }
        .onTapGesture {
            
        }

    }

    private var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func sendMessage() {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        onSend(trimmedText)
        text = ""
        isActive = false
    }
}



extension View {
    func customAlert(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        primaryButtonText: String = "네",
        secondaryButtonText: String = "아니요",
        style: CustomAlert.AlertStyle = .normal,
        primaryAction: @escaping () -> Void = {},
        secondaryAction: @escaping () -> Void = {}
    ) -> some View {
        self.overlay(
            Group {
                if isPresented.wrappedValue {
                    CustomAlert(
                        title: title,
                        message: message,
                        primaryButtonText: primaryButtonText,
                        secondaryButtonText: secondaryButtonText,
                        primaryAction: primaryAction,
                        secondaryAction: secondaryAction,
                        style: style,
                        isPresented: isPresented
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.8)),
                        removal: .opacity.combined(with: .scale(scale: 0.8))
                    ))
                }
            }
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isPresented.wrappedValue)
    }
}



struct CustomAlert: View {
    let title: String
    let message: String
    let primaryButtonText: String
    let secondaryButtonText: String
    let primaryAction: () -> Void
    let secondaryAction: () -> Void
    let style: AlertStyle
    @Binding var isPresented: Bool

    enum AlertStyle {
        case normal
        case destructive
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            
            VStack(spacing: 0) {
                VStack(spacing: 8) {
                    Text(title)
                        .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 20))
                        .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)

                    Text(message)
                        .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                        .foregroundColor(DesignSystemAsset.Colors.gray300.swiftUIColor)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .padding(.top, 24)
                .padding(.bottom, 20)

                HStack(spacing: 12) {
                    Button(action: {
                        withAnimation { isPresented = false }
                        secondaryAction()
                    }) {
                        Text(secondaryButtonText)
                            .font(.system(size: 16))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.2))
                            )
                    }

                    Button(action: {
                        withAnimation { isPresented = false }
                        primaryAction()
                    }) {
                        Text(primaryButtonText)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(primaryButtonColor)
                            )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(alertBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(borderColor, lineWidth: style == .destructive ? 2 : 0)
                    )
            )
            .padding(.horizontal, 40)
            .transition(.scale)
            .zIndex(999)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
    }

    private var alertBackgroundColor: Color {
        switch style {
        case .normal:
            return Color(red: 0.25, green: 0.25, blue: 0.27)
        case .destructive:
            return Color(red: 0.2, green: 0.2, blue: 0.22)
        }
    }

    private var primaryButtonColor: Color {
        switch style {
        case .normal, .destructive:
            return Color(red: 0.85, green: 0.85, blue: 0.4)
        }
    }

    private var borderColor: Color {
        switch style {
        case .normal:
            return Color.clear
        case .destructive:
            return Color.purple.opacity(0.6)
        }
    }
}




struct FeedBottomSheetView: View {
    let items: [String]
    let action: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { index in
                Button {
                    action(index)
                    dismiss()
                } label: {
                    HStack {
                        Text(items[index])
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(Color(hex: "#2B2B2B"))
                }

                if index < items.count - 1 {
                    Divider()
                        .frame(height: 0.5)
                        .background(Color.white.opacity(0.2))
                }
            }
        }
        .background(Color(hex: "#2B2B2B"))
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = 10.0
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}




struct ImageViewerView: View {
    let imageUrls: [String]
    let initialIndex: Int
    @Binding var isPresented: Bool
    
    init(imageUrls: [String], initialIndex: Int, isPresented: Binding<Bool>) {
        self.imageUrls = imageUrls
        self.initialIndex = initialIndex
        self._isPresented = isPresented
    }
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea(.all)
            
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        DesignSystemAsset.Images.icCommunityXmarkFiled.swiftUIImage
                            .foregroundColor(.white)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 16)
                }
                
                Spacer()
                
                if imageUrls.indices.contains(initialIndex) {
                    AsyncImage(url: URL(string: imageUrls[initialIndex])) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
                                .clipped()
                        case .failure(_):
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.width - 40)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo")
                                            .font(.system(size: 50))
                                            .foregroundColor(.white)
                                        Text("이미지를 불러올 수 없습니다")
                                            .foregroundColor(.white)
                                            .font(.caption)
                                    }
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                
                Spacer()
            }
        }
        .onAppear {
            print("ImageViewerView appeared with URL: \(imageUrls.indices.contains(initialIndex) ? imageUrls[initialIndex] : "Invalid index")")
        }
    }
}
