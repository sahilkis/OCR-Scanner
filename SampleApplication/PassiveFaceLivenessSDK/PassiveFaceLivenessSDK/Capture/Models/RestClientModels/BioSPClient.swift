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

public enum BioSPRequestType: String {
    case PLAINTEXT
    case BASE64
    
    func convert(rawData: Data) -> Data {
        switch self {
        case .PLAINTEXT:
            return rawData
        case .BASE64:
            let base64Prefix = "base64encoded:"
            let base64DataString = String(data: rawData, encoding: .utf8)!.toBase64()
            let res = base64Prefix + base64DataString
            return res.data(using: .utf8)!
        }
    }
    
    func convertToString(rawData: Data) -> String {
        switch self {
        case .PLAINTEXT:
            return String(data: rawData, encoding: .utf8)!.toBase64()
        case .BASE64:
            let base64Prefix = "base64encoded:"
            let base64DataString = String(data: rawData, encoding: .utf8)!.toBase64()
            let res = base64Prefix + base64DataString
            return res
        }
    }
}

class BioSPClient: RestClient {
    
    var analyzeVideoCompletionHandler: StatusResponseCompletionHandler = {
        (status, response) in
        var data: [String: Any]?
        
        func analyzeFunc() -> [String: Any]? {
            return data
        }
        
        if status == true {            
            if let response = response {
                print(response)
                if let jsonResult = response as? Dictionary<String, Any> {
                    data = jsonResult
                    return analyzeFunc
                }
            }
        }
        
        return analyzeFunc
    }
    
    public func analyzeVideo(urlFullString: String, bioSPUsername: String, biospPassword:String, sessionId: String?, json: [String: Any]) {

        guard let url = URL(string: urlFullString) else {
            print("Error: cannot create URL for: " + urlFullString)
            
            // propogate failure
            onResponseReceived(
                restCommand: ClientRestCommand.analyze,
                status: false,
                response: nil,
                message: "Could not create URL from: " + urlFullString)
            
            return
        }
        
        var urlRequest = URLRequest(url: url)
        let body: [String: Any] = json
        let isValidJSON = JSONSerialization.isValidJSONObject(body)
        if isValidJSON == true {
            do {
                let analyzeVideoRequestJSON =
                    try JSONSerialization.data(withJSONObject: body, options: JSONSerialization.WritingOptions.prettyPrinted)
                
                let faceLivenessRequest = FaceLivenessRequest()
                faceLivenessRequest.serverPackage = LivenessAppUIClientServerViewController.biospRequestType.convertToString(rawData: analyzeVideoRequestJSON)
                faceLivenessRequest.sessionId = sessionId
                
                urlRequest.httpBody = try JSONEncoder().encode(faceLivenessRequest)
                
            } catch {
                print("analyzeVideoRequestJSON failed")
                return
            }
        }

        let loginString = String(format: "%@:%@", bioSPUsername, biospPassword).data(using: String.Encoding.utf8)!.base64EncodedString()
        urlRequest.setValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        post(restCommand: ClientRestCommand.analyze, request: urlRequest, timeoutInterval: 120.0, completion: analyzeVideoCompletionHandler)
    }
}
