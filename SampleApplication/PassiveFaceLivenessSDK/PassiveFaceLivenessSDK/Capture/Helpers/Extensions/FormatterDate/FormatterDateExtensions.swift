/*
 *  © 2017-2019 Aware, Inc.  All Rights Reserved.
 *
 *  NOTICE:  All information contained herein is, and remains the property of Aware, Inc.
 *  and its suppliers, if any.  The intellectual and technical concepts contained herein
 *  are proprietary to Aware, Inc. and its suppliers and may be covered by U.S. and
 *  Foreign Patents, patents in process, and are protected by trade secret or copyright law.
 *  Dissemination of this information or reproduction of this material is strictly forbidden
 *  unless prior written permission is obtained from Aware, Inc.
 */

import Foundation
import UIKit




// 
// MARK: Extensions to format number as ISO 8601, RFC 3339, UTC time zone
// 

// Usage:
// let stringFromDate = Date().iso8601    // "2017-03-22T13:22:13.933Z"
//
// if let dateFromString = stringFromDate.dateFromISO8601 {
//     print(dateFromString.iso8601)      // "2017-03-22T13:22:13.933Z"
//}
internal extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}

internal extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}
