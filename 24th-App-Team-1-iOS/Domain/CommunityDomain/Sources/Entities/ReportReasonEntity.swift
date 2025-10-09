//
//  ReportReasonEntity.swift
//  CommunityDomain
//
//  Created by 김도현 on 9/3/25.
//

public struct ReportReason: Identifiable, Hashable {
    public let id: Int
    public let title: String
    public var isEditable: Bool
    public var isSelected: Bool

    public init(id: Int, title: String, isEditable: Bool, isSelected: Bool = false) {
        self.id = id
        self.title = title
        self.isEditable = isEditable
        self.isSelected = isSelected
    }
}
