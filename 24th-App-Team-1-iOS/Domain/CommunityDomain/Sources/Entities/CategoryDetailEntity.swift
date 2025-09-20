//
//  CategoryDetailEntity.swift
//  CommunityDomain
//
//  Created by 김도현 on 7/27/25.
//

import Foundation

public struct CategoryDetailEntity: Equatable {
    public let title: String
    public let chips: [CategoryChipsEntity]
    
    public init(title: String, chips: [CategoryChipsEntity]) {
        self.title = title
        self.chips = chips
    }
}


public struct CategoryChipsEntity: Identifiable, Equatable, Hashable {
    public let id: Int
    public let text: String
        
    public init(id: Int, text: String) {
        self.id = id
        self.text = text
    }
}
