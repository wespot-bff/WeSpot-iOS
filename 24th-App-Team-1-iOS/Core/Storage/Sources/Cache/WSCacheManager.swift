//
//  WSCacheManager.swift
//  Storage
//
//  Created by 김도현 on 1/16/25.
//

import Foundation

public enum WSCacheKey: String {
    case voteOptions = "vote_options"
}


public final class WSCacheManager {
    private let cache = NSCache<NSString, AnyObject>()
    
    public static let shared = WSCacheManager()
    
    /// 캐시 데이터를  저장 하기 위한 메서드
    public func save<T: Decodable>(response: T, for key: String) {
        let wrapper = WSCacheWrapper(value: response)
        cache.setObject(wrapper, forKey: key as NSString)
    }
    
    /// 캐시 데이터를 가져오기 위한 메서드
    public func getResponse<T: Decodable>(for key: String) -> T? {
        guard let wrapper = cache.object(forKey: key as NSString) as? WSCacheWrapper<T> else {
            return nil
        }
        return wrapper.value
    }
    
    /// 캐시 데이터를 삭제하기 위한 메서드
    public func claer(for key: String) {
        cache.removeObject(forKey: key as NSString)
    }
}
