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

class BiometricUtils {
    
    static func createBiometrics(biometricsCapturedMessage message : BiometricsCapturedMessage) -> Biometrics {
        let biometrics = Biometrics()
        biometrics.facialImages = FacialImages()
        biometrics.facialImages?.facialImage = [FacialImage]()
        
        let facialImage = FacialImage()
        let base64Data = CommonUtils.convertBytesArrayToBase64Data(bytesArray: message.faceBuffer!)
        facialImage.image = String(data: base64Data, encoding: String.Encoding.utf8)
        
        let facialMetadata = FacialImageMetadata()
        facialMetadata.pose = "FRONT"
        facialMetadata.imageStorage = ImageStorage()
        facialMetadata.imageStorage?.compressionAlgorithm = "JPG"
        facialImage.facialImageMetadata = facialMetadata
        
        biometrics.facialImages?.facialImage?.append(facialImage)
        
        return biometrics
    }
    
    static func verifyBiometricsRequest(matcherName : String, probeBiometrics : Biometrics, knownBiometrics : Biometrics) -> VerifyBiometricsRequest {
        let biometricsRequest = VerifyBiometricsRequest()
        biometricsRequest.matcherName = matcherName
        biometricsRequest.probeBiometrics = probeBiometrics
        biometricsRequest.knownBiometrics = knownBiometrics
        return biometricsRequest
    }
    
}
