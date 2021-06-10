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

class DocumentAuthenticationResponse: Codable {
    
    var overallAuthenticationResult: String?
    var statusMessages: [BiospMessage]?
    var documentAuthenticationResult: DocumentAuthenticationResult?
    var biometricsAuthenticationResult: BiometricsAuthenticationResult?
    
}
