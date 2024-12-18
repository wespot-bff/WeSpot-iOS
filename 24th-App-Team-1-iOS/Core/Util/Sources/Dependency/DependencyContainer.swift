//
//  DependencyContainer.swift
//  Util
//
//  Created by Kim dohyun on 7/28/24.
//

import Foundation

import Swinject

public final class DependencyContainer {
    public static let shared = DependencyContainer()
    public lazy var injector: Injector = DependencyInjector()
    
    private init() { }
}
