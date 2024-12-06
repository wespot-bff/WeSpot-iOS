//
//  FetchAppVersionItemUseCaseProtocol.swift
//  CommonDomain
//
//  Created by 김도현 on 12/6/24.
//

import Foundation

import RxSwift
import Extensions
import Storage

public enum WSUpdateTypes {
    case majorUpdate
    case minorUpdate
    case patchUpdate
    case noUpdate
}


public protocol FetchAppVersionItemUseCaseProtocol {
    func execute() async throws -> WSUpdateTypes
}

public final class FetchAppVersionItemUseCase: FetchAppVersionItemUseCaseProtocol {
    
    private let commonRepository: CommonRepositoryProtocol
    
    public init(commonRepository: CommonRepositoryProtocol) {
        self.commonRepository = commonRepository
    }
    
    public func execute() async throws -> WSUpdateTypes {
        let versionInfo = try await commonRepository.fetchAppVersionItem()
        let appVersion = Bundle.main.appVersion
        print("appversion : \(appVersion), min: \(versionInfo.minVersion) latest: \(versionInfo.latestVersion)")
        if compareVersion(versionA: appVersion, versionB: versionInfo.minVersion) == .orderedAscending {
            return .majorUpdate
        } else if compareVersion(versionA: appVersion, versionB: versionInfo.latestVersion) == .orderedAscending {
            return .minorUpdate
        } else {
            return .noUpdate
        }
    }
}


extension FetchAppVersionItemUseCase {
    private func compareVersion(versionA: String, versionB: String) -> ComparisonResult {
        let componentsA = versionA.split(separator: ".").compactMap { Int($0) }
        let componentsB = versionB.split(separator: ".").compactMap { Int($0) }
        
        let maxLength = max(componentsA.count, componentsB.count)
        let paddedA = componentsA + Array(repeating: 0, count: maxLength - componentsA.count)
        let paddedB = componentsB + Array(repeating: 0, count: maxLength - componentsB.count)
        
        for (_, (a, b)) in zip(paddedA, paddedB).enumerated() {
            if a < b {
                return .orderedAscending
            } else if a > b {
                return .orderedDescending
            }
        }
        return .orderedSame
    }
    
}

