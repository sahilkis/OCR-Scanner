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
import UIKit

class NFCResultDisplayDTO : NSCopying {

    var rfidValidationResult: RfidValidationResult?
    var verifyBiometricsResponse : VerifyBiometricsResponse?
    var photoImage: UIImage?
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = NFCResultDisplayDTO()
        copy.rfidValidationResult = self.rfidValidationResult?.copy() as? RfidValidationResult
        copy.verifyBiometricsResponse = self.verifyBiometricsResponse?.copy() as? VerifyBiometricsResponse
        if let cgImage = self.photoImage?.cgImage?.copy() {
            copy.photoImage = UIImage(cgImage: cgImage)
        }
        return copy
    }
    
    func clearValue() {
        self.rfidValidationResult = nil
        self.verifyBiometricsResponse = nil
        self.photoImage = nil
    }
    
}

class NFCFieldType {
    var key : String?
    var value: String?
    
    init() {
        
    }
    
    init(key: String?, value: String?) {
        self.key = key
        self.value = value
    }
}
