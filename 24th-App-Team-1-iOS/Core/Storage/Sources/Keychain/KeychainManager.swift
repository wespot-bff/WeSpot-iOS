//
//  KeychainManager.swift
//  Storage
//
//  Created by eunseou on 8/17/24.
//

import Foundation

import KeychainSwift

public class KeychainManager {
    
    public static let shared = KeychainManager()
    public let keychain = KeychainSwift()
    
    // 저장할 데이터
    public enum keychainType: String {
        case accessToken
        case refreshToken
    }
    
    private init() {}
    
    // 데이터 저장하기
    @discardableResult
    public func set(value: String, type: keychainType) -> Bool {
        return keychain.set(value, forKey: type.rawValue)
    }
    
    // 데이터 불러오기
    public func get(type: keychainType) -> String? {
        return keychain.get(type.rawValue)
    }
    
    // 데이터 삭제
    @discardableResult
    public func delete(type: keychainType) -> Bool {
        return keychain.delete(type.rawValue)
    }
    
    // 모든 데이터 삭제
    @discardableResult
    public func allClear() -> Bool {
        return keychain.clear()
    }
}
