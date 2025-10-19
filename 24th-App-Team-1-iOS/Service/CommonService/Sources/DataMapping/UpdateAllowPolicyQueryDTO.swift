//
//  UpdateAllowPolicyQueryDTO.swift
//  CommonService
//
//  Created by 김도현 on 10/14/25.
//


public struct UpdateAllowPolicyQueryDTO: Encodable {
    public let policyType: String
    
    public init(policyType: String) {
        self.policyType = policyType
    }
}
