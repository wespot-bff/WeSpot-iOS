//
//  Single+Rx.swift
//  Util
//
//  Created by 최지철 on 12/3/24.
//

import Foundation

import Alamofire
import RxSwift

extension Observable where Element == Data {
    /// Raw JSON을 로깅하는 확장 메서드
    /// - Parameter category: 로그 카테고리
    /// - Returns: 로깅이 적용된 Observable
    public func logRawJSON(category: some CustomStringConvertible = Network.default) -> Observable<Element> {
        return self.do(onNext: { data in
            if let jsonString = String(data: data, encoding: .utf8) {
                WSLogger.debug(category: category, message: "Raw JSON Response: \(jsonString)")
            } else {
                WSLogger.error(category: category, message: "응답 데이터를 문자열로 변환하는 데 실패했습니다.")
            }
        }, onError: { error in
            WSLogger.error(category: category, message: "로깅 중 에러 발생: \(error.localizedDescription)")
        })
    }
}
