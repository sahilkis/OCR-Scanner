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

class CommonConstants {

    /********SERVER INFO********/
    static let BIOSP_SERVER_BASE = "https://knomi.aware.com:8443/BioSP/rest"
    public static let SERVICE_USERNAME = "integuser100"
    public static let SERVICE_PASSWORD = "XCV673!"
    
    /********SERVICE URL********/
    static let ICAO_VALIDATION_SERVICE = BIOSP_SERVER_BASE + "/icaoValidationService/v1"
    static let ICAO_REQUEST_FOR_VALIDATE_SESSION_URL = ICAO_VALIDATION_SERVICE + "/requestForValidateSession"
    static let ICAO_RECORD_DEVICE_LOGS_URL = ICAO_VALIDATION_SERVICE + "/recordDeviceLogs"
    static let DOC_AUTH_SERVICE_BASE = BIOSP_SERVER_BASE + "/documentAuthenticationService"
    static let VERIFY_DOCUMENTS_AND_BIOMETRICS_URL = DOC_AUTH_SERVICE_BASE + "/verifyDocumentsAndBiometrics"
    static let VALIDATE_DOCUMENTS_TYPE_URL = DOC_AUTH_SERVICE_BASE + "/validateDocumentType"

    static let ICAO_VERIFY_DATA_GROUPS_URL = ICAO_VALIDATION_SERVICE + "/verifyDataGroups"
    static let FACE_LIVENESS_CHECK_WITH_SESSION_URL = ICAO_VALIDATION_SERVICE + "/doFaceLivenessCheck"
    
    /********WORK FLOW SETTINGS********/
    static let defaultDisplayMode: String = "standard"
    static let defaultWorkflow: String = "Charlie2"
    static let defaultVideoLivenessThreshold: Double = 50.0
    static let matcherName = "aware-nexa-face"

}
