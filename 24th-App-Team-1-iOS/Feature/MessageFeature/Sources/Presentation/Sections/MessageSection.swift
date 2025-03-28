//
//  MessageSection.swift
//  MessageFeature
//
//  Created by 최지철 on 1/20/25.
//

import MessageDomain

import RxDataSources

struct MessageSection {
    var header: String
    var items: [MessageContentModel]
}

extension MessageSection: AnimatableSectionModelType {
    typealias Item = MessageContentModel
    
    var identity: String {
        return header
    }
    
    init(original: MessageSection, items: [MessageContentModel]) {
        self = original
        self.items = items
    }
}
