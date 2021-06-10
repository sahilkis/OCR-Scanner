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

class ServerDocVidationClient {
    
    
    static func send(requestJson: String, completed: @escaping (_ error: Bool, _ jsonResponse: String?, _ errorMsg: String?) -> Void) {
        
        let errorMessage = "Error occured in document type validation"
        do {
            let validateDocumentTypeURL = NSURL(string:CommonConstants.VALIDATE_DOCUMENTS_TYPE_URL)!
            let request = NSMutableURLRequest(url: validateDocumentTypeURL as URL)
            let loginString = String(format: "%@:%@", CommonConstants.SERVICE_USERNAME, CommonConstants.SERVICE_PASSWORD).data(using: String.Encoding.utf8)!.base64EncodedString()
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
            request.httpBody = requestJson.data(using: .utf8)

            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                guard let data = data, error == nil else {
                    print("Error: \(String(describing: error))")
                    
                    print(String(describing: error))
                    completed(true, nil, errorMessage)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    print("statusCode should be 200, but is \(httpStatus.statusCode)")
                    completed(true, nil, errorMessage)
                    return
                }
                
                do {
                    let resp = String(data: data, encoding: .utf8)
                    completed(false, resp, nil)
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                    completed(true, nil, errorMessage)
                }
            }
            task.resume()
        } catch let error {
            print(error.localizedDescription)
            completed(true, nil, errorMessage)
        }
        
    }
    
}
