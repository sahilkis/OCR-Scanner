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


public enum DisplayMode: String {
    case verbose = "verbose"
    case standard = "standard"
    case minimal = "minimal"
    case none = "none"
    
    public static func fromString(term: String) -> DisplayMode {
        switch term {
        case "verbose": return .verbose
        case "standard": return .standard
        case "minimal": return .minimal
        case "none": return .none
        default:
            fatalError("Oops, invalid string input.")
        }
    }
}


//
// Analyze Video REQUEST -----------------------
//

// Server package response with JSON serialization.
//
// - parameters:
//     - "username" : username,
//     - "client_version": clientVersion,
//     - "client_device_brand": "Apple",
//     - "client_device_model": deviceModel,
//     - "client_os_version": osVersion,
//     - "workflow_data" : obfuscated workflow data]

//
// Analyze Video REQUEST -----------------------
//


public struct AnalyzeVideoObfuscatedRequest {
    let username: String
    let workflowData: WorkflowData
    
    var description: String {
        var message = ""
        
        message += "username: \(username) \n"
        message += "workflowData: \(workflowData.description) \n"
        
        // message += message.removeTrailingCommaSpace()
        
        return message
    }
    
    // Return JSON form of AnalyzeVideoRequest
    // Assumes frames are in base64http escaped string format.
    func asJSON() -> [String: Any] {
        
        // IDs:
        var versionId = ""
        if let verDict = Bundle.main.infoDictionary?["CFBundleVersion"] {
            versionId = "_" + (verDict as! String)
        }
        let shortVersionId: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        let clientVersion: String = appName + "_" + shortVersionId + versionId

        let deviceModel: String = UIDevice.current.type.rawValue
        let clientOSVersion: String = UIDevice.current.systemVersion
        
        // Get language/region
        let localization = Locale.preferredLanguages[0]
        
        var swiftVersion = ""
        
        #if swift(>=4.2)
            swiftVersion = "Swift 4.2"
        #elseif swift(>=4.1)
            swiftVersion = "Swift 4.1"
        #elseif swift(>=4.0.3)
            swiftVersion = "Swift 4.0.3"
        #elseif swift(>=4.0)
            swiftVersion = "Swift 4.0"
        #elseif swift(>=3.2)
            swiftVersion = "Swift 3.2"
        #elseif swift(>=3.1)
            swiftVersion = "Swift 3.1"
        #elseif swift(>=3.0.1)
            swiftVersion = "Swift 3.0.1"
        #elseif swift(>=2.2)
            swiftVersion = "Swift 2.2"
        #elseif swift(>=2.0)
            swiftVersion = "Swift 2.0"
        #endif
        
        let body: [String: Any] =
            ["username" : username,
             "client_version": clientVersion,
             "client_device_brand": "Apple",
             "client_device_model": deviceModel,
             "client_os_version": clientOSVersion,
             "localization": localization,
             "programming_language_version": swiftVersion,
             "workflow_data" : workflowData.asJSON()]
        
        // DEBUG - check ...
        // let isValidJSON = JSONSerialization.isValidJSONObject(body)
        // print("isValidJSON - AnalyzeVideoObfuscatedRequest: \(isValidJSON)")
        
        return body
    }
}

//
// WorkflowData Model -----------------------
//


public struct WorkflowData {
    let frames: [Frames]
    let profile: ProfileInfo
    let faceEvents: [String]
    let algorithms: [AlgorithmsModel]
    let autocaptureMinFrameCount: Int
    let faceDetectionMinSize: Double
    let faceDetectionMaxSize: Double
    let faceDetectionGranularity: Double
    let faceDetectionSensitivity: Double
    let faceDetectionMode: String
    let rotation: Int
    
    var description: String {
        var message = ""
        
        message += "frames: (skip printing) {...}\n"
        
        // NOTE: Skip printing of frames, too much data to display
        //        for frame in frames {
        //            message += "frame: " + frame.description + "\n "
        //        }
        
        message += "profile: {\n\(profile.description) }\n"
        
        message += "faceEvents: {\n"
        for event in faceEvents {
            message += event + "\n"
        }
        message += "}\n"
        
        message += "algorithms: {\n"
        for algo in algorithms {
            message += "\(algo.description)\n"
        }
        message += "}\n"
        
        message += "autocaptureMinFrameCount: \(autocaptureMinFrameCount)\n"
        message += "faceDetectionMinSize: \(faceDetectionMinSize)\n"
        message += "faceDetectionMaxSize: \(faceDetectionMaxSize)\n"
        message += "faceDetectionGranularity: \(faceDetectionGranularity)\n"
        message += "faceDetectionSensitivity: \(faceDetectionSensitivity)\n"
        message += "faceDetectionSensitivity: \(faceDetectionMode)\n"
        message += "rotation: \(rotation)" + "\n"
        
        // message += message.removeTrailingCommaSpace()
        
        return message
    }
    
    // Return JSON form of AnalyzeVideoRequest
    // Assumes frames are in base64http escaped string format.
    func asJSON() -> [String: Any] {
        
        var framesAsJSON = Array<[String: Any]>()
        for frame in frames {
            framesAsJSON.append(frame.asJSON())
        }
        
        var algosAsJSON = Array<[String: Any]>()
        for algo in algorithms {
            algosAsJSON.append(algo.asJSON())
        }
        
        let body: [String: Any] =
            ["frames": framesAsJSON,
             "profile": profile.asJSON(),
             "face_events": faceEvents,
             "algorithms": algosAsJSON,
             "autocapture_minimum_frame_count": autocaptureMinFrameCount,
             "face_detection_min_size": faceDetectionMinSize,
             "face_detection_max_size":  faceDetectionMaxSize,
             "face_detection_granularity":  faceDetectionGranularity,
             "face_detection_sensitivity":  faceDetectionSensitivity,
             "face_detection_mode":  faceDetectionMode,
             "rotation": rotation]
        
        // DEBUG - check ...
        // let isValidJSON = JSONSerialization.isValidJSONObject(body)
        // print("isValidJSON - WorkflowData: \(isValidJSON)")
        
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

public struct AnalyzeResponse {
    public var videoLiveness: AnalyzeVideoObfuscatedResponse?
    public var voiceLiveness: AnalyzeVoiceResponse?
}

public extension AnalyzeResponse {
    
    init?(json: [String: Any]) throws {
        
        // Optional
        self.videoLiveness = nil
        if let videoLivenessJSON = json["video"] as? [String: Any] {
            self.videoLiveness = try AnalyzeVideoObfuscatedResponse(json: videoLivenessJSON)
        }
        
        // Optional
        self.voiceLiveness = nil
        if let voiceLivenessJSON = json["voice"] as? [String: Any] {
            self.voiceLiveness = try AnalyzeVoiceResponse(json: voiceLivenessJSON)
        }
    }
    
    internal var description: String {
        var desc = ""
        
        if let videoLive = videoLiveness {
            desc += "videoLiveness: " + videoLive.description
        }
        
        if let voiceLive = voiceLiveness {
            desc += "voiceLiveness: " + voiceLive.description
        }
        
        return desc
    }
    
    func display(mode: DisplayMode, videoThreshold: Double?, voiceThreshold: Double?) -> String {
        var desc = ""
        var summary = ""
        
        if videoLiveness?.livenessResult != nil {
            if let vidThresh = videoThreshold {
                if Double((self.videoLiveness?.livenessResult?.score)!) > vidThresh { // videoLivenessThreshold {
                    summary += "\n" +
                        NSLocalizedString("Video", comment: "") + " - " +
                        NSLocalizedString("Live", comment: "")
                } else {
                    summary += "\n" +
                        NSLocalizedString("Video", comment: "") + " - " +
                        NSLocalizedString("Try Again", comment: "")
                }
            }
        } else {
            if self.videoLiveness?.autocaptureResult.capturedFrame.isEmpty == false {
                summary += "\n" +
                    NSLocalizedString("Video", comment: "") + " - " +
                    NSLocalizedString("Image captured", comment: "")
            } else {
                summary += "\n" +
                    NSLocalizedString("Video", comment: "") + " - " +
                    NSLocalizedString("No Image", comment: "")
            }
        }
        
        if voiceLiveness?.livenessResult != nil {
            if let voiceThresh = voiceThreshold {
                let score = (self.voiceLiveness?.livenessResult?.score)!
                if Double(score) > voiceThresh {
                    summary += "\n" +
                        NSLocalizedString("Voice", comment: "") + " - " +
                        NSLocalizedString("score", comment: "") + ": " +
                        NSLocalizedString(String(format: "%.2f", score), comment: "") + "\n" +
                        NSLocalizedString("Live", comment: "")
                } else {
                    summary += "\n" +
                        NSLocalizedString("Voice", comment: "") + " - " +
                        NSLocalizedString("score", comment: "") + ": " +
                        NSLocalizedString(String(format: "%.2f", score), comment: "") + "\n" +
                        NSLocalizedString("Try Again", comment: "")
                }
            }
        }
        
        switch mode {
        case DisplayMode.verbose:
            desc += summary + "\n\n"
            desc += NSLocalizedString("All results:", comment: "") + "\n"
            desc += "\(self as AnyObject)"
            break
        case DisplayMode.standard:
            fallthrough
        case DisplayMode.minimal:
            desc += summary
            break
        case DisplayMode.none:
            break
        }
        
        return desc
    }
    
    func asJSON() -> [String: Any] {

        var body: [String: Any] = [:]

        if let videoLive = videoLiveness {
            body["video"] = videoLive
        }

        if let voiceLive = voiceLiveness {
            body["voice"] = voiceLive
        }

        // DEBUG - check ...
        let isValidJSON = JSONSerialization.isValidJSONObject(body)
        print("isValidJSON - AnalyzeResponse: \(isValidJSON)")

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
public struct AnalyzeVideoObfuscatedResponse {
    
    public let livenessResult: LivenessResult?
    public let autocaptureResult: AutocaptureObfuscatedResult
}

public extension AnalyzeVideoObfuscatedResponse {
    
    /// Initializer - takes an Any argument that extracts and
    /// transforms data from the JSON representation into properties.
    ///
    /// - parameters
    ///   - json: input json
    init?(json: [String: Any]) throws {
        
        
        // Optional
        var livenessResultJson: [String: Any] = [:]
        if let livenessResultJsonOptional = json["liveness_result"] as? [String: Any] {
            livenessResultJson = livenessResultJsonOptional
        }

        // Mandatory
        guard let autocaptureResultJson = json["autocapture_result"] as? [String: Any] else {
            throw SerializationError.missing("autocapture_result")
        }
        
        if livenessResultJson.count > 0 {
            let livenessResult = try LivenessResult(json: livenessResultJson)!
            self.livenessResult = livenessResult
        } else {
            self.livenessResult = nil
        }
        let autocaptureResult = try AutocaptureObfuscatedResult(json: autocaptureResultJson)!
        
        self.autocaptureResult = autocaptureResult
    }
    
    internal var description: String {
        var des = ""
        
        if livenessResult != nil {
            des += "livenessResult: \(String(describing: livenessResult?.description)) \n"
        }
        des += "autocaptureResult: \(autocaptureResult.description) \n"

        return des
    }
    
    func display(mode: DisplayMode, videoThreshold: Double) -> String {
        var desc = ""
        var summary = ""
        
        if livenessResult != nil {
            
            if Double((self.livenessResult?.score)!) > videoThreshold {
                summary += "\n" + NSLocalizedString("Live", comment: "")
            } else {
                summary += "\n" + NSLocalizedString("Try Again", comment: "")
            }
        } else {
            
            if self.autocaptureResult.capturedFrame.isEmpty == false {
                summary += "\n" + NSLocalizedString("Image captured", comment: "")
            } else {
                summary += "\n" + NSLocalizedString("No Image", comment: "")
            }
        }
        
        switch mode {
        case DisplayMode.verbose:
            desc += summary + "\n\n"
            desc += NSLocalizedString("All results:", comment: "") + "\n"
            desc += "\(self as AnyObject)"
            break
        case DisplayMode.standard:
            fallthrough
        case DisplayMode.minimal:
            desc += summary
            break
        case DisplayMode.none:
            break
        }
        
        return desc
    }
    
    func asJSON() -> [String: Any] {
        var body: [String: Any]
        
        if livenessResult != nil {
            body = [
                "liveness_result": livenessResult?.asJSON() as Any,
                "autocapture_result": autocaptureResult.asJSON(),
            ]
        } else {
            body = [
                "liveness_result": "",
                "autocapture_result": autocaptureResult.asJSON(),
            ]
        }
        
        // DEBUG - check ...
        // let isValidJSON = JSONSerialization.isValidJSONObject(body)
        // print("isValidJSON - AnalyzeVideoObfuscatedResponse: \(isValidJSON)")
        
        return body
    }
    
}

