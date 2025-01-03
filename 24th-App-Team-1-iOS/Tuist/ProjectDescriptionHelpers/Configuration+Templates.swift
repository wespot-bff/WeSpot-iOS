//
//  Configuration+Templates.swift
//  ProjectDescriptionHelpers
//
//  Created by Kim dohyun on 7/10/24.
//

@preconcurrency import ProjectDescription


public enum BuildTarget: String {
    case dev = "DEV"
    case prd = "PRD"
    
    var configurationName: ConfigurationName {
        return .configuration(self.rawValue)
    }
}

public extension Configuration {
    static func build(_ type: BuildTarget, name: String = "" ) -> Self {
        switch type {
        case .dev:
            return .debug(
                name: BuildTarget.dev.configurationName,
                xcconfig: .relativeToXCConfig(type)
            )
        case .prd:
            return .release(
                name: BuildTarget.prd.configurationName,
                xcconfig: .relativeToXCConfig(type)
            )
        }
    }
}


