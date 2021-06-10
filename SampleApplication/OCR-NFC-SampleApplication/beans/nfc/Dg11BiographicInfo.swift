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

class Dg11BiographicInfo : Codable, NSCopying {

    var nameOfHolder: String?
    var fullDateOfBirth: String?
    var placeOfBirth: String?
    var permanentAddress: String?
    var otherNames: String?
    var personalSummary: String?
    var profession: String?
    var proofOfCitizenship: String?
    var otherTravelDocumentNumbers: String?
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Dg11BiographicInfo()
        copy.nameOfHolder = self.nameOfHolder
        copy.fullDateOfBirth = self.fullDateOfBirth
        copy.placeOfBirth = self.placeOfBirth
        copy.permanentAddress = self.permanentAddress
        copy.otherNames = self.otherNames
        copy.personalSummary = self.personalSummary
        copy.profession = self.profession
        copy.proofOfCitizenship = self.proofOfCitizenship
        copy.otherTravelDocumentNumbers = self.otherTravelDocumentNumbers
        return copy
    }
}
