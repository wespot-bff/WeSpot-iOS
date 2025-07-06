//
//  String+Extension.swift
//  Extensions
//
//  Created by 최지철 on 6/7/25.
//

import Foundation

public extension String {
    /// String.dateFormatter 형태로 호출하기 위한 포맷터
    static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy.MM.dd"      // 원하는 포맷으로 설정
        return f
    }()
}
