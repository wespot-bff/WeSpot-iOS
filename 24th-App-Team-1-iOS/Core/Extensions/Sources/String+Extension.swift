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
        f.dateFormat = "yyyy.MM.dd"
        return f
    }()
    
    func formattedRelative() -> String {
        guard let date = Self.isoFormatter.date(from: self) else {
            return self
        }

        let now = Date()
        let interval = now.timeIntervalSince(date)

        if interval < 10 * 60 {
            return "방금"
        }

        let calendar = Calendar.current
        if calendar.isDate(date, equalTo: now, toGranularity: .year) {
            return Self.thisYearFormatter.string(from: date)
        } else {
            return Self.otherYearFormatter.string(from: date)
        }
    }

    private static let isoFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone(secondsFromGMT: 0)
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return f
    }()

    private static let thisYearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "MM.dd HH:mm"
        return f
    }()

    private static let otherYearFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ko_KR")
        f.dateFormat = "yy.MM.dd HH:mm"
        return f
    }()
}
