//
//  WSCacheWrapper.swift
//  Storage
//
//  Created by 김도현 on 1/20/25.
//

import Foundation

final class WSCacheWrapper<T: Decodable>: NSObject {
    let value: T
    
    init(value: T) {
        self.value = value
    }
}
