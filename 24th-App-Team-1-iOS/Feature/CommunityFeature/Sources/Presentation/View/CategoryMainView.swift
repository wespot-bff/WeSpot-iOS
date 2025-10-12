//
//  CategoryMainView.swift
//  CommunityFeature
//
//  Created by 김도현 on 9/5/25.
//



import SwiftUI
import ComposableArchitecture
import DesignSystem


@ViewAction(for: CategoryMainFeature.self)
struct CategoryMainView: View {
    var store: StoreOf<CategoryMainFeature>
    @StateObject private var viewStore: ViewStoreOf<CategoryMainFeature>
    @State private var showMainView: Bool = false
    @Environment(\.presentationMode) private var presentationMode
    let fromCategoryPost: Bool
    let shouldReturnToMain: Bool
    
    public init(
        store: StoreOf<CategoryMainFeature>,
        fromCategoryPost: Bool = false,
        shouldReturnToMain: Bool = false
    ) {
        self.store = store
        self.fromCategoryPost = fromCategoryPost
               self.shouldReturnToMain = shouldReturnToMain
        self._viewStore = StateObject(
            wrappedValue: ViewStore(store, observe: \.self)
        )
    }
    
    var body: some View {
        GeometryReader { geo in
            NavigationLink(
                destination: Group {
                    if let chip = viewStore.category {
                        CategoryPostView(store: .init(initialState: CategoryPostFeature.State(category: chip) , reducer: { CategoryPostFeature()}))
                    } else {
                        EmptyView()
                    }
                },
                isActive: $showMainView,
                label: { EmptyView() }
            )
            
            
            let topInset     = geo.safeAreaInsets.top
            let navBarHeight = topInset + 8 + 44 + 12
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    Color.clear.frame(height: navBarHeight)
                    if let list = viewStore.postListEntity {
                        ForEach(list.items, id: \.id) { element in
                            if case .post(let post) = element,
                               let content = post.content {
                                PostView(content: content) {
                                    
                                } onTapLike: {
                                    
                                } onTapScrap: {
                                    
                                }
                                .padding(.horizontal, 20)
                            }
                            
                        }
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
                    }
                )
                .presentationCornerRadius(25)
                .presentationDetents([.height(423)])
                .ignoresSafeArea(.all)
            }
            .wsNavigationBar(left: {
                Button {
                    if viewStore.isEditable {
                        showMainView = true
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                    
                } label: {
                    DesignSystemAsset.Images.icCommunityLeftArrowFiled.swiftUIImage
                }
            }, title: {
                Group {
                        HStack(spacing: 5) {
                            Button {
                                viewStore.send(.view(.didTappedCategoryButton))
                            } label: {
                                if let category = viewStore.category {
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
                    
                } label: {
                    DesignSystemAsset.Images.icCommunityDotFiled.swiftUIImage
                }
            })
            .onAppear {
                NotificationCenter.default.addObserver(forName: .didFinishWritePost, object: nil, queue: .main) { _ in
                    showMainView = true
                }
                viewStore.send(.view(.onAppear))
            }
            .navigationBarBackButtonHidden(true)
            .background(DesignSystemAsset.Colors.gray900.swiftUIColor)
        }
    }
}
