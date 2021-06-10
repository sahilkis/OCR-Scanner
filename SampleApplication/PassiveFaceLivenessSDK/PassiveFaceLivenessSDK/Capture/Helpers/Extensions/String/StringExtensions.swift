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
import AVFoundation

// String can be thrown directly
extension String: Error {}

//
// Dictionary (JSON) Extensions
//

//Usage: print(json.prettyPrint())
extension Dictionary where Key == String, Value == Any {
    func prettyPrint() -> String{
        var string: String = ""
        if let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted){
            if let nstr = NSString(data: data, encoding: String.Encoding.utf8.rawValue){
                string = nstr as String
            }
        }
        return string
    }
}

//
// String Extensions
//

internal extension String {
    
    // Convert string to Double
    func toDouble() -> Double? {
        return NumberFormatter().number(from: self)?.doubleValue
    }
    
    // Convert string to UInt
    func toUInt() -> UInt? {
        return NumberFormatter().number(from: self)?.uintValue
    }
    
    // Convert string to Int
    func toInt() -> Int? {
        return NumberFormatter().number(from: self)?.intValue
    }
    
    /// Find all indices of substring in string
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
    
    /// Remove trailing ", "
    func removeTrailingCommaSpace() -> String {
        let delCharSet = NSCharacterSet(charactersIn: ", ")
        let temp = self.trimmingCharacters(in: delCharSet as CharacterSet)
        
        return temp
    }
    
    /// Remove trailing " "
    func removeTrailingSpace() -> String {
        let delCharSet = NSCharacterSet(charactersIn: " ")
        let temp = self.trimmingCharacters(in: delCharSet as CharacterSet)
        
        return temp
    }
    
    /// Remove trailing "\n"
    func removeTrailingCarriageReturn() -> String {
        let delCharSet = NSCharacterSet(charactersIn: "\n")
        let temp = self.trimmingCharacters(in: delCharSet as CharacterSet)
        
        return temp
    }
    
    /// Encode a String to Base64
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    /// Decode a String from Base64. Returns nil if unsuccessful.
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    
    /// Takes a base64 encoded string and makes the string properly escaped for
    /// transmission across http.
    func base64ToURLBase64() -> String {
        var temp = self.components(separatedBy: "=")[0] // Remove any trailing '='s
        temp = temp.replacingOccurrences(of: "+", with: "-")
        temp = temp.replacingOccurrences(of: "/", with: "_")
        
        return temp
    }
    
    
    /// Takes a URL base64 encoded string and decodes it to a standard
    /// base64 string.
    func urlBase64ToBase64() -> String
    {
        var temp = self
        temp = temp.replacingOccurrences(of: "-", with: "+")
        temp = temp.replacingOccurrences(of: "_", with: "/")
        
        switch (temp.count % 4) // Pad with trailing '='s
        {
        case 0: break // No pad chars in this case
        case 2: temp += "=="; break // Two pad chars
        case 3: temp += "="; break // One pad char
        default: break
        }
        
        return temp
    }
    
    /// For translating from string representation to AVCaptureDevice.Position
    func descriptionToPosition() -> AVCaptureDevice.Position {
       
        let description = self
        
        if description == "front" {
            return AVCaptureDevice.Position.front
        } else if description == "back" {
            return AVCaptureDevice.Position.back
        } else if description == "unspecified" {
            return AVCaptureDevice.Position.unspecified
        }
        
        return AVCaptureDevice.Position.unspecified
    }
    
    /// TODO: This is an app specific extension. Move to app.
    func mapWorkflowPickerDataNameToSelectedWorkflowName() -> String {
        
        let workflowPickerName = self
        var name = ""
        if workflowPickerName == "charlie - Passive" {
            name = "charlie"
        }
        return name
    }
   
    /// TODO: This is an app specific extension. Move to app.   
    func mapSelectedWorkflowNameToWorkflowPickerDataName() -> String {
        
        let selectedWorkflowName = self
        var name = ""
        if selectedWorkflowName == "charlie" {
            name = "charlie - Passive"
        }
        return name
    }
    
    
    func beautifyAutocaptureDescription() -> String {
        var newDesc = self.lowercased()
        newDesc = newDesc.replacingOccurrences(of: "_", with: " ")
        
        let first = String(newDesc.prefix(1)).capitalized
        let other = String(newDesc.dropFirst())
        
        newDesc = first + other
        
        return newDesc
    }
    
}

