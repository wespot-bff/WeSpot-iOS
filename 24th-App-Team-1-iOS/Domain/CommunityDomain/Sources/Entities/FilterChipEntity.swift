//
//  FilterChipEntity.swift
//  CommunityDomain
//
//  Created by 김도현 on 7/26/25.
//

import Foundation

public struct FilterChipEntity: Identifiable, Equatable, Hashable {
    public let id: Int
    public let iconURL: URL?
    public let iconHexColor: String
    public let text: String
    public let textHexColor: String
    public let typography: String
    
    public init(
        id: Int,
        iconURL: URL?,
        iconHexColor: String,
        text: String,
        textHexColor: String,
        typography: String
    ) {
        self.id = id
        self.iconURL = iconURL
        self.iconHexColor = iconHexColor
        self.text = text
        self.textHexColor = textHexColor
        self.typography = typography
    }
}
