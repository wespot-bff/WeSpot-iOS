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

struct FeedDetailView: View {
    @Perception.Bindable
    public var store: StoreOf<FeedDetailFeature>
    @Environment(\.presentationMode) private var presentationMode
    @StateObject private var viewStore: ViewStore<FeedDetailFeature.State, FeedDetailFeature.Action>
    
    public init(store: StoreOf<FeedDetailFeature>) {
        self.store = store
        self._viewStore = StateObject(wrappedValue: ViewStore(store, observe: \.self))
    }
    
    var body: some View {
        ZStack {
            DesignSystemAsset.Colors.gray900.swiftUIColor
                .ignoresSafeArea()
            
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
                                    .background(Color.gray.opacity(0.3))
                                    .padding(.vertical, 16)
                                
                                commentsSection(comments: viewStore.commentItem)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                    .safeAreaInset(edge: .top, spacing: 0) {
                        Color.clear.frame(height: 120)
                    }
                }
            }
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
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .wsNavigationBar(left: {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                DesignSystemAsset.Images.icCommunityLeftArrowFiled.swiftUIImage
            }
        }, title: {
            Group {
                if let category = viewStore.postEntity?.content?.category {
                    HStack(spacing: 5) {
                        Button {
                            
                        } label: {
                            Text(category.text)
                                .foregroundColor(.init(hex: category.textColor))
                                .font(.typography(category.typography))
                            
                            DesignSystemAsset.Images.icCommuntyCategoryChipFiled.swiftUIImage
                        }
                        
                        
                    }
                }
            }
        }, right: {
            Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                DesignSystemAsset.Images.icCommunityDotFiled.swiftUIImage
            }
        })
        .onAppear {
            NotificationCenter.default.post(name: .hideTabBar, object: nil)
            viewStore.send(.view(.onAppear))
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
                    
                    VStack(alignment: .leading, spacing: 4) {
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
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 82, height: 30)
                .onTapGesture {
                    viewStore.send(.view(.didTappedCommentNotification(Int(viewStore.postId) ?? 0)))
                }
        )
    }
    
    @ViewBuilder
    private func contentView(postEntity: PostItem) -> some View {
        if let content = postEntity.content {
            VStack(alignment: .leading, spacing: 12) {
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
        LazyVGrid(columns: [
            GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
        ], spacing: 8) {
            ForEach(Array(imageUrls.enumerated()), id: \.offset) { _, url in
                AsyncImage(url: URL(string: url)) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle().fill(Color.gray.opacity(0.3))
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }
    @ViewBuilder
    private func footerView(postEntity: PostItem) -> some View {
        if let content = postEntity.content {
            HStack {
                ForEach(Array(content.footer.reactions.enumerated()), id: \.offset) { index, reaction in
                    let reaction = content.footer.reactions[index]
                    Button {
                        if reaction.type == "Like" {
                            viewStore.send(.view(.didTappedLike(postEntity.id)))
                        } else if reaction.type == "Chat" {
                            viewStore.send(.view(.didTappedChat))
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
            if updatedComment.isMine {
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text(updatedComment.nickname)
                        .foregroundColor(DesignSystemAsset.Colors.gray200.swiftUIColor)
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
                                viewStore.send(.view(.didTappedCommentLike(String(comment.id))))
                            } label: {
                                updatedComment.isLiked ? DesignSystemAsset.Images.icCommunityLikeFiled.swiftUIImage : DesignSystemAsset.Images.icCommunityUnlikeFiled.swiftUIImage
                            }
                            
                            Text("\(updatedComment.likeCount)")
                                .foregroundColor(DesignSystemAsset.Colors.gray200.swiftUIColor)
                                .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                        }
                        
                        Button {
                            
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
                        .foregroundColor(DesignSystemAsset.Colors.gray200.swiftUIColor)
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
                                // 신고 액션
                            }
                            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 11))
                            .foregroundColor(DesignSystemAsset.Colors.gray400.swiftUIColor)
                        }
                    }
                }
                
                Spacer()
            }
        }
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
            if newValue {
                isTextFieldFocused = true
            } else {
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


