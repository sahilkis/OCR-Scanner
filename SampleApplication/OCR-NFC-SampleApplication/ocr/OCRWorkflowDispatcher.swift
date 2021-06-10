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

import UIKit
import AVFoundation
import PassiveFaceLivenessSDK
import AwDocumentCapture

class OCRWorkflowDispatcher: UIViewController {
    var alertController: UIAlertController?
    var spinnerIndicator: UIActivityIndicatorView?
    
    
    var docAndBiometricsCapturedMessage = DocAndBiometricsCapturedMessage()
    var isCaptureJustStarted = true
    public typealias DocProofCaptureCallback = (_ success: Bool, _ message: String?, _ docAndBiometricsCapturedMessage: DocAndBiometricsCapturedMessage?) -> Void
    var docProofCaptureCallback: DocProofCaptureCallback? = {_,_,_ in }
    public func setDocumentProofCaptureCallback(callback: @escaping DocProofCaptureCallback) {
        self.docProofCaptureCallback = callback
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isCaptureJustStarted {
            self.isCaptureJustStarted = false
            startAwDocumentCapture()
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func startAwDocumentCapture() {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight, andRotateTo: UIInterfaceOrientation.landscapeRight)
        let scannerViewController = UIStoryboard(name: "AwDocumentCapture", bundle: Bundle.init(identifier: "com.aware.auth.AwDocumentCapture")).instantiateViewController(withIdentifier: "ImageScannerViewController") as! ImageScannerViewController
        scannerViewController.modalPresentationStyle = .fullScreen
        
        scannerViewController.setSurroundingColor(color: UIColor.darkGray, alpha: CGFloat(0.7))
        
        /* Please refer to documentation for setting details*/
        /* OPTIONAL SETTINGS */
        /*
        scannerViewController.setSurroundingColor(color: UIColor.darkGray, alpha: CGFloat(0.7))
         
        scannerViewController.setCaptureImageOption(captureOption: .DOC_TYPE_SERVER, serverValidateCallback: self)
        scannerViewController.setCaptureImageOption(captureOption: .DOC_TYPE_AUTO)
         
        scannerViewController.setBoundaryFrameOnDetection(image: <#T##UIImage#>)
        scannerViewController.setBoundaryFrameWhileDetecting(image: <#T##UIImage#>)
        scannerViewController.setFlipImage(image: <#T##UIImage#>)
        scannerViewController.setFlipImageScale(scale: <#T##Double#>)
        scannerViewController.enablePlaceDocumentPrompt(enabled: <#T##Bool#>)
        scannerViewController.setPlaceDocumentText(content: <#T##String#>)
        
         let option = TextUIFeatureBuilder().textColor(UIColor.purple).textSize(25).backgroundColor(UIColor.blue.withAlphaComponent(CGFloat(0.7))).build()
        scannerViewController.setPlaceDocumentText(content: "Place document here", UIOption: option)
         
        scannerViewController.setPlaceDocumentFrontImage(image: <#T##UIImage#>)
        scannerViewController.setPlaceDocumentBackImage(image: <#T##UIImage#>)
         
        scannerViewController.enableCaptureCompletionDisplay(enabled: <#T##Bool#>)
        scannerViewController.setCaptureCompletionImage(completionImage: <#T##UIImage#>)
        scannerViewController.setCaptureCompletionContent(content: <#T##String#>)
        scannerViewController.setCaptureCompletionContent(content: "CAPTURE COMPLETE", feature: TextUIFeatureBuilder()
                                                                                                  .textColor(UIColor.purple)
                                                                                                  .textSize(25)
                                                                                                  .build())
        
         
        scannerViewController.setFeedbackString(feedback: <#T##FeedbackStatus#>, message: <#T##String#>)
        scannerViewController.setFeedbackString(feedback: <#T##FeedbackStatus#>, message: <#T##String#>, feature: <#T##TextUIFeature?#>)
         
        scannerViewController.setCancelButton(feature: <#T##TextUIFeature?#>)
        */
        
        /* REQUIRED */
        scannerViewController.setCompleteCallback { (success: Bool, captureResult: AwDocumentCaptureResult?, errorMessage: String?) in
            if success, let result = captureResult {
                
                
                // display result
                let resultDisplayVC = self.getDocCaptureResultViewController(images: result.images, isForFinalResult: true)
                resultDisplayVC.modalPresentationStyle = .fullScreen
                resultDisplayVC.setCallback { (nextStep) in
                    switch nextStep {
                    case .CANCEL:
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: {
                                self.docProofCaptureCallback!(false, "User canceled", nil)
                            })
                        }
                    case .RESCAN :
                        DispatchQueue.main.async {
                            self.startAwDocumentCapture()
                        }
                    case .OK:
                        DispatchQueue.main.async {
                            self.docAndBiometricsCapturedMessage.documentBuffer = result.images
                            self.startFaceLivenessCapture()
                        }
                    case .ERROR:
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: {
                                self.docProofCaptureCallback!(false, "Unexpected error occured", nil)
                            })
                        }
                    }
                    
                }
                DispatchQueue.main.async {
                    self.present(resultDisplayVC, animated: true, completion: nil)
                }
            }
            else {
                
                if let result = captureResult {
                    // captured, but validation error

                    let resultDisplayVC = self.getDocCaptureResultViewController(images: result.images, isForFinalResult: false)
                    resultDisplayVC.modalPresentationStyle = .fullScreen
                    resultDisplayVC.setCallback { (nextStep) in
                        switch nextStep {
                        case .CANCEL:
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: {
                                    self.docProofCaptureCallback!(false, "User canceled", nil)
                                })
                            }
                        case .RESCAN :
                            DispatchQueue.main.async {
                                self.startAwDocumentCapture()
                            }
                        case .OK:
                            DispatchQueue.main.async {
                                self.startAwDocumentCapture()
                            }
                        case .ERROR:
                            DispatchQueue.main.async {
                                self.dismiss(animated: true, completion: {
                                    self.docProofCaptureCallback!(false, "Unexpected error occured", nil)
                                })
                            }
                        }
                        
                    }
                    DispatchQueue.main.async {
                        self.present(resultDisplayVC, animated: true, completion: nil)
                    }
                }
                else {
                    var message: String?
                    if let errorMsg = errorMessage {
                        message = errorMsg
                    }
                    self.dismiss(animated: true, completion: {
                        self.docProofCaptureCallback!(false, message, nil)
                    })
                }
            }
        }
        self.present(scannerViewController, animated: true)
    }
    
    private func getDocCaptureResultViewController(images: [[UInt8]], isForFinalResult: Bool) -> DocCaptureResultViewController {

        let resultDisplayVC = UIStoryboard(name: "DocCaptureResult", bundle: Bundle(for: type(of: self))).instantiateViewController(withIdentifier: "DocCaptureResultViewController") as! DocCaptureResultViewController

        resultDisplayVC.isForFinalResult = isForFinalResult
        for imageByteArray in images {
            let imageData = Data(bytes: imageByteArray, count: imageByteArray.count)
            resultDisplayVC.imagesToDisplay.append(UIImage(data: imageData)!)
        }
        

        return resultDisplayVC
    }
    
    private func startFaceLivenessCapture() {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        initWaitingAlert(message: "Initializing Face Capture")
        self.present(alertController!, animated: true) {
            let faceLivenessCaptureViewController = self.storyboard?.instantiateViewController(withIdentifier: "PassiveFaceLivenessManagerViewController") as! PassiveFaceLivenessManagerViewController
            faceLivenessCaptureViewController.modalPresentationStyle = .fullScreen
            faceLivenessCaptureViewController.shouldSkipDisplayIfLivenessSucceed = true
            faceLivenessCaptureViewController.sessionId = nil
            self.isCaptureJustStarted = false
            faceLivenessCaptureViewController.setCallback(callback: { [unowned self] (error, faceBuffer) in
                if !error, let capturedImage = faceBuffer {
                    let dataBeforeCompress = NSData(bytes: capturedImage, length: capturedImage.count)
                    let uiimageBeforeCompress = UIImage(data: dataBeforeCompress as Data)!
                    let jpgDataAfterCompress = uiimageBeforeCompress.jpegData(compressionQuality: CGFloat(0.7))
                    self.docAndBiometricsCapturedMessage.faceBuffer = [UInt8](jpgDataAfterCompress!)
                    self.dismiss(animated: true, completion: {
                        self.docProofCaptureCallback!(true, nil, self.docAndBiometricsCapturedMessage)
                    })
                }
                else {
                    self.dismiss(animated: true, completion: {
                        self.docProofCaptureCallback!(false, nil, nil)
                    })
                }
            })
            DispatchQueue.main.async {
                self.alertController!.dismiss(animated: true, completion: {
                    self.present(faceLivenessCaptureViewController, animated: true, completion: nil)
                })
            }
        }
    }
    
    private func initWaitingAlert(message: String){
        alertController = UIAlertController(title: nil, message: message + "..\n\n", preferredStyle: .alert)
        spinnerIndicator = UIActivityIndicatorView(style: .white)
        spinnerIndicator!.center = CGPoint(x:135.0, y: 65.5)
        spinnerIndicator!.color = UIColor.black
        spinnerIndicator!.startAnimating()
        alertController!.view.addSubview(spinnerIndicator!)
    } 
    
}

extension OCRWorkflowDispatcher: IServerValidateCallback {
    
    public func validateOnServer(validateServerReqJson: String, validateCompletion: @escaping (Bool, String?) -> Void) {
        // no need to handle error here, the logc is implemented in side SDK
        ServerDocVidationClient.send(requestJson: validateServerReqJson) { (error: Bool, response: String?, errorMessage: String?) in
            validateCompletion(error, response)
        }
    }
 
}
