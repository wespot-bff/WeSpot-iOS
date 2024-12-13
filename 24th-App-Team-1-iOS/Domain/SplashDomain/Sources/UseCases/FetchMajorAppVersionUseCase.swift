//
//  FetchMajorAppVersionUseCase.swift
//  SplashDomain
//
//  Created by 김도현 on 12/8/24.
//

import Foundation

import CommonDomain
import Extensions

public enum MajorUpdateTypes {
    case major
    case noUpdate
}

public protocol FetchMajorAppVersionUseCaseProtocol {
    func execute() async throws -> MajorUpdateTypes
}


public final class FetchMajorAppVersionUseCase: FetchMajorAppVersionUseCaseProtocol {
        
    private let commonRepository: CommonRepositoryProtocol
    
    public init(commonRepository: CommonRepositoryProtocol) {
        self.commonRepository = commonRepository
    }
    
    public func execute() async throws -> MajorUpdateTypes {
        let versionInfo = try await commonRepository.fetchAppVersionItem()
        let appVersion = Bundle.main.appVersion
        
        if self.compareVersion(versionA: appVersion, versionB: versionInfo.minVersion) == .orderedAscending {
            return .major
        }
        
        return .noUpdate
        
    }
}

extension FetchMajorAppVersionUseCase {
    public func compareVersion(versionA: String, versionB: String) -> ComparisonResult {
        let componentsA = versionA.split(separator: ".").map { Int($0) ?? 0 }
        let componentsB = versionB.split(separator: ".").map { Int($0) ?? 0 }
        
        let majorA = componentsA.indices.contains(0) ? componentsA[0] : 0
        let majorB = componentsB.indices.contains(0) ? componentsB[0] : 0
        
        if majorA < majorB { return .orderedAscending }
        if majorA > majorB { return .orderedDescending }
        
        return .orderedSame
    }
}
