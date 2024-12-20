//
//  CoordinatorInjected.swift
//  Util
//
//  Created by 김도현 on 12/20/24.
//

import Foundation

/// Coordinator 의존성을 가져오는 `propertyWrapper` 입니다.
@propertyWrapper
public struct CoordinatorInjected<I> {
    public lazy var wrappedValue: I = DependencyContainer.shared.injector.resolve()
    
    public init() { }
}
