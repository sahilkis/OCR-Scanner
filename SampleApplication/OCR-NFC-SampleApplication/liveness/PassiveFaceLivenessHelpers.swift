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
import PassiveFaceLivenessSDK


class PassiveFaceLivenessHelpers {
    
    /// Colorize specific text according to the hard coded dictionary, "strings"
    /// within this function:
    ///     "Likely Spoof" - red
    ///     "Spoof" - red
    ///     "Live" - green
    ///     "Undetermined" - blue
    public static func colorizeMessage(message: String) -> NSAttributedString {
        
        let normalGreen = UIColor(red: CGFloat(37/255.0), green: CGFloat(143/255.0), blue: CGFloat(0.0), alpha: CGFloat(1.0))
        
        let strings =
            [
                [
                    "text" : NSLocalizedString("Likely Spoof", comment: ""),
                    "color" : UIColor.red
                ],
                [
                    "text" : NSLocalizedString("Spoof", comment: ""),
                    "color" : UIColor.red
                ],
                [
                    "text" : NSLocalizedString("Live", comment: ""),
                    "color" : normalGreen
                ],
                [
                    "text" : NSLocalizedString("Undetermined", comment: ""),
                    "color" : UIColor.blue
                ],
                [
                    "text" : NSLocalizedString("Try Again", comment: ""),
                    "color" : UIColor.red
                ]
        ]
        
        let attributedString = NSMutableAttributedString(string: message)
        for configDict in strings {
            
            // reset loc for each text string
            var loc = NSRange()
            if let color = configDict["color"] as? UIColor, let text = configDict["text"] as? String {
                
                let indices = message.indicesOf(string: text)
                
                for index in indices {
                    loc.location = index
                    loc.length = text.count
                    attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: loc)
                }
            }
        }
        
        return attributedString
    }
}

extension String {
    func indicesOf(string: String) -> [Int] {
        var indices = [Int]()
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
            let range = self.range(of: string, range: searchStartIndex..<self.endIndex),
            !range.isEmpty
        {
            let index = distance(from: self.startIndex, to: range.lowerBound)
            indices.append(index)
            searchStartIndex = range.upperBound
        }
        
        return indices
    }
}

