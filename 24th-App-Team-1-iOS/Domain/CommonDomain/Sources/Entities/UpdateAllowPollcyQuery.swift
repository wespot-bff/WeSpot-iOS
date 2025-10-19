//
//  UpdateAllowPollcyQuery.swift
//  CommonDomain
//
//  Created by 김도현 on 10/14/25.
//



public struct UpdateAllowPollcyQuery {
    public let policyType: String
    
    public init(policyType: String) {
        self.policyType = policyType
    }
}
