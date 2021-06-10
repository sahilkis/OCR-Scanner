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
import AwNFCPassportReaderSDK

@available(iOS 13, *)
class AwNFCPassportScanner {
    
    private static let instance = AwNFCPassportScanner()
    private let passportReader = PassportReader()
    
    private init() { }
    
    static func getInstance() -> AwNFCPassportScanner { return instance }

    // This function handles only scanning, and callback to caller about the scanning result
    func scan(passportNumber: String,
              dateOfBirth: String,
              expiryDate: String,
              challenge: String,
              onScanComplete: @escaping (_ error: Bool, _ icaoDataGroups: ICAODataGroups?, _ errorMsg: String?)-> Void) {
        let ERROR_TAG = "[AwNFCPassportScanner scan] - "

        passportReader.readPassport(passportNumber: passportNumber, expirationDate: expiryDate, birthDate: dateOfBirth, challenge: challenge) { (statusCode : Int, icaoDataGroups : ICAODataGroups?, error: String?) in
        
            let status = NFCStatusCode.byValue(code: statusCode)
            
            if status == .SUCCESS, let dataGroups = icaoDataGroups {
                onScanComplete(false, dataGroups, nil)
            }
            else {
               var errorMsg = "\(error ?? "Passport reader received unexpected error"), Error Code: \(statusCode)"
               
               var errorLog = ERROR_TAG + errorMsg
                if status == NFCStatusCode.INVALID_INPUT || status == NFCStatusCode.BAC_KEYINPUTS_INCORRECT {
                   errorMsg = "Please check if the input is correct"
                   errorLog += " \(errorMsg)"
               }
               ICAOClient.publishDeviceLogs(logMessage: errorLog)
               onScanComplete(true, nil, errorMsg)
            }
        }
    }
}
