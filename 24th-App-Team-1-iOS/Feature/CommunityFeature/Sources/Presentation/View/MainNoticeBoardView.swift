//
//  MainNoticeBoardView.swift
//  CommunityFeature
//
//  Created by 김도현 on 7/15/25.
//

import SwiftUI
import DesignSystem
import ComposableArchitecture

import SwiftUI

struct WSNavigationBarView: View {
    let onSearch: () -> Void
    let onNotice: () -> Void
    let onMenu: () -> Void

    var body: some View {
        GeometryReader { geo in
            let topInset = geo.safeAreaInsets.top

            VStack(spacing: 0) {
                HStack {
                    Spacer()

                    HStack(spacing: 4) {
                        Button(action: onSearch) {
                            DesignSystemAsset.Images.icCommunitySesarchFiled.swiftUIImage
                        }
                        Button(action: onNotice) {
                            DesignSystemAsset.Images.notice.swiftUIImage
                        }
                        Button(action: onMenu) {
                            DesignSystemAsset.Images.icTabbarAllUnselected.swiftUIImage
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, topInset + 8)
                .padding(.bottom, 12)
                
                Spacer()
            }
            .background(DesignSystemAsset.Colors.gray800.swiftUIColor)
            .ignoresSafeArea(edges: .top)
        }

        .frame(height: UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0
               + 8
               + 44
               + 12)
    }
}



public struct MainNoticeBoardView: View {
    @State private var showSearch = false

    public init() { }

    public var body: some View {
        GeometryReader { geo in
            let topInset     = geo.safeAreaInsets.top
            let navBarHeight = topInset + 8 + 44 + 12

            NavigationView {
                ZStack(alignment: .top) {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            Color.clear
                                .frame(height: navBarHeight)

                            CategorySelectorView()
                                .padding(.horizontal, 20)
                                .padding(.bottom, 16)

                            LazyVStack(alignment: .leading, spacing: 16) {
                                ForEach(0..<20, id: \.self) { _ in
                                    PostView()
                                        .padding(.horizontal, 20)
                                }
                            }
                            .padding(.vertical, 16)
                            .safeAreaInset(edge: .bottom) {
                                Color.clear.frame(height: 80)
                            }
                        }
                    }
                    .background(DesignSystemAsset.Colors.gray800.swiftUIColor)
                    .ignoresSafeArea()

                    WSNavigationBarView(
                        onSearch:  { showSearch = true },
                        onNotice:  { },
                        onMenu:    { }
                    )
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: { }) {
                                DesignSystemAsset.Images.icCommunityPencilFiled.swiftUIImage
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30, height: 30)
                                    .padding(18)
                                    .background(
                                        Circle()
                                            .fill(DesignSystemAsset.Colors.primary300.swiftUIColor)
                                    )
                                    .shadow(color: Color.black.opacity(0.2),
                                            radius: 4, x: 0, y: 5)
                            }
                            .padding(.bottom, 40)
                            .padding(.trailing, 24)
                        }
                    }
                    NavigationLink(
                        destination: NoticeSearchView(),
                        isActive: $showSearch,
                        label: { EmptyView() }
                    )
                    .hidden()
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarHidden(true)
            }
            .onAppear {
                NotificationCenter.default.post(name: .showTabBar, object: nil)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }
}



private struct CategorySelectorView: View {
    let categories: [String] = ["전체", "카테고리1", "카테고리2", "카테고리3", "카테고리4"]
    @State private var selected: String = "전체"
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(categories, id: \.self) { category in
                    let isSelected = selected == category
                    let foregroundColor: Color = isSelected ? DesignSystemAsset.Colors.white.swiftUIColor : DesignSystemAsset.Colors.gray400.swiftUIColor
                    let backgroundColor: Color = isSelected ? DesignSystemAsset.Colors.gray500.swiftUIColor : Color.clear
                    Button(action: {
                        selected = category
                    }) {
                        Text(category)
                            .font(.subheadline)
                            .foregroundColor(foregroundColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(backgroundColor)
                            ).overlay {
                                Capsule()
                                    .stroke(selected == category ? Color.clear : DesignSystemAsset.Colors.gray400.swiftUIColor, lineWidth: 1)
                            }
                    }
                }
            }
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct CategorySelectorView_Previews: PreviewProvider {
    static var previews: some View {
        CategorySelectorView()
            .background(Color.black.opacity(0.9))
            .previewLayout(.sizeThatFits)
    }
}



private struct VoteBannerView: View {
    let question: String
    
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
                    Text(question)
                        .font(.body)
                        .foregroundColor(.black)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        DesignSystemAsset.Images.icCommunityArrowFiled.swiftUIImage
                            .font(.headline)
                            .foregroundColor(.white)
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
                    Color(red: 1.00, green: 0.87, blue: 0.72),
                    Color(red: 0.98, green: 0.78, blue: 0.60)
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
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1523348837708-15d4a09cfac2?q=80&w=2070&auto=format&fit=crop")) { state in
                    switch state {
                    case .empty: ProgressView()
                    case .success(let image): image.resizable()
                    @unknown default: EmptyView()
                    }
                }
                .frame(width: 36, height: 36)
                .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("금융")
                            .font(.caption)
                            .foregroundColor(DesignSystemAsset.Colors.gray300.swiftUIColor)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    HStack(spacing: 6) {
                        Text("익명의 글쓴이")
                            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 14))
                            .foregroundColor(DesignSystemAsset.Colors.gray300.swiftUIColor)
                        Text("방금")
                            .font(.footnote)
                            .font(.subheadline)
                            .foregroundColor(DesignSystemAsset.Colors.gray400.swiftUIColor)
                    }
                }
                
                Spacer()
            }
            Text("강한 3파가 나간 후 땅바닥을 찍고 230불까지 도달한 후 날봉기준 10일선을 지키고 마감했네요. 엔비디아, TSMC는 진고점과 10%도 차이가 나지 않는 범위 안에 있고, 브로드컴은 ATH를 찍고 살짝 내려오고 있습니다만, 과연 여기서 금리인하를 할것인지 어찌고 저찌고 블라블라블라블라블라블블라블...")
                .font(DesignSystemFontFamily.Pretendard.regular.swiftUIFont(size: 14))
                .foregroundColor(DesignSystemAsset.Colors.white.swiftUIColor)
                .lineLimit(5)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button("더 보기") {
                
            }
            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 16))
            .frame(maxWidth: .infinity, maxHeight: 18, alignment: .leading)
            .foregroundColor(DesignSystemAsset.Colors.primary300.swiftUIColor)
            
            HStack(spacing: 24) {
                Button(action: {

                }) {
                    HStack(spacing: 4) {
                        DesignSystemAsset.Images.icCommunityCommentFiled.swiftUIImage
                        Text("10,0000")
                            .foregroundColor(DesignSystemAsset.Colors.gray300.swiftUIColor)
                            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                    }
                }
                
                Button(action: {
                    
                }) {
                    HStack(spacing: 4) {
                        DesignSystemAsset.Images.icCommunityLikeFiled.swiftUIImage
                        Text("10,0000")
                            .foregroundColor(DesignSystemAsset.Colors.gray300.swiftUIColor)
                            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                    }
                }
                
                Spacer()
                
                Button(action: {
 
                }) {
                    HStack(spacing: 4) {
                        DesignSystemAsset.Images.icCommunityBookmarkFiled.swiftUIImage
                        Text("스크랩")
                            .foregroundColor(DesignSystemAsset.Colors.gray300.swiftUIColor)
                            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 12))
                    }
                }
            }
            Divider()
                .background(DesignSystemAsset.Colors.gray600.swiftUIColor)   // 선 색 지정
                .padding(.vertical, 4)
            
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    MainNoticeBoardView()
}
