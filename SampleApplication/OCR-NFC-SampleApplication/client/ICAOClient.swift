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

class ICAOClient {
    
    public static func requestForValidateSession(callback: @escaping (_ error: Bool, _ icaoSessionResponse: ICAOSessionResponse?, _ errorMsg: String?)-> Void) {
       
        let url: NSURL = NSURL(string:CommonConstants.ICAO_REQUEST_FOR_VALIDATE_SESSION_URL)!
        let request = NSMutableURLRequest(url: url as URL)
        let loginString = String(format: "%@:%@", CommonConstants.SERVICE_USERNAME, CommonConstants.SERVICE_PASSWORD).data(using: String.Encoding.utf8)!.base64EncodedString()
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
            
            guard let data = data, error == nil else {
                print("[ICAOClient - requestForValidateSession] Error: \(String(describing: error))")
                callback(true, nil, "Error occured in requesting validate session from server")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                var errorMessage = "Error occured in requesting validate session from server, http code: \(httpStatus.statusCode)"
                print("[ICAOClient - requestForValidateSession] http status code: \(httpStatus.statusCode)")
                do {
                    let detailedErrorInfo = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                    if let detailedErrorMessage = detailedErrorInfo["message"] as? String {
                        errorMessage = detailedErrorMessage
                    }
                } catch let err {
                    print(err)
                }
                callback(true, nil, errorMessage)
                return
            }
            
            // http code 200
            do {
                let icaoSessionResponse: ICAOSessionResponse = try JSONDecoder().decode(ICAOSessionResponse.self, from: data)
                
                callback(false, icaoSessionResponse, nil)
            } catch {
                callback(true, nil, "Exception caught while reading server response or error occured in parsing response to ICAOSessionResponse: \(error)")
            }
        }
        task.resume()
    }
    
    
    
    public static func doICAOValidation(icaoValidationRequest: ICAOValidationRequest, callback: @escaping (_ error: Bool, _ icaoValidationResponse: ICAOValidationResponse?, _ errorMsg: String?)-> Void) {
        
        do {
            let url: NSURL = NSURL(string:CommonConstants.ICAO_VERIFY_DATA_GROUPS_URL)!
            let request = NSMutableURLRequest(url: url as URL)
            let loginString = String(format: "%@:%@", CommonConstants.SERVICE_USERNAME, CommonConstants.SERVICE_PASSWORD).data(using: String.Encoding.utf8)!.base64EncodedString()
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
            request.httpBody = try JSONEncoder().encode(icaoValidationRequest)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                guard let data = data, error == nil else {
                    print("[ICAOClient - preparePassiveAuthentication] Error: \(String(describing: error))")
                    callback(true, nil, "Error occured in obtaining passive authentication response from server")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    var errorMessage = "Error occured in obtaining passive authentication response from server, http code: \(httpStatus.statusCode)"
                    print("[ICAOClient - preparePassiveAuthentication] http status code: \(httpStatus.statusCode)")
                    do {
                        let detailedErrorInfo = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                        if let detailedErrorMessage = detailedErrorInfo["message"] as? String {
                            errorMessage = detailedErrorMessage
                        }
                    } catch let err {
                        print(err)
                    }
                    callback(true, nil, errorMessage)
                    return
                }
                
                // http code 200
                do {
                    let icaoValidationResponse = try JSONDecoder().decode(ICAOValidationResponse.self, from: data)
                    
                    callback(false, icaoValidationResponse, nil)
                } catch {
                    callback(true, nil, "Exception caught while reading server response or error occured in parsing response to ICAOValidationResponse: \(error)")
                }
            }
            task.resume()
        }catch {
            print("[ICAOClient - preparePassiveAuthentication] Unexpected error occurs")
            callback(true, nil, "Unexpected error occurs")
        }
        
    }
    
    
    public static func publishDeviceLogs(logMessage : String) {
        
        do {
            let url: NSURL = NSURL(string:CommonConstants.ICAO_RECORD_DEVICE_LOGS_URL)!
            let request = NSMutableURLRequest(url: url as URL)
            let loginString = String(format: "%@:%@", CommonConstants.SERVICE_USERNAME, CommonConstants.SERVICE_PASSWORD).data(using: String.Encoding.utf8)!.base64EncodedString()
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Basic \(loginString)", forHTTPHeaderField: "Authorization")
            
            let logMessageWithDatetimeInfo = CommonUtils.getPrintableCurrentDateTime() + "\n" + logMessage
            
            let base64EncodedLogMessage = Data(logMessageWithDatetimeInfo.utf8).base64EncodedString()
            let deviceLog = DeviceLog(logStr: base64EncodedLogMessage)

            request.httpBody = try JSONEncoder().encode(deviceLog)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) { (data, response, error) in
                
                guard let data = data, error == nil else {
                    print("[ICAOClient - publishDeviceLogs] Error: \(String(describing: error))")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 204 {
                    var errorMessage = "Error occured in sending log to server"
                    print("[ICAOClient - publishDeviceLogs] http status code: \(httpStatus.statusCode)")
                    do {
                        let detailedErrorInfo = try JSONSerialization.jsonObject(with: data, options: []) as! NSDictionary
                        if let detailedErrorMessage = detailedErrorInfo["message"] as? String {
                            errorMessage = detailedErrorMessage
                        }
                        print(errorMessage)
                    } catch let err {
                        print(err)
                    }
                    return
                }
                print("[ICAOClient - publishDeviceLogs] log sent to server")
            }
            task.resume()
        }catch {
            print("[ICAOClient - publishDeviceLogs] Unexpected error occurs in sending log to server")
        }
        
    }
}
