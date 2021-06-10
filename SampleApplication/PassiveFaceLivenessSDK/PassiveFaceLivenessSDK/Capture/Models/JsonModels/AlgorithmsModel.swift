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


struct AlgorithmsModel {
    let name: String
    let threshold: Int
    var score: Double?
}

extension AlgorithmsModel {
    
    init?(json: [String: Any]) throws {
        
        guard let name = json["name"] as? String else {
            throw SerializationError.missing("name")
        }
        
        guard let threshold = json["threshold"] as? Int else {
            throw SerializationError.missing("threshold")
        }
        
        // Optional
        self.score = nil
        if let score = json["score"] as? Double {
            self.score = score
            
        }
        
        self.name = name
        self.threshold = threshold
    }
    
    public var description: String {
        var desc = ""
        
        desc += "name: " + name + "\n"
        desc += "threshold: \(threshold)"
        
        if let sc = score {
            desc += "score: " + sc.description + "\n"
        }
        
        return desc
    }
    
    func asJSON() -> [String: Any] {
        
        var body: [String: Any]
        
        if let sc = score {
            body = [ "name": name,
                     "threshold": threshold,
                     "score": sc]
        } else {
            body = [ "name": name,
                     "threshold": threshold]
        }
        
        // DEBUG - check ...
        // let isValidJSON = JSONSerialization.isValidJSONObject(body)
        // print("isValidJSON - AlgorithmsModel: \(isValidJSON)")
        
        return body
    }
    
}

struct AlgoThresholdModel {
    var algorithm: String
    var messages: AlgoMessagesModel
    var threshold: Int
}

extension AlgoThresholdModel {
    
    init?(json: [String: Any]) throws {
        
        guard let algorithm = json["algorithm"] as? String else {
            throw SerializationError.missing("algorithm")
        }
        
        guard let messages = json["messages"] as? AlgoMessagesModel else {
            throw SerializationError.missing("messages")
        }
        
        guard let threshold = json["threshold"] as? Int else {
            throw SerializationError.missing("threshold")
        }
        
        self.algorithm = algorithm
        self.messages = messages
        self.threshold = threshold
    }
    
    public var description: String {
        var desc = ""
        
        desc += "algorithm: " + algorithm + "\n"
        desc += "messages: " + messages.description + "\n"
        desc += "threshold: \(threshold)"
        
        return desc
    }
    
    func asJSON() -> [String: Any] {
        
        let body: [String: Any] =
            [ "algorithm": algorithm,
              "messages": messages.asJSON(),
              "threshold": threshold]
        
        // DEBUG - check ...
        // let isValidJSON = JSONSerialization.isValidJSONObject(body)
        // print("isValidJSON - AlgoThresholdModel: \(isValidJSON)")
        
        return body
    }
}


struct AlgoMessagesModel {
    let high: String
    let low: String
    let minus1: String
}

extension AlgoMessagesModel {
    
    init?(json: [String: Any]) throws {
        
        guard let high = json["high"] as? String else {
            throw SerializationError.missing("high")
        }
        
        guard let low = json["low"] as? String else {
            throw SerializationError.missing("low")
        }
        
        guard let minus1 = json["minus1"] as? String else {
            throw SerializationError.missing("minus1")
        }
        
        self.high = high
        self.low = low
        self.minus1 = minus1
    }
    
    public var description: String {
        var desc = ""
        
        desc += "high: " + high + ", "
        desc += "low: " + low + ", "
        desc += "minus1: " + minus1
        
        return desc
    }
    
    func asJSON() -> [String: Any] {
        
        let body: [String: Any] =
            [ "high": high,
              "low": low,
              "minus1": minus1]
        
        // DEBUG - check ...
        // let isValidJSON = JSONSerialization.isValidJSONObject(body)
        // print("isValidJSON - AlgoMessagesModel: \(isValidJSON)")
        
        return body
    }
}


