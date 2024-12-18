//
//  Injected.swift
//  Util
//
//  Created by 김도현 on 12/16/24.
//

import Foundation


@propertyWrapper
public class Injected<T> {
    
    public lazy var wrappedValue: T = DependencyContainer.shared.injector.resolve()
    public init() {}
}
