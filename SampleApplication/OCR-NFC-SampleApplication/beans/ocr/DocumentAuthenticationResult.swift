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

class DocumentAuthenticationResult: Codable {
    
    var documentType: String?
    var documentTypeId: String?
    var fidType: String?
    var fidTypeId: String?
    var overallResult: String?
    var mrzPresence: Bool?
    var fieldType: [OCRFieldType]?
    var signatureImage: String?
    var authenticityResult: AuthenticityResult?
    
    func getFieldType(byName queryName: String) -> OCRFieldType? {
        if let allTypes = self.fieldType {
            for eachType in allTypes {
                if let name = eachType.name, name == queryName {
                    return eachType
                }
            }
        }
        return nil
    }
    
    func getFieldType(byTypeId queryTypeId: Int64) -> OCRFieldType? {
        if let allTypes = self.fieldType {
            for eachType in allTypes {
                if let typeId = eachType.typeId, typeId == queryTypeId {
                    return eachType
                }
            }
        }
        return nil
    }
}
