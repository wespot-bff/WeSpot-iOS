//
//  VoteProcessDIContaier.swift
//  VoteFeature
//
//  Created by 김도현 on 12/16/24.
//

import Foundation

import CommonDomain
import Util

public final class VoteProcessDIContainer: BaseDIContainer {
    public typealias ViewController = VoteProcessViewController
    public typealias Reactor = VoteProcessViewReactor
    
    private let voteResponseEntity: VoteResponseEntity?
    
    
    public init(voteResponseEntity: VoteResponseEntity?) {
        self.voteResponseEntity = voteResponseEntity
    }
    
    
    public func makeViewController() -> VoteProcessViewController {
        return VoteProcessViewController(reactor: makeReactor())
    }
    
    public func makeReactor() -> VoteProcessViewReactor {
        return VoteProcessViewReactor(voteResponseEntity: voteResponseEntity)
    }
}
