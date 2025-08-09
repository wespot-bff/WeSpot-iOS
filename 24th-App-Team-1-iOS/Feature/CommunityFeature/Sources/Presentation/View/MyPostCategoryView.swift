//
//  MyPostCategoryView.swift
//  CommunityFeature
//
//  Created by 김도현 on 8/7/25.
//

import SwiftUI
import ComposableArchitecture
import DesignSystem

@ViewAction(for: MyPostCategoryFeature.self)
struct MyPostCategoryView: View {
    @Perception.Bindable
    var store: StoreOf<MyPostCategoryFeature>
    @StateObject private var viewStore: ViewStore<MyPostCategoryFeature.State, MyPostCategoryFeature.Action>
    @Environment(\.presentationMode) private var presentationMode
    public init(store: StoreOf<MyPostCategoryFeature>) {
        self.store = store
        self._viewStore = StateObject(wrappedValue: ViewStore(store, observe: \.self))
    }
    
    var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 16) {
                    if let list = viewStore.postListItems {
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
            .onAppear {
                viewStore.send(.view(.onAppear))
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        DesignSystemAsset.Images.arrow.swiftUIImage
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text(viewStore.category.title)
                        .foregroundStyle(DesignSystemAsset.Colors.gray100.swiftUIColor)
                        .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 18))
                }
            }
            .background(DesignSystemAsset.Colors.gray900.swiftUIColor)
        }
    }
}
