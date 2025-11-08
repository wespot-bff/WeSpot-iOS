//
//  CategoryPostView.swift
//  CommunityFeature
//
//  Created by 김도현 on 8/3/25.
//



import ComposableArchitecture
import SwiftUI
import DesignSystem
import Kingfisher

@ViewAction(for: CategoryPostFeature.self)
struct CategoryPostView: View {
    var store: StoreOf<CategoryPostFeature>
    @StateObject private var viewStore: ViewStoreOf<CategoryPostFeature>
    @Environment(\.presentationMode) private var presentationMode
    private let bannerHeight: CGFloat   = 200
    private let circleDiameter: CGFloat = 56
    private var circleRadius: CGFloat   { circleDiameter / 2 }
    @State private var showPostWriteView = false
    @State private var selectedPostId: String? = nil
    @State private var showSearchView = false
    @State private var scrollPosition: String? = nil
    @State private var isFirstAppear = true
    @State private var isReturningFromWrite = false
    @State private var showFeedDetail = false
    
    public init(store: StoreOf<CategoryPostFeature>) {
        self.store = store
        self._viewStore = StateObject(
            wrappedValue: ViewStore(store, observe: \.self)
        )
    }
    
    var body: some View {
        GeometryReader { geo in
            let topInset = geo.safeAreaInsets.top
            
            NavigationLink(
                 destination: FeedDetailView(
                     store: .init(
                         initialState: FeedDetailFeature.State(postId: selectedPostId ?? ""),
                         reducer: { FeedDetailFeature() }
                     )
                 ),
                 isActive: $showFeedDetail
             ) {
                 EmptyView()
             }
             .hidden()
             .onChange(of: showFeedDetail) { isShowing in
                 if isShowing {
                     scrollPosition = "post-\(selectedPostId ?? "")"
                 } else {
                     let returnSource = viewStore.returnSource
                     
                     switch returnSource {
                     case .feedDetail(let needsRefresh):
                         if !needsRefresh, let position = scrollPosition {
                             DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                 // 스크롤 복원 로직은 ScrollViewReader에서 처리
                             }
                         } else {
                             scrollPosition = nil
                         }
                     default:
                         break
                     }
                 }
             }
            
            NavigationLink(
                destination: PostWriteView(store: .init(initialState: PostWriteFeature.State(selectedCategory: viewStore.category, isMain: false), reducer: {PostWriteFeature()})),
                isActive: $showPostWriteView,
                label: { EmptyView()}
            )
            .hidden()
            .onChange(of: showPostWriteView) { isShowing in
                 if !isShowing && isReturningFromWrite {
                     viewStore.send(.view(.onAppearWithRefresh))
                     isReturningFromWrite = false
                     scrollPosition = nil
                 } else if isShowing {
                     isReturningFromWrite = true
                     viewStore.send(.view(.willNavigateToPostWrite))
                 }
             }
            
            
            NavigationLink(
                destination: NoticeSearchView(store: .init(initialState: NoticeSearchFeature.State(), reducer: {NoticeSearchFeature()})),
                isActive: $showSearchView,
                label: { EmptyView() }
            )
            
            ZStack {
                DesignSystemAsset.Colors.gray900.swiftUIColor
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    contentScrollView(topInset: topInset)
                }
                
                floatingWriteButton()
            }
            .onReceive(NotificationCenter.default.publisher(for: .postDeleted)) { _ in
                viewStore.send(.view(.onAppearWithRefresh))
            }
            .onAppear {
                if isFirstAppear {
                    viewStore.send(.view(.onAppear))
                    isFirstAppear = false
                } else {
                    viewStore.send(.view(.onAppear))
                }
            }
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
                    let _ = print("데이터 확인 \(chip)")
                    viewStore.send(.view(.didSelectChip(chip)))
                },
                selectedCategoryId: viewStore.category.id
            )
            .presentationCornerRadius(25)
            .presentationDetents([.height(423)])
            .ignoresSafeArea(.all)
        }
        
        .navigationBarHidden(true)
        .modifier(
            WSNavigationBarModifier(
                left:  {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        DesignSystemAsset.Images.icCommunityLeftArrowFiled.swiftUIImage
                    }
                    
                },
                title: { EmptyView() },
                right: {
                    Button {
                        showSearchView = true
                    } label: {
                        DesignSystemAsset.Images.icCommunitySesarchFiled.swiftUIImage
                            .renderingMode(.template)
                            .foregroundColor(.white)
                    }
                },
                background: Color.clear
            )
        )
    }
    
    private func headerView(topInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(height: bannerHeight)
                .overlay {
                    if let post = viewStore.postListEntity,
                       let backgroundURL = URL(string: post.background?.url ?? "")
                    {
                        AsyncImage(url: backgroundURL) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            EmptyView()
                        }
                    }
                        
                }
            
            ZStack(alignment: .leading) {
                DesignSystemAsset.Colors.gray900.swiftUIColor
                .padding(.leading, 20)
                .padding(.top, circleRadius + 20)
            }
            .frame(height: circleRadius + 20 + 28)
        }
        .frame(height: 250)
        .ignoresSafeArea(edges: .top)
    }
    
    private func contentScrollView(topInset: CGFloat) -> some View {
        ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ZStack(alignment: .bottomLeading) {
                        headerView(topInset: topInset)
                            .frame(height: 250)
                        
                        profileCircle()
                            .offset(y: circleRadius - 70)
                            .padding(.leading, 20)
                    }
                    .padding(.bottom, circleRadius - 40)
                    
                    HStack(spacing: 8) {
                        Text(viewStore.category.text)
                            .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 24))
                            .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
                        
                        DesignSystemAsset.Images.icCommuntyCategoryChipFiled.swiftUIImage
                            .onTapGesture {
                                viewStore.send(.view(.didTappedCategoryButton))
                            }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    LazyVStack(spacing: 16) {
                        if let list = viewStore.postListEntity {
                            ForEach(list.items, id: \.id) { element in
                                if case .post(let post) = element,
                                   let content = post.content {
                                    Button(action: {
                                        selectedPostId = String(post.id)
                                        viewStore.send(.view(.willNavigateToFeedDetail))
                                        showFeedDetail = true
                                    }) {
                                        PostView(content: content,  postId: post.id) {
                                            
                                        } onTapLike: {
                                            viewStore.send(.view(.didTappedLike(post.id)))
                                        } onTapScrap: {
                                            viewStore.send(.view(.didTappedScrap(post.id)))
                                        }
                                        .id("post-\(post.id)")
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .onAppear {
                                        if element.id == list.items.last?.id {
                                            viewStore.send(.view(.loadNextPage))
                                        }
                                    }
                                    .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .padding(.top, 16)
                }
            }
            .background(DesignSystemAsset.Colors.gray900.swiftUIColor)
            .onChange(of: showFeedDetail) { isShowing in
                if !isShowing, let position = scrollPosition {
                    let returnSource = viewStore.returnSource
                    
                    switch returnSource {
                    case .feedDetail(let needsRefresh):
                        if !needsRefresh {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                withAnimation(.easeOut(duration: 0.2)) {
                                    proxy.scrollTo(position, anchor: .center)
                                }
                            }
                        }
                    default:
                        break
                    }
                }
            }
        }
    }


    
    private func floatingWriteButton() -> some View {
        Button {
            showPostWriteView = true
        } label: {
            DesignSystemAsset.Images.icCommunityPencilFiled.swiftUIImage
                .resizable().scaledToFit()
                .frame(width: 30, height: 30)
                .padding(18)
                .background(Circle().fill(DesignSystemAsset.Colors.primary300.swiftUIColor))
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.bottom, 40)
        .padding(.trailing, 24)
    }
    
    private func profileCircle() -> some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: circleDiameter, height: circleDiameter)
            .overlay {
                if let post = viewStore.postListEntity,
                   let profileURL = URL(string: post.thumbnail?.url ?? "")
                {
                    AsyncImage(url: profileURL) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: circleDiameter - 4, height: circleDiameter - 4)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .foregroundColor(.white)
                    }
                }
            }
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
    }
}
