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

class BiospMessage : Codable, NSCopying {
    
    var name : String?
    var message : String?
    var level : String?
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = BiospMessage()
        copy.name = self.name
        copy.message = self.message
        copy.level = self.level
        return copy
    } 
}
