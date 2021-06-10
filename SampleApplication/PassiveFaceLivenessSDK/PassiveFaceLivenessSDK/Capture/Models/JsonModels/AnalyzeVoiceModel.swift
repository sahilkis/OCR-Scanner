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


// VoiceSample: ----------------------------
internal struct VoiceSample {
    var data: String  // Base64 encoded voice sample
    var phrase: String
}

internal extension VoiceSample {

    init?(json: [String: Any]) throws {

        // Mandatory
        guard let data = json["data"] as? String else {
            throw SerializationError.missing("data")
        }
        
        // Mandatory
        guard let phrase = json["phrase"] as? String else {
            throw SerializationError.missing("phrase")
        }
        
        self.data = data
        self.phrase = phrase
    }

    internal var description: String {
        var desc = ""
        desc += "data: " + data
        desc += "phrase: " + phrase

        return desc
    }

    func asJSON() -> [String: Any] {

        var body: [String: Any]

        body = ["data": data,
                "phrase": phrase]

        // DEBUG - check ...
        let isValidJSON = JSONSerialization.isValidJSONObject(body)
        print("isValidJSON - VoiceSample: \(isValidJSON)")

        return body
    }
}

// VoiceLivenessResult: ----------------------------
internal struct VoiceLivenessResult {
    var score: Double
    var scoreReplay: Double
    var scoreTts: Double
    var scoreVc: Double
}

internal extension VoiceLivenessResult {
    
    init?(json: [String: Any]) throws {
        
        // Mandatory
        guard let score = json["score"] as? Double else {
            throw SerializationError.missing("score")
        }
        
        guard let scoreReplay = json["score_replay"] as? Double else {
            throw SerializationError.missing("score_replay")
        }
        
        guard let scoreTts = json["score_tts"] as? Double else {
            throw SerializationError.missing("score_tts")
        }
        
        guard let scoreVc = json["score_vc"] as? Double else {
            throw SerializationError.missing("score_vc")
        }
        
        self.score = score
        self.scoreReplay = scoreReplay
        self.scoreTts = scoreTts
        self.scoreVc = scoreVc
    }
    
    internal var description: String {
        var desc = ""
        desc += "score: \(score)"
        desc += "scoreReplay: \(scoreReplay)"
        desc += "scoreTts: \(scoreTts)"
        desc += "scoreVc: \(scoreVc)"

        return desc
    }
    
    func asJSON() -> [String: Any] {
        
        var body: [String: Any]
        
        body = ["score": score,
                "score_replay": scoreReplay,
                "score_tts": scoreTts,
                "score_vc": scoreVc]
        
        // DEBUG - check ...
        let isValidJSON = JSONSerialization.isValidJSONObject(body)
        print("isValidJSON - VoiceLivenessResult: \(isValidJSON)")
        
        return body
    }
}

//
// Analyze Voice RESPONSE -----------------------
//

/// Server package response with JSON serialization.
// Example response:
//    "voice": {
//        "liveness_result" =     {
//            score = "61.92245483398438";
//            "score_replay" = "38.0714225769043";
//            "score_tts" = "0.0044580115936696529";
//            "score_vc" = "0.0016634042840451002";
//        }
//
public struct AnalyzeVoiceResponse {
    
    var livenessResult: VoiceLivenessResult?
}

public extension AnalyzeVoiceResponse {
    
    /// Initializer - takes an Any argument that extracts and
    /// transforms data from the JSON representation into properties.
    ///
    /// - parameters
    ///   - json: input json
    init?(json: [String: Any]) throws {
   
        // Optional
        self.livenessResult = nil
        if let livenessResultJSON = json["liveness_result"] as? [String: Any] {
            self.livenessResult = try VoiceLivenessResult(json: livenessResultJSON)
        }
    }
    
    internal var description: String {
        
        var desc = ""
        
        if let lr = self.livenessResult {
            desc += "livenessResult: " + lr.description
        }
        
        return desc
    }
    
    func asJSON() -> [String: Any] {
        
        var body: [String: Any] = [:]
        
        if let lr = livenessResult {
            body["voice"] = lr
        }
        
        // DEBUG - check ...
        let isValidJSON = JSONSerialization.isValidJSONObject(body)
        print("isValidJSON - AnalyzeVoiceResponse: \(isValidJSON)")
        
        return body
    }
    
    
}

//
// Analyze Video RESPONSE -----------------------
//

/// Server package response with JSON serialization.
///
/// - parameters:
///   - livenessResult: LivenessResult struct
///   - autocaptureResult: AutocaptureObfuscatedResult struct
///
internal struct AnalyzeVoiceObfuscatedResponse {
        
    let livenessResult: LivenessResult
}

internal extension AnalyzeVoiceObfuscatedResponse {
    
    /// Initializer - takes an Any argument that extracts and
    /// transforms data from the JSON representation into properties.
    ///
    /// - parameters
    ///   - json: input json
    init?(json: [String: Any]) throws {
        
        // Mandatory
        guard let livenessResult = json["liveness_result"] as? LivenessResult else {
            throw SerializationError.missing("liveness_result")
        }
        
        self.livenessResult = livenessResult
    }
}

