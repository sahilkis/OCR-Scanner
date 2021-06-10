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



// Throw SerializationError for required fields
enum SerializationError: Error {
    case missing(String)
    case invalid(String, Any)
}

//
// Frames:
//

struct Frames {
    let data: String // base64 encoded
    let timestamp: Double
    let tags: [String]
}

extension Frames {
    
    init?(json: [String: Any]) throws {
        
        guard let data = json["data"] as? String else {
            throw SerializationError.missing("data")
        }
        
        guard let timestamp = json["timestamp"] as? Double else {
            throw SerializationError.missing("timestamp")
        }
        
        guard let tags = json["tags"] as? [String] else {
            throw SerializationError.missing("tags")
        }
        
        self.data = data
        self.timestamp = timestamp
        self.tags = tags
    }
    
    public var description: String {
        var desc = ""
        
        desc += "data: \(data) \n"
        
        desc += "timestamp: \(timestamp) \n"
        
        desc += "tags: {"
        for tag in tags {
            desc += tag + ", "
        }
        desc = desc.removeTrailingCommaSpace()
        desc += "}"
        
        return desc
    }
    
    func asJSON() -> [String: Any] {
        
        let body: [String: Any] =
            [ "data": data,
              "timestamp": timestamp,
              "tags": tags]
        
        // DEBUG - check ...
        // let isValidJSON = JSONSerialization.isValidJSONObject(body)
        // print("isValidJSON - Frames: \(isValidJSON)")
        
        return body
    }
    
}

// AlgorithmResultModel: --------------------------
struct AlgorithmResultModel {
    var name: String
    var feedback: [String]
    var score: Double?
}

extension AlgorithmResultModel {
    init?(json: [String: Any]) throws {
        guard let name = json["name"] as? String else {
            throw SerializationError.missing("name")
        }
        
        guard let feedback = json["feedback"] as? [String] else {
            throw SerializationError.missing("feedback")
        }
        
        // let score = json["score"] as? Double ?? nil
        if let scoreDouble = json["score"] as? Double {
            self.score = scoreDouble
        } else if let scoreInt = json["score"] as? Int {
            self.score = Double(scoreInt)
        }

        self.name = name
        self.feedback = feedback
    }
    
    public var description: String {
        var des = "";
        
        des += "name: " + name + "\n"
        des += "feedback: "
        for fb in feedback {
            des += fb + " "
        }
        des += "\n"
        des += "score: \(String(describing: score)) \n"
        
        return des
    }
    
    func asJSON() -> [String: Any] {
        var body: [String: Any]
        
        if score != nil {
            body = [
                "name": name,
                "feedback": feedback,
                "score": score as Any
            ]
        } else {
            body = [
                "name": name,
                "feedback": feedback
            ]
        }
        
        return body
    }
}

// FaceEventModel: --------------------------
struct FaceEventModel {
    var name: String
    var feedback: [String]
    var score: Double
}

extension FaceEventModel {
    init?(json: [String: Any]) throws {
        guard let name = json["name"] as? String else {
            throw SerializationError.missing("name")
        }
        
        guard let feedback = json["feedback"] as? [String] else {
            throw SerializationError.missing("feedback")
        }
        
        guard let score = json["score"] as? Double else {
            throw SerializationError.missing("score")
        }
        
        self.name = name
        self.feedback = feedback
        self.score = score
    }
    
    public var description: String {
        var des = "";
        
        des += "name: " + name + "\n"
        des += "feedback: "
        for fb in feedback {
            des += fb + " "
        }
        des += "\n"
        des += "score: \(score) \n"
        
        return des
    }
    
    func asJSON() -> [String: Any] {
        var body: [String: Any]
        
        body = [
            "name": name,
            "feedback": feedback,
            "score": score
        ]
        
        return body
    }
}

// AutoCaptureResultModel: --------------------------
struct AutoCaptureResultModel {
    var capturedFrameIndex: Int
    var feedback: [String]
}

extension AutoCaptureResultModel {
    init?(json: [String: Any]) throws {
        guard let capturedFrameIndex = json["captured_frame_index"] as? Int else {
            throw SerializationError.missing("captured_frame_index")
        }
        
        guard let feedback = json["feedback"] as? [String] else {
            throw SerializationError.missing("feedback")
        }
        
        self.capturedFrameIndex = capturedFrameIndex
        self.feedback = feedback
    }
    
    public var description: String {
        var des = "";
        
        des += "captured_frame_index: \(capturedFrameIndex) \n"
        des += "feedback: "
        for fb in feedback {
            des += fb + " "
        }
        des += "\n"
        
        return des
    }
    
    func asJSON() -> [String: Any] {
        var body: [String: Any]
        
        body = [
            "captured_frame_index": capturedFrameIndex,
            "feedback": feedback
        ]
        
        return body
    }
}

/// Feedback and captured image in base64.
///
/// - parameters:
///   - capturedFrame: Base64 image.
///   - feedback: String array of feedback messages.
public struct AutocaptureObfuscatedResult {
    let capturedFrame: String
    let feedback: [String]
}

internal extension AutocaptureObfuscatedResult {
    
    init?(json: [String: Any]) throws {
        
        guard let capturedFrame = json["captured_frame"] as? String else {
            throw SerializationError.missing("capturedFrame")
        }
        
//        guard let feedback = json["feedback"] as? [String] else {
//            throw SerializationError.missing("feedback")
//        }
//        self.feedback = feedback
        
        self.feedback = json["feedback"] as? [String] == nil ? [String]() : json["feedback"] as! [String]
        self.capturedFrame = capturedFrame

    }
    
    internal var description: String {
        var desc = ""
        
        desc += "capturedFrame: \(capturedFrame) \n"
        
        desc += "feedback: {"
        for fb in feedback {
            desc += fb + ", "
        }
        desc = desc.removeTrailingCommaSpace()
        desc += "}"
        
        return desc
    }
    
    func asJSON() -> [String: Any] {
        
        let body: [String: Any] =
            [ "captured_frame": capturedFrame,
              "feedback": feedback]
        
        // DEBUG - check ...
        // let isValidJSON = JSONSerialization.isValidJSONObject(body)
        // print("isValidJSON - AutocaptureObfuscatedResult: \(isValidJSON)")
        
        return body
    }
    
}

//
// Liveness Result:
//

/// Feedback and captured image in base64.
///
/// - parameters:
///   - score: Double value, a high value indicates likely live,
///     a low value indicates possible spoof.
///   - feedback: String array of feedback messages.
public struct LivenessResult {
    public let score: Double
    public let feedback: [String]
}

public extension LivenessResult {
    
    init?(json: [String: Any]) throws {
        
        guard let score = json["score"] as? Double else {
            throw SerializationError.missing("score")
        }
        
//        guard let feedback = json["feedback"] as? [String] else {
//            throw SerializationError.missing("feedback")
//        }
//        self.feedback = feedback
        
        self.feedback = json["feedback"] as? [String] == nil ? [String]() : json["feedback"] as! [String]
        self.score = score

    }
    
    internal var description: String {
        var desc = ""
        
        desc += "score: \(score) \n"
        
        desc += "feedback: {"
        for fb in feedback {
            desc += fb + ", "
        }
        desc = desc.removeTrailingCommaSpace()
        desc += "}"
        
        return desc
    }
    
    func asJSON() -> [String: Any] {
        
        let body: [String: Any] =
            [ "score": score,
              "feedback": feedback]
        
        // DEBUG - check ...
        // let isValidJSON = JSONSerialization.isValidJSONObject(body)
        // print("isValidJSON - LivenessResult: \(isValidJSON)")
        
        return body
    }
    
}


//
// AlgoEventResult:
//

/// Algorithm and event results.
///
/// - parameters:
///   - name: Name of algorithm or event.
///   - feedback: Array of String feedback messages.
internal struct AlgoEventResult {
    let name: String
    let feedback: [String]
}

internal extension AlgoEventResult {
    
    init?(json: [String: Any]) throws {
        
        guard let name = json["name"] as? String else {
            throw SerializationError.missing("name")
        }
        
        guard let feedback = json["feedback"] as? [String] else {
            throw SerializationError.missing("feedback")
        }
        
        self.name = name
        self.feedback = feedback
    }
    
    internal var description: String {
        var desc = ""
        
        desc += "name: \(name) \n"
        
        desc += "feedback: {"
        for fb in feedback {
            desc += fb + ", "
        }
        desc = desc.removeTrailingCommaSpace()
        desc += "}"
        
        return desc
    }
    
    func asJSON() -> [String: Any] {
        
        let body: [String: Any] =
            [ "name": name,
              "feedback": feedback]
        
        // DEBUG - check ...
        // let isValidJSON = JSONSerialization.isValidJSONObject(body)
        // print("isValidJSON - AlgoEventResult: \(isValidJSON)")
        
        return body
    }
    
}

// FrameTag: --------------------------
struct FrameTag {
    let index: Int
    let tags: [String]
}

extension FrameTag {
    
    init?(json: [String: Any]) throws {
        
        guard let index = json["index"] as? Int else {
            throw SerializationError.missing("index")
        }
        
        guard let tags = json["tags"] as? [String] else {
            throw SerializationError.missing("tags")
        }
        
        self.index = index
        self.tags = tags
    }
    
    public var description: String {
        var desc = ""
        
        desc += "index: \(index) \n"
        
        desc += "tags: {"
        for tag in tags {
            desc += tag + ", "
        }
        desc = desc.removeTrailingCommaSpace()
        desc += "}"
        
        return desc
    }
    
    func asJSON() -> [String: Any] {
        
        let body: [String: Any] =
            [ "index": index,
              "tags": tags]
        
        // DEBUG - check ...
        // let isValidJSON = JSONSerialization.isValidJSONObject(body)
        // print("isValidJSON - FrameTag: \(isValidJSON)")
        
        return body
    }
    
}


// ProfileInfo: --------------------------
struct ProfileInfo {
    let name: String
    let xml: String
}

extension ProfileInfo {
    
    init?(json: [String: Any]) throws {
        
        guard let name = json["name"] as? String else {
            throw SerializationError.missing("name")
        }
        
        guard let xml = json["xml"] as? String else {
            throw SerializationError.missing("xml")
        }
        
        self.name = name
        self.xml = xml
    }
    
    public var description: String {
        var desc = ""
        
        desc += "name: \(name) \n"
        
        desc += "xml: \(xml) \n"
        
        return desc
    }
    
    func asJSON() -> [String: Any] {
        
        let body: [String: Any] =
            [ "name": name,
              "xml": xml]
        
        // DEBUG - check ...
        // let isValidJSON = JSONSerialization.isValidJSONObject(body)
        // print("isValidJSON - ProfileInfo: \(isValidJSON)")
        
        return body
    }
    
}

