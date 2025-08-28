//
//  NoticeSearchView.swift
//  CommunityFeature
//
//  Created by 김도현 on 7/22/25.
//

import ComposableArchitecture
import SwiftUI
import DesignSystem
import CommunityDomain


struct SearchBar: View {
    @Binding var text: String
    var placeholder: String = ""
    
    var body: some View {
        HStack {
            DesignSystemAsset.Images.icCommunitySesarchFiled.swiftUIImage
            
            TextField(placeholder, text: $text)
                .foregroundColor(.white)
            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(white: 0.15))
        .cornerRadius(12)
        .frame(maxWidth:  .infinity, maxHeight: 56)
    }
}


@ViewAction(for: NoticeSearchFeature.self)
public struct NoticeSearchView: View {
    @Perception.Bindable
    public var store: StoreOf<NoticeSearchFeature>
    @StateObject private var viewStore: ViewStore<NoticeSearchFeature.State, NoticeSearchFeature.Action>

    @Environment(\.presentationMode) private var presentationMode
    
    public init(store: StoreOf<NoticeSearchFeature>) {
        self.store = store
        self._viewStore = StateObject(wrappedValue: ViewStore(store, observe: \.self))
    }
    
    public var body: some View {
        GeometryReader { geo in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section(header:
                                SearchBar(
                                    text: viewStore.binding(
                                        get: \.searchKeyword,
                                        send: { .view(.didSearchKeyword($0)) }
                                    ),
                                    placeholder: "글 제목, 내용을 검색해 주세요"
                                )
                                    .padding(.horizontal, 20)
                                    .padding(.top, 12)
                                    .background(DesignSystemAsset.Colors.gray900.swiftUIColor)
                    ) {
                        
                        if let list = viewStore.postListEntity {
                            ForEach(list.items.compactMap { element in
                                if case .post(let post) = element {
                                    return post
                                }
                                return nil
                            }, id: \.id) { post in
                                if let content = post.content {
                                    NavigationLink(
                                        destination: FeedDetailView(
                                            store: .init(
                                                initialState: FeedDetailFeature.State(postId: String(post.id)),
                                                reducer: { FeedDetailFeature() }
                                            )
                                        )
                                    ) {
                                        PostView(content: content) {
                                        } onTapLike: {
                                            viewStore.send(.view(.didTappedLike(post.id)))
                                        } onTapScrap: {
                                            viewStore.send(.view(.didTappedScrap(post.id)))
                                        }
                                        .padding(.top, 24)
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    NotificationCenter.default.post(name: .hideTabBar, object: nil)
                }
            }
            .background(DesignSystemAsset.Colors.gray900.swiftUIColor)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        DesignSystemAsset.Images.arrow.swiftUIImage
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .edgesIgnoringSafeArea(.bottom)
    }
}

