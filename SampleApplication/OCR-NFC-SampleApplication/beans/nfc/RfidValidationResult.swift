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

class RfidValidationResult : Codable, NSCopying {
    
    var dg1BiographicInfo : Dg1BiographicInfo?
    var dg11BiographicInfo : Dg11BiographicInfo?
    var dg2Info: Dg2Info?
    var signatureOnSODValid : Bool?
    var certificateChainValid : Bool?
    var dataGroupHashesValid : Bool?
    var activeAuthenticationResult: String?
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = RfidValidationResult()
        copy.dg1BiographicInfo = self.dg1BiographicInfo?.copy() as? Dg1BiographicInfo
        copy.dg11BiographicInfo = self.dg11BiographicInfo?.copy() as? Dg11BiographicInfo
        copy.dg2Info = self.dg2Info?.copy() as? Dg2Info
        copy.signatureOnSODValid = self.signatureOnSODValid
        copy.certificateChainValid = self.certificateChainValid
        copy.dataGroupHashesValid = self.dataGroupHashesValid
        copy.activeAuthenticationResult = self.activeAuthenticationResult
        
        return copy
    }
}
