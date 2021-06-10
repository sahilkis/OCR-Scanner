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

class VerifyBiometricsResponse : Codable, NSCopying {

    var verifyResult : Bool?
    var matchScore : Double?
    var biometricMatchedCount : Int?
    var biometricsOnServer : String?
    var biometricMatchResultList : [BiometricMatchResult]?
    var matchingminutia : String?
    var statusMessages : [BiospMessage]?
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = VerifyBiometricsResponse()
        copy.verifyResult = self.verifyResult
        copy.matchScore = self.matchScore
        copy.biometricMatchedCount = self.biometricMatchedCount
        copy.biometricsOnServer = self.biometricsOnServer
        copy.biometricMatchResultList = self.biometricMatchResultList?.map { $0.copy() as! BiometricMatchResult }
        copy.matchingminutia = self.matchingminutia
        copy.statusMessages = self.statusMessages?.map { $0.copy() as! BiospMessage }
        return copy
    }
    
}
