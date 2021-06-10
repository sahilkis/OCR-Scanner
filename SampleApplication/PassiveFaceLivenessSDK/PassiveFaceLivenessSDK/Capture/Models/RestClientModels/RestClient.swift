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


public enum ClientRestCommand: String {
    
    case analyze = "CAPTURE"

}

// Protocols
protocol RestDelegate: class {
    func responseReceived(
        restCommand: ClientRestCommand,
        status: Bool,
        response: [String: Any]?,
        message: String)
}


// API Client
typealias DataResponseErrorCompletionHandler = (Data?, URLResponse?, Error?) -> Void
typealias StatusResponseCompletionHandler = (Bool, AnyObject?) -> () -> [String: Any]?

typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void


enum RestClientError: Error {
    case noError
    case noResponse
    case cannotCreateURL
    case jsonDeserializeError
    case missing(String)
    case invalid(String, Any)
}



class RestClient {
    
    //
    // MARK: Delegates
    //
    
    weak var delegate: RestDelegate?
    
    func onResponseReceived(
        restCommand: ClientRestCommand,
        status: Bool,
        response: [String: Any]?,
        message: String) {
        
        if response != nil {
            print("[RestClient | onResponseReceived] response: valid response")
        } else {
            print("[RestClient | onResponseReceived] response: nil")
        }

        delegate?.responseReceived(restCommand: restCommand, status: status, response: response, message: message)
    }

    //
    // MARK: Initializers / Deinitializers
    //

    init() {
    
    }

    //
    // MARK: Methods
    //
    
    public func post(restCommand: ClientRestCommand, request: URLRequest, timeoutInterval: Double, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> () -> [String: Any]?) {
        dataTask(restCommand: restCommand, request: request, timeoutInterval: timeoutInterval, method: "POST", completion: completion)
    }
    
    public func put(request: URLRequest, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        dataTask(request: request, method: "PUT", completion: completion)
    }
    
    public func get(request: URLRequest, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        dataTask(request: request, method: "GET", completion: completion)
    }
    
    public func getSynch(request: URLRequest) -> (data: Data, status: Int) { // String {
        
        let result = dataTaskSync(request: request, method: "GET") // , completion: completion)
        
        return result
    }
    
    /// Function to use to make an async URL request. It takes a request which contains
    /// the URL, sends it, and once it gets a response or error, the completion handler
    /// gets called.
    ///
    /// - parameters:
    ///   - request: HTTP Request
    ///   - method: "GET", "POST", etc
    ///   - completion: Callback handler to execute once response is received.
    /// - returns: Return contents as String
    private func dataTask(request: URLRequest, method: String, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> ()) {
        
        print("dataTask: request.httpBody string output: " + String(data: request.httpBody!, encoding: .utf8)!)  // Actual string representation

        var requestMutable = request
        
        requestMutable.httpMethod = method
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        // NOTE: Look here to support Jamie's auth stuff
        // TODO: requestMutable.allHTTPHeaderFields
        
        session.dataTask(with: requestMutable as URLRequest) { (data, response, error) -> Void in
            if let data = data {
                
                let json = try? JSONSerialization.jsonObject(with: data, options: []) // as! [String: Any]
                
                let jsonResult = json as? [String: Any]
                print("jsonResult: \(String(describing: jsonResult))")

                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    // HTTP Status code range - SUCCESS
                    completion(true, json as AnyObject)
                } else {
                    print("response.statusCode: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                    completion(false, json as AnyObject)
                }
            }
            }.resume()
    }
    
    private func dataTask(restCommand: ClientRestCommand, request: URLRequest, timeoutInterval: Double, method: String, completion: @escaping (_ success: Bool, _ object: AnyObject?) -> () -> [String: Any]?) {
   
        // DEBUG: Actual string representation of request
//        print("dataTask: request.httpBody string output: " + String(data: request.httpBody!, encoding: .utf8)!)
        
        var status = false
        
        var requestMutable = request
        
        requestMutable.httpMethod = method
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.configuration.timeoutIntervalForRequest = timeoutInterval // 30.0
        
        // NOTE: Look here to support Jamie's auth stuff
        // TODO: requestMutable.allHTTPHeaderFields
        
        var res: [String: Any]?

        // NOTE: error codes: https://developer.apple.com/documentation/foundation/1508628-url_loading_system_error_codes
        
        session.dataTask(with: requestMutable as URLRequest) { (data, response, error) -> Void in
            
            if error != nil {
                print("[dataTask overloaded with RestCommand] error: \(String(describing: error))")
                status = false
                res = nil
            } else if let data = data {
                
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                
                let jsonResult = json as? [String: Any]
                print("jsonResult: \(String(describing: jsonResult))")
                
                //---------
                // DEBUG:
                // print("data as string: " + String(data: data, encoding: .utf8)! + "\n")
                // print("data as any object: \(data as AnyObject)" + "\n")
                // print("data.description" + data.description + "\n")
                // print("response.description" + (response?.description)! + "\n")
                //---------

                
                if let response = response as? HTTPURLResponse, 200...299 ~= response.statusCode {
                    
                    // HTTP Status code range - SUCCESS
                    status = true
                    // completion callback here is to analyze response and assign to res, not directly callback to upper level
                    res = completion(status, json as AnyObject)()
                } else if (response as! HTTPURLResponse).statusCode == 500 { // internalServerError
                    status = false
                    
                    // TODO: Have completion deal with deserializing errorResponse...
                    // change status to an int? Where 0:succes, -1:fail, n:HttpStatusCode?
                    res = completion(status, json as AnyObject)()
                } else {
                    print("response.statusCode: \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                    
                    status = false
                    res = completion(status, json as AnyObject)()
                }
            }
            
            // real callback that send message back to topper level
            self.onResponseReceived(restCommand: restCommand, status: status, response: res, message: "")

            }.resume()
    }
    
    /// Perform a synchronous HTTP call
    ///
    /// - parameters:
    ///   - request: HTTP Request
    ///   - method: "GET", "POST", etc
    ///   - completion: Callback handler to execute once response is received.
    /// - returns: Return contents as String
    private func dataTaskSync(request: URLRequest, method: String)
        -> (data: Data, status: Int)  {
            
        var responseData: Data = Data()
        var status = 0
        var requestMutable = request
        
        requestMutable.httpMethod = method
        let session = URLSession.shared
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = session.dataTask(with: requestMutable as URLRequest) {
            (data, response, error) -> Void in
            
            if let error = error {
                print("Error: \(error)")
            } else if let response = response as? HTTPURLResponse, 300..<600 ~= response.statusCode {
                status = response.statusCode
                print("Error, statusCode: \(response.statusCode)")
            } else if let data = data {
                // Success
                responseData = data
                
//                // DEBUG:
//                // Print out response string
//                let responseString = String(data: data, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))!
//                print("responseString = " + responseString)
            }
            
            semaphore.signal()
        }
        
        task.resume()
            // TODO:
            // _ = semaphore.wait(timeout: DispatchTime.distantFuture)
            let dt = DispatchTime(uptimeNanoseconds: 6000000 * NSEC_PER_SEC)
            _ = semaphore.wait(timeout: dt)

        return (responseData, status)
    }
    
}
