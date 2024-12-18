//
//  BaseDIContainer.swift
//  Util
//
//  Created by 김도현 on 12/16/24.
//

import Foundation


public protocol BaseDIContainer {
    associatedtype ViewController
    associatedtype Reactor
    
    
    func makeViewController() -> ViewController
    func makeReactor() -> Reactor
}
