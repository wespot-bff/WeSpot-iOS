//
//  MainNoticeBoardView.swift
//  CommunityFeature
//
//  Created by 김도현 on 7/15/25.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture
import CommunityDomain
import Extensions
import Util
import NotificationFeature


public struct MainNoticeBoardView: View {
    @State private var showSearch = false
    @State private var showWrite = false
    @State private var showMyCategory = false
    @Perception.Bindable
    var store: StoreOf<MainNoticeBoardFeature>
    @StateObject private var viewStore: ViewStore<MainNoticeBoardFeature.State, MainNoticeBoardFeature.Action>
    @State private var showCategoryPost = false
    @State private var showNotification = false
    @State private var selectedDetailChip: CategoryChipsEntity? = nil
    public init(store: StoreOf<MainNoticeBoardFeature>) {
        self.store = store
        self._viewStore = StateObject(wrappedValue: ViewStore(store, observe: \.self))
    }
    
    public var body: some View {
        GeometryReader { geo in
            let topInset     = geo.safeAreaInsets.top
            let navBarHeight = topInset + 8 + 44 + 12
            
            NavigationView {
                ZStack(alignment: .top) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            Color.clear
                                .frame(height: navBarHeight - 10)
                            CategorySelectorWithDropdown(
                                chips: viewStore.filterChips, selected: viewStore.selectedChip) { chip in
                                    viewStore.send(.view(.didSelectChip(chip)))
                                } onDropdownTap: {
                                    viewStore.send(.view(.didTappedCategoryButton))
                                }
                                .padding(.horizontal, 20)
                            
                            LazyVStack(alignment: .leading, spacing: 0) {
                                if let list = viewStore.postListItems {
                                    ForEach(list.items, id: \.id) { element in
                                        switch element {
                                        case .post(let post):
                                            if let content = post.content {
                                                NavigationLink(
                                                    destination: FeedDetailView(
                                                        store: .init(
                                                            initialState: FeedDetailFeature.State(postId: String(post.id)),
                                                            reducer: { FeedDetailFeature() }
                                                        )
                                                    )
                                                ) {
                                                    PostView(content: content, postId: post.id) {
                                                        
                                                    } onTapLike: {
                                                        viewStore.send(.view(.didTappedLike(post.id)))
                                                    } onTapScrap: {
                                                        viewStore.send(.view(.didTappedScrap(post.id)))
                                                    }
                                                    .onAppear {
                                                        guard element.id == list.items.last?.id else { return }
                                                        viewStore.send(.view(.loadNextPage))
                                                    }
                                                    .padding(.horizontal, 20)
                                                }
                                            }
                                        case .vote(let vote):
                                            VoteBannerView(voteEntity: vote)
                                                .padding(.horizontal, 20)
                                                .padding(.top, 24)
                                        case .hotPost(let hotpost):
                                            HotPostBannerView(hotPostEntity: hotpost)
                                                .padding(.top, 24)
                                        }
                                    }
                                }
                            }
                            
                            .padding(.vertical, 16)
                            .safeAreaInset(edge: .bottom) {
                                Color.clear.frame(height: 80)
                            }
                        }
                    }
                    .background(DesignSystemAsset.Colors.gray900.swiftUIColor)
                    .ignoresSafeArea()
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: { showWrite = true }) {
                                DesignSystemAsset.Images.icCommunityPencilFiled.swiftUIImage
                                    .resizable()
                                    .scaledToFit()
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 13)
                                    .background(
                                        Circle()
                                            .fill(DesignSystemAsset.Colors.primary300.swiftUIColor)
                                    )
                                    .shadow(color: Color.black.opacity(0.2),
                                            radius: 4, x: 0, y: 5)
                            }
                            .frame(width: 50, height: 50)
                            .padding(.bottom, 24)
                            .padding(.trailing, 24)
                        }
                    }
                    NavigationLink(
                        destination: NotificationViewWrapper()
                            .ignoresSafeArea()
                            .navigationBarBackButtonHidden()
                            .navigationBarHidden(true)
                        ,
                        isActive: $showNotification
                    ) {
                        EmptyView()
                    }
                    
                    NavigationLink(
                        destination: Group {
                            if let chip = selectedDetailChip {
                                CategoryPostView(store: .init(initialState: CategoryPostFeature.State(category: chip) , reducer: { CategoryPostFeature()}))
                            } else {
                                EmptyView()
                            }
                        },
                        isActive: $showCategoryPost,
                        label: { EmptyView() }
                    )
                    .hidden()
                    
                    NavigationLink(
                        destination: MyCategoryPostView(),
                        isActive: $showMyCategory,
                        label: { EmptyView() }
                    )
                    .hidden()
                    
                    
                    NavigationLink(
                        destination: NoticeSearchView(store: .init(initialState: NoticeSearchFeature.State(), reducer: {NoticeSearchFeature()})),
                        isActive: $showSearch,
                        label: { EmptyView() }
                    )
                    .hidden()
                    
                    NavigationLink(
                        destination: PostWriteView(store: .init(initialState: PostWriteFeature.State(), reducer: {PostWriteFeature()})),
                        isActive: $showWrite,
                        label: { EmptyView()}
                    )
                }
                .onAppear {
                    NotificationCenter.default.post(name: .showTabBar, object: nil)
                    store.send(.view(.onAppear))
                }
                .wsNavigationBar(
                    left:  { EmptyView() },
                    title: { EmptyView() },
                    right: {
                        HStack(spacing: 4) {
                            Button { showSearch = true } label: {
                                DesignSystemAsset.Images.icCommunitySesarchFiled.swiftUIImage
                                    .foregroundColor(.white)
                            }
                            Button {
                                showNotification = true
                            } label: {
                                DesignSystemAsset.Images.notice.swiftUIImage
                                    .foregroundColor(.white)
                            }
                            Button {
                                showMyCategory = true
                            } label: {
                                DesignSystemAsset.Images.icTabbarAllUnselected.swiftUIImage
                                    .foregroundColor(.white)
                            }
                        }
                    }
                )
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
            }
            .sheet(
                isPresented: viewStore.binding(
                    get: \.isShowingCategorySheet,
                    send: { $0 ? .view(.didTappedCategoryButton) : .view(.dismissCategorySheet) }
                )
            ) {
                CategoryBottomSheetView(
                    sections: viewStore.chipDetails,
                    onSelect: { chip in
                        viewStore.send(.view(.didSelectDetailChip(chip)))
                        selectedDetailChip = chip
                        showCategoryPost = true
                    }
                )
                .presentationCornerRadius(25)
                .presentationDetents([.height(423)])
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}






struct CategorySelectorWithDropdown: View {
    let chips: [FilterChipEntity]
    let selected: FilterChipEntity?
    let onSelect: (FilterChipEntity) -> Void
    let onDropdownTap: () -> Void
    
    var body: some View {
        ZStack {
            CategorySelectorView(chips: chips, selected: selected, onSelect: onSelect)
                .padding(.trailing, 60)
                .frame(height: 43)
            HStack {
                Spacer()
                ZStack {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                gradient: Gradient(stops: [
                                    .init(color: Color(hex: "1B1C1E"), location: 0.0),
                                    .init(color: Color(hex: "1B1C1E"), location: 0.24),
                                    .init(color: Color(hex: "1B1C1E").opacity(0.73), location: 0.73),
                                    .init(color: Color(hex: "1B1C1E").opacity(0.0), location: 1.0)
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 80, height: 43)
                    
                    Button {
                        onDropdownTap()
                    } label: {
                        Circle()
                            .fill(DesignSystemAsset.Colors.gray700.swiftUIColor)
                            .frame(width: 31, height: 31)
                            .overlay(
                                DesignSystemAsset.Images.icCommuntyDownArrowFiled.swiftUIImage
                            )
                    }
                }
            }
        }
        .frame(height: 43)
    }
}

private struct CategorySelectorView: View {
    let chips: [FilterChipEntity]
    let selected: FilterChipEntity?
    let onSelect: (FilterChipEntity) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(chips, id: \.self) { chip in
                    let isSelected = chip == selected
                    let foregroundColor: Color = isSelected ? DesignSystemAsset.Colors.gray900.swiftUIColor : DesignSystemAsset.Colors.gray300.swiftUIColor
                    let backgroundColor: Color = isSelected ? DesignSystemAsset.Colors.gray200.swiftUIColor : DesignSystemAsset.Colors.gray700.swiftUIColor
                    Button(action: {
                        onSelect(chip)
                    }) {
                        Text(chip.text)
                            .font(.typography(chip.typography))
                            .foregroundColor(foregroundColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(
                                Capsule()
                                    .fill(backgroundColor)
                            )
                    }
                }
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


private struct HotPostBannerView: View {
    let hotPostEntity: HotPostItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 4) {
                AsyncImage(url: URL(string: hotPostEntity.titleIconURL))
                
                Text(hotPostEntity.titleText.text)
                    .font(.typography(hotPostEntity.titleText.typography))
                    .foregroundColor(.token(hotPostEntity.titleText.color))
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    let innerPosts = hotPostEntity.innerPosts.compactMap { $0 }
                    ForEach(innerPosts) { inner in
                        HotPostInnerCardView(inner: inner)
                    }
                }
                .padding(.horizontal, 4)
            }
            .padding(.horizontal, 20)
        }
    }
}

private struct HotPostInnerCardView: View {
    let inner: HotPostInner
    
    var body: some View {
        let profileWidth = CGFloat(inner.profileImageSizeWidth ?? 24)
        let profileHeight = CGFloat(inner.profileImageSizeHeight ?? 24)
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center, spacing: 6) {
                AsyncImage(url: URL(string: inner.profileImageURL)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: profileWidth, height: profileWidth)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: profileWidth, height: profileHeight)
                            .clipShape(Circle())
                    default:
                        Circle()
                            .fill(.gray.opacity(0.3))
                            .frame(width: profileWidth, height: profileHeight)
                    }
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(inner.nickname.text)
                        .font(.typography(inner.nickname.typography))
                        .foregroundColor(.token(inner.nickname.color))
                    
                }
                
                Spacer()
            }
            
            if let innerTitle = inner.title {
                if !innerTitle.text.isEmpty {
                    Text(innerTitle.text)
                        .font(.typography(innerTitle.typography))
                        .foregroundColor(.token(innerTitle.color))
                        .lineLimit(1)
                } else {
                    Text(inner.description.text)
                        .font(.typography(inner.description.typography))
                        .foregroundColor(.token(inner.description.color))
                        .lineLimit(2)
                }
            }
            
            
            
            Text(inner.createdAt.text)
                .font(.typography(inner.createdAt.typography))
                .foregroundColor(.token(inner.createdAt.color))
                .padding(.bottom, 12)
        }
        .padding(12)
        .frame(width: 240)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(hex:inner.gradationStart), Color(hex:inner.gradationEnd)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}



private struct VoteBannerView: View {
    let voteEntity: VoteComponent
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("비밀 투표")
                    .font(.caption2)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.orange))
                
                HStack {
                    Text(voteEntity.text.text)
                        .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        AsyncImage(url: URL(string: voteEntity.actionIconURL))
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.black.opacity(0.8)))
                    }
                }
                
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: voteEntity.gradientStart),
                    Color(hex: voteEntity.gradientEnd)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .frame(maxWidth: .infinity)
    }
}




struct PostView: View {
    let content: PostContent
    let postId: Int
    let onTapComment: () -> Void
    let onTapLike:    () -> Void
    let onTapScrap:   () -> Void
    @State private var isExpanded = false
    @State private var showFeedDetail = false
    
    init(
        content: PostContent,
        postId: Int = 0,
        onTapComment: @escaping () -> Void = {},
        onTapLike: @escaping () -> Void,
        onTapScrap: @escaping () -> Void
    ) {
        self.content = content
        self.postId = postId
        self.onTapComment = onTapComment
        self.onTapLike = onTapLike
        self.onTapScrap = onTapScrap
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            NavigationLink(
                destination: FeedDetailView(
                    store: .init(
                        initialState: FeedDetailFeature.State(postId: String(postId)),
                        reducer: { FeedDetailFeature() }
                    )
                ),
                isActive: $showFeedDetail
            ) {
                EmptyView()
            }
            
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: content.header.profileImageURL)) { state in
                    switch state {
                    case .empty: ProgressView()
                    case .success(let image): image.resizable()
                    @unknown default: EmptyView()
                    }
                }
                .frame(width: CGFloat(content.header.profileImageWidth),
                       height: CGFloat(content.header.profileImageHeight))
                .clipShape(Circle())
                let _ = print("프로필 이미지 값 \(content.header.profileImageWidth)")
                
                VStack(alignment: .leading, spacing: 4) {
                    if let category = content.header.category {
                        
                        let _ = print("카테고리 아이콘 이미지 : \(category.iconURL)")
                        HStack(spacing: 0) {
                            Text(category.text)
                                .font(.typography(category.typography))
                                .foregroundColor(.token(category.textColor))
                            
                            DesignSystemAsset.Images.icPostRightArrow.swiftUIImage
                                .frame(width: 16, height: 16)
                            .foregroundColor(.token(category.iconColor))
                        }
                    }
                    
                    HStack(spacing: 6) {
                        Text(content.header.nickname.text)
                            .font(.typography(content.header.nickname.typography))
                            .foregroundColor(.token(content.header.nickname.color))
                        Text(content.header.createdAt.text.formattedRelative())
                            .font(.typography(content.header.createdAt.typography))
                            .foregroundColor(.token(content.header.createdAt.color))
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if let contentTitle = content.info.title {
                    let _ = print("데이터 확인합니다 : \(contentTitle.typography)")
                    Text(contentTitle.text)
                        .font(.typography(contentTitle.typography))
                        .foregroundColor(.token(contentTitle.color))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, maxHeight: 21, alignment: .leading)
                }
                
                let _ = print("데이터 확인합니다 : \(content.info.description.typography)")
                Text(content.info.description.text)
                    .font(.typography(content.info.description.typography))
                    .foregroundColor(.token(content.info.description.color))
                    .lineLimit(5)
                    .frame(maxWidth: .infinity, maxHeight: 120, alignment: .leading)
            }
            
            if content.info.seeMore.maxLine >= 5 {
                Button(content.info.seeMore.text) {
                    showFeedDetail = true
                }
                .font(.typography(content.info.seeMore.typography))
                .frame(maxWidth: .infinity, maxHeight: 18, alignment: .leading)
                .foregroundColor(.token(content.info.seeMore.color))
            }
            
            if let section = content.contentSection {
                switch section {
                case .images(let images) where !images.isEmpty:
                    if images.count == 1 {
                        AsyncImage(url: URL(string: images[0].url)) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 336, height: 155)
                            case .success(let img):
                                img
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 336, height: getImageHeight(for: images[0], maxWidth: 336))
                                    .clipped()
                                    .cornerRadius(12)
                            case .failure:
                                Color.gray
                                    .frame(width: 336, height: 155)
                                    .overlay(
                                        Image(systemName: "photo")
                                    )
                                    .cornerRadius(12)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .padding(.vertical, 8)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(images.enumerated()), id: \.offset) { _, image in
                                    AsyncImage(url: URL(string: image.url)) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                                .frame(width: 226, height: 226)
                                        case .success(let img):
                                            img
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 226, height: 226)
                                                .clipped()
                                                .cornerRadius(12)
                                        case .failure:
                                            Color.gray
                                                .frame(width: 226, height: 226)
                                                .overlay(
                                                    Image(systemName: "photo")
                                                )
                                                .cornerRadius(12)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                default:
                    EmptyView()
                }
            }
            
            
            HStack(spacing: 12) {
                ForEach(content.footer.reactions, id: \.type) { reaction in
                    Button {
                        switch reaction.type {
                        case "Chat": onTapComment()
                        case "Like": onTapLike()
                        default: break
                        }
                    } label: {
                        HStack(spacing: 4) {
                            AsyncImage(url: URL(string: reaction.iconURL)) { state in
                                switch state {
                                case .empty:
                                    ProgressView()
                                        .frame(width: 14, height: 14)
                                case .success(let image):
                                    image
                                        .renderingMode(.template)
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(reaction.selected ? DesignSystemAsset.Colors.primary300.swiftUIColor : .token(reaction.iconColor))
                                @unknown default:
                                    EmptyView()
                                }
                            }
                            .frame(width: 14, height: 14)
                            
                            if reaction.count.text != "0" {
                                Text(reaction.count.text)
                                    .font(.typography(reaction.count.typography))
                                    .foregroundColor(.token(reaction.count.color))
                            }
                        }
                    }
                }
                
                
                Spacer()
                Button(action: {
                    onTapScrap()
                }) {
                    HStack(spacing: 4) {
                        AsyncImage(url: URL(string: content.footer.scrap.iconURL)) { state in
                            switch state {
                            case .empty:    ProgressView().frame(width: 16, height: 16)
                            case .success(let image):
                                image
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(content.footer.scrap.selected ? DesignSystemAsset.Colors.primary300.swiftUIColor :  .token(content.footer.scrap.iconColor))
                            @unknown default: EmptyView()
                            }
                        }
                        .frame(width: 14, height: 14)
                        
                        Text("스크랩")
                            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                            .foregroundColor(DesignSystemAsset.Colors.gray300.swiftUIColor)
                    }
                }
                
            }
            
            Divider()
                .background(DesignSystemAsset.Colors.gray600.swiftUIColor)
                .padding(.vertical, 16)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func getImageHeight(for imageData: Any, maxWidth: CGFloat) -> CGFloat {
        let defaultHeight: CGFloat = 155
        let maxHeight: CGFloat = 718
        
        return defaultHeight
    }
    
}

struct NotificationViewWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> NotificationViewController {
        let notificationViewController = DependencyContainer.shared.injector.resolve(NotificationViewController.self)
        
        notificationViewController.navigationController?.setNavigationBarHidden(true, animated: false)
        notificationViewController.navigationController?.navigationBar.isHidden = true
        
        DispatchQueue.main.async {
            notificationViewController.beginAppearanceTransition(true, animated: false)
            notificationViewController.endAppearanceTransition()
        }
        
        NotificationCenter.default.post(name: .hideTabBar, object: nil)
        
        return notificationViewController
    }
    
    func updateUIViewController(_ uiViewController: NotificationViewController, context: Context) {
        uiViewController.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

