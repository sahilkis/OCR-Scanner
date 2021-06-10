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

class BiometricMatchResult : Codable, NSCopying {

    var verifyResult: Bool?
    var modality: String?
    var fmr_score: Double?
    var biometricMatchedCount: Int?
    var biometricOnServer: String?
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = BiometricMatchResult()
        copy.verifyResult = self.verifyResult
        copy.modality = self.modality
        copy.fmr_score = self.fmr_score
        copy.biometricMatchedCount = self.biometricMatchedCount
        copy.biometricOnServer = self.biometricOnServer
        return copy
    }
}
