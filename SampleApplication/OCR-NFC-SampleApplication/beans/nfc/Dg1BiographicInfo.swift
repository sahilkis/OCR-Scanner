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

class Dg1BiographicInfo : Codable, NSCopying {
    
    var primaryIdentifier: String?
    var secondaryIdentifier: String?
    var personalNumber : String?
    var documentType: String?
    var documentCode : String?
    var documentNumber: String?
    var gender : String?
    var nationality : String?
    var dateOfBirth : String?
    var dateOfExpiry : String?
    var issuingState : String?
    var optionalData1 : String?
    var optionalData2 : String?
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Dg1BiographicInfo()
        copy.primaryIdentifier = self.primaryIdentifier
        copy.secondaryIdentifier = self.secondaryIdentifier
        copy.personalNumber = self.personalNumber
        copy.documentType = self.documentType
        copy.documentCode = self.documentCode
        copy.documentNumber = self.documentNumber
        copy.gender = self.gender
        copy.nationality = self.nationality
        copy.dateOfBirth = self.dateOfBirth
        copy.dateOfExpiry = self.dateOfExpiry
        copy.issuingState = self.issuingState
        copy.optionalData1 = self.optionalData1
        copy.optionalData2 = self.optionalData2
        return copy
    }
    
    
}
