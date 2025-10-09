//
//  CategoryBottomSheetView.swift
//  CommunityFeature
//
//  Created by 김도현 on 7/27/25.
//

import SwiftUI
import CommunityDomain
import DesignSystem

public struct FilterChipView: View {
    let chip: CategoryChipsEntity
    let isSelected: Bool
    
    public init(chip: CategoryChipsEntity, isSelected: Bool = false) {
        self.chip = chip
        self.isSelected = isSelected
    }
    
    
    public var body: some View {
        Text(chip.text)
            .font(DesignSystemFontFamily.Pretendard.medium.swiftUIFont(size: 11))
            .foregroundColor(isSelected ? .black : .white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                isSelected
                ? DesignSystemAsset.Colors.gray100.swiftUIColor
                : DesignSystemAsset.Colors.gray500.swiftUIColor
            )
            .cornerRadius(16)
    }
}


struct CategoryBottomSheetView: View {
    let sections: [CategoryDetailEntity]
    let onSelect: (CategoryChipsEntity) -> Void
    @State private var selectedIDs: Set<Int> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("게시판 카테고리")
                .padding(.top, 20)
                .font(DesignSystemFontFamily.Pretendard.bold.swiftUIFont(size: 18))
                .foregroundColor(DesignSystemAsset.Colors.gray100.swiftUIColor)
            
            ForEach(sections, id: \.title) { section in
                VStack(alignment: .leading, spacing: 12) {
                    Text(section.title)
                        .font(DesignSystemFontFamily.Pretendard.semiBold.swiftUIFont(size: 16))
                        .foregroundColor(DesignSystemAsset.Colors.gray200.swiftUIColor)
                    
                    
                    FlexibleView(
                        data: section.chips,
                        spacing: 10,
                        alignment: .leading
                    ) { chip in
                        FilterChipView(
                            chip: chip,
                            isSelected: selectedIDs.contains(chip.id)
                        )
                        .onTapGesture {
                            if selectedIDs.contains(chip.id) {
                                selectedIDs.remove(chip.id)
                            } else {
                                selectedIDs.insert(chip.id)
                            }
                            onSelect(chip)
                        }
                    }
                }
            }
            
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(DesignSystemAsset.Colors.gray600.swiftUIColor)
        .cornerRadius(16)
    }
}



struct FlexibleView<Data: RandomAccessCollection, Content: View>: View
where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content
    
    @State private var sizes: [Data.Element: CGSize] = [:]
    @State private var containerWidth: CGFloat = 0
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            GeometryReader { proxy in
                Color.clear
                    .onAppear { containerWidth = proxy.size.width }
                    .onChange(of: proxy.size.width) { new in
                        containerWidth = new
                    }
            }
            
            VStack(alignment: alignment, spacing: spacing) {
                ForEach(computeRows(), id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(row, id: \.self) { element in
                            content(element)
                                .fixedSize()
                                .readSize { sizes[element] = $0 }
                        }
                    }
                }
            }
        }
    }
    
    private func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentLineWidth: CGFloat = 0
        let maxWidth = containerWidth
        
        for element in data {
            let elementWidth = sizes[element]?.width ?? 0
            if currentLineWidth + elementWidth + spacing > maxWidth {
                rows.append([element])
                currentLineWidth = elementWidth + spacing
            } else {
                rows[rows.count - 1].append(element)
                currentLineWidth += elementWidth + spacing
            }
        }
        return rows
    }
}
