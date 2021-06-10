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
import UIKit
import AwNFCPassportReaderSDK

@available(iOS 13, *)
class SequentialNFCWorkflowDispatcher: NSObject, INFCWorkflowDispatcher {
    
    var parentViewController: MainViewController?
    var scanner: AwNFCPassportScanner?
    
    public init(parentViewController : MainViewController) {
        self.parentViewController = parentViewController
        scanner = AwNFCPassportScanner.getInstance()
    }

    
    // passport scan -> facical capture -> passive authentication on server -> show result
    func start(passportNumber: String, dateOfBirth: String, dateOfExpiry: String) {
        
        ICAOClient.requestForValidateSession { (error: Bool, icaoSessionResponse: ICAOSessionResponse?, errorMessage: String?) in
           
            guard !error, let sessionResponse = icaoSessionResponse, let sessionId = sessionResponse.sessionId, let challenge = sessionResponse.challenge else {

                DispatchQueue.main.async {
                    let err = "Error occured in request validation session information from server"
                    self.parentViewController?.showAlert(status: "\(err)", error: true)
                }
                return
                
            }
            
            let icaoValidationRequest = ICAOValidationRequest()
            icaoValidationRequest.sessionId = sessionId
            
            // 1. passport scan
            self.scanner?.scan(passportNumber: passportNumber, dateOfBirth: dateOfBirth, expiryDate: dateOfExpiry, challenge: challenge, onScanComplete: { (error: Bool, dataGroups: ICAODataGroups?, errorMessageInNFCScan: String?) in
                
                guard !error, let icaoDataGroups = dataGroups else {
                    print("ErrorMessageInNFCScan: \(errorMessageInNFCScan!)")
                    DispatchQueue.main.async {
                        self.parentViewController?.showAlert(status: "\(errorMessageInNFCScan!)", error: true)
                    }
                    return
                }
                
                // filled as a parameter in request
                icaoValidationRequest.icaoDataGroups = icaoDataGroups
                
                DispatchQueue.main.async {
                    // 2. facial capture
                    self.startFaceLivenessCapture(sessionId: sessionId) { (error: Bool, faceBufferCaptured: [UInt8]?, errorMessageInLivenessCapture: String?) in
                        
                        guard !error, let faceBufferCaptured = faceBufferCaptured else {
                            print("ErrorMessageInLivenessCapture: \(errorMessageInLivenessCapture!)")
                            DispatchQueue.main.async {
                                self.parentViewController?.showAlert(status: "\(errorMessageInLivenessCapture!)", error: true)
                            }
                            return
                        }
                        
                        guard self.isRequestValid(icaoValidationRequest: icaoValidationRequest) else {
                            let errorMsg = "icaoValidationRequest validation error"
                            print(errorMsg)
                            DispatchQueue.main.async {
                                self.parentViewController?.showAlert(status: errorMsg, error: true)
                            }
                            return
                        }
                        
                        // 3. send icao validation request to server
                        DispatchQueue.main.async {
                            
                            self.parentViewController?.initWaitingAlert(message: "Please wait")
                            self.parentViewController?.present(self.parentViewController!.alertController!, animated: true) {
                            
                                ICAOClient.doICAOValidation(icaoValidationRequest: icaoValidationRequest) { (error: Bool, response: ICAOValidationResponse?, errorMsg: String?) in
                                    
                                    DispatchQueue.main.async {
                                        self.parentViewController?.spinnerIndicator?.stopAnimating()
                                        self.parentViewController?.alertController?.dismiss(animated: true, completion: {

                                            guard !error, let icaoValidationResponse = response else {
                                                print("ErrorMessageInServerPassiveAuthentication: \(errorMsg!)")
                                                DispatchQueue.main.async {
                                                    self.parentViewController?.showAlert(status: "\(errorMsg!)", error: true)
                                                }
                                                return
                                            }
                                            
                                            // postprocess icaoValidationResponse do display
                                            guard let nfcResultDisplayDTO = self.convertToResultDisplayDTO(from: icaoValidationResponse) else {
                                                DispatchQueue.main.async {
                                                    self.parentViewController?.showAlert(status: "Error in converting passive authentication response to result display information", error: true)
                                                }
                                                return
                                            }
                                            
                                            DispatchQueue.main.async {
                                                self.parentViewController?.showNFCResult(resultDisplayDTO: nfcResultDisplayDTO)
                                            }
                                            
                                        })
                                    }
                                    
                                }
                                
                            }
                        }
                        
                    }
                }
            })
        }
    }
    
    private func convertToResultDisplayDTO(from icaoValidationResponse: ICAOValidationResponse) -> NFCResultDisplayDTO? {
        
        let resultDisplayDTO = NFCResultDisplayDTO()
        
        resultDisplayDTO.rfidValidationResult = icaoValidationResponse.rfidValidationResult
        
        resultDisplayDTO.verifyBiometricsResponse = VerifyBiometricsResponse()
        resultDisplayDTO.verifyBiometricsResponse?.verifyResult = icaoValidationResponse.facialMatchResult?.matchResult
        resultDisplayDTO.verifyBiometricsResponse?.matchScore = icaoValidationResponse.facialMatchResult?.matchScore
        
        
        // extract facial image from dg2
        guard let passportImageBase64Str = resultDisplayDTO.rfidValidationResult?.dg2Info?.facialImage, let passportImage = CommonUtils.convertImageFromBase64StringToUIImage(base64Str: passportImageBase64Str) else {
            return nil
        }
        resultDisplayDTO.photoImage = passportImage
        
        return resultDisplayDTO
    }
    
    private func isRequestValid(icaoValidationRequest: ICAOValidationRequest) -> Bool {
        return icaoValidationRequest.icaoDataGroups != nil
    }
 
    private func startFaceLivenessCapture(sessionId: String, captureComplete: @escaping (_ error: Bool, _ faceBufferCaptured: [UInt8]?, _ errorMsg: String?)-> Void) {
        
        self.parentViewController?.initWaitingAlert(message: "Initializing Face Capture")
        self.parentViewController?.present(self.parentViewController!.alertController!, animated: true) {
            let faceLivenessCaptureViewController = self.parentViewController?.storyboard?.instantiateViewController(withIdentifier: "PassiveFaceLivenessManagerViewController") as! PassiveFaceLivenessManagerViewController
            faceLivenessCaptureViewController.shouldSkipDisplayIfLivenessSucceed = true
            faceLivenessCaptureViewController.sessionId = sessionId
            faceLivenessCaptureViewController.setCallback(callback: { [unowned self] (error, faceBuffer) in
                self.parentViewController?.spinnerIndicator?.stopAnimating()
                self.parentViewController?.alertController?.dismiss(animated: true, completion: {
                    if !error, let capturedImage = faceBuffer {
                        
                        let dataBeforeCompress = NSData(bytes: capturedImage, length: capturedImage.count)
                        let uiimageBeforeCompress = UIImage(data: dataBeforeCompress as Data)!
                        let jpgDataAfterCompress = uiimageBeforeCompress.jpegData(compressionQuality: CGFloat(0.7))
                        let faceBufferCaptured = [UInt8](jpgDataAfterCompress!)
                        
                        captureComplete(false, faceBufferCaptured, nil)
                    }
                    else {
                        captureComplete(true, nil, "error occured during face capture")
                    }
                })
            })
            sleep(3)    // It is better to wait until NFC modal dismissed
            self.parentViewController?.spinnerIndicator?.stopAnimating()
            self.parentViewController?.alertController!.dismiss(animated: true, completion: {
                faceLivenessCaptureViewController.modalPresentationStyle = .fullScreen
                self.parentViewController?.present(faceLivenessCaptureViewController, animated: true, completion: nil)
            })
        }
        
    }
}

