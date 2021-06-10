/*
*  © 2017-2020 Aware, Inc.  All Rights Reserved.
*
*  NOTICE:  All information contained herein is, and remains the property of Aware, Inc.
*  and its suppliers, if any.  The intellectual and technical concepts contained herein
*  are proprietary to Aware, Inc. and its suppliers and may be covered by U.S. and
*  Foreign Patents, patents in process, and are protected by trade secret or copyright law.
*  Dissemination of this information or reproduction of this material is strictly forbidden
*  unless prior written permission is obtained from Aware, Inc.
*/

import Foundation

class DocAuthClient {
    
    static func sendAuthenticationRequest(docAuthenticationRequest: DocumentAuthenticationRequest, callback: @escaping (_ success: Bool, _ docAuthenticationResponse: DocumentAuthenticationResponse?, _ additionalMessage: String?) -> Void) {
        
        do {
            let url: NSURL = NSURL(string:CommonConstants.VERIFY_DOCUMENTS_AND_BIOMETRICS_URL)!
            let request = NSMutableURLRequest(url: url as URL)
            let loginString = String(format: "%@:%@", CommonConstants.SERVICE_USERNAME, CommonConstants.SERVICE_PASSWORD).data(using: String.Encoding.utf8)!.base64EncodedString()
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
            request.httpBody = try JSONEncoder().encode(docAuthenticationRequest)
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                if error == nil, let data = data {
                    let decodedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                    if (decodedString?.contains("ERROR"))! {
                        var errorMessage = "Unexpected Error"
                        do {
                            let errorDict = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                            if let errorMsg = errorDict["message"] as? String {
                                errorMessage = errorMsg
                            }
                        } catch {}
                        callback(false, nil, errorMessage)
                        return
                    }
                    do
                    {
                        
                        let documentAuthenticationResponse = try JSONDecoder().decode(DocumentAuthenticationResponse.self, from: data)
                        callback(true, documentAuthenticationResponse, nil)
                    }catch {
                        callback(false, nil, "Exception caught while reading server response: \(error)")
                    }
                } else {
                    callback(false, nil, (error?.localizedDescription)!)
                }
            }
            task.resume()
        }catch {
            print("Unexpected error occurs")
        }
        
    }
    
}
