//
//  FetchMinorAppVersionUseCase.swift
//  CommonDomain
//
//  Created by 김도현 on 12/8/24.
//

import Foundation

import Storage
import Extensions


public enum MinorUpdateTypes {
    case minor(type: String)
    case noUpdate
}


public protocol FetchMinorAppVersionUseCaseProtocol {
    func execute() async throws -> MinorUpdateTypes
}

public final class FetchMinorAppVersionUseCase: FetchMinorAppVersionUseCaseProtocol {
    
    private let commonRepository: CommonRepositoryProtocol
    
    public init(commonRepository: CommonRepositoryProtocol) {
        self.commonRepository = commonRepository
    }
    
    public func execute() async throws -> MinorUpdateTypes {
        let versionInfo = try await commonRepository.fetchAppVersionItem()
        let appVersion = Bundle.main.appVersion
        
        if self.compareVersion(versionA: appVersion, versionB: versionInfo.latestVersion) == .orderedAscending {
            if UserDefaultsManager.shared.lastPromptedVersion != versionInfo.latestVersion {
                UserDefaultsManager.shared.lastPromptedVersion = versionInfo.latestVersion
                if versionInfo.updateType == "USABILITY_IMPROVEMENT" {
                    return .minor(type: "usability")
                } else {
                    return .minor(type: "feature")
                }
            }
        }
        return .noUpdate
    }
}

extension FetchMinorAppVersionUseCase {
    func compareVersion(versionA: String, versionB: String) -> ComparisonResult {
       let componentsA = versionA.split(separator: ".").map { Int($0) ?? 0 }
       let componentsB = versionB.split(separator: ".").map { Int($0) ?? 0 }
        
       let minorA = componentsA.indices.contains(1) ? componentsA[1] : 0
       let minorB = componentsB.indices.contains(1) ? componentsB[1] : 0
       
       
       if minorA < minorB { return .orderedAscending }
       if minorA > minorB { return .orderedDescending }
       return .orderedSame
   }
}

