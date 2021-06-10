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

class MainViewController: UIViewController {

    // central waiting spinner
    var alertController: UIAlertController?
    var spinnerIndicator: UIActivityIndicatorView?
    
    // dispatchers
    var nfcWorkflowDispatcher: INFCWorkflowDispatcher?
    var ocrWorkflowDispatcher: OCRWorkflowDispatcher?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        if #available(iOS 13, *) {
            initNFCWorkflowDispatcher()
        }
        initOCRWorkflowDispatcher()
    }
    
    @available(iOS 13, *)
    private func initNFCWorkflowDispatcher() {
        self.nfcWorkflowDispatcher = SequentialNFCWorkflowDispatcher(parentViewController: self)
    }
    
    private func initOCRWorkflowDispatcher() {
        self.ocrWorkflowDispatcher = self.storyboard?.instantiateViewController(withIdentifier: "OCRWorkflowDispatcher") as? OCRWorkflowDispatcher
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
    }

    // MARK: Button actions
    @IBAction func ocrVerificationBtnPressed(_ sender: UIButton) {
        doStartOCRWorkflow()
    }

    @IBAction func nfcVerificationBtnPressed(_ sender: UIButton) {
        if #available(iOS 13.0, *) {
            doStartNFCWorkflow()
        } else {
            self.showAlert(status: "iOS 13 or above version is required for NFC feature", error: true)
        }
    }
    
    // MARK: Adidtional UI display
    func initWaitingAlert(message: String){
        alertController = UIAlertController(title: nil, message: message + "...\n\n", preferredStyle: .alert)
        spinnerIndicator = UIActivityIndicatorView(style: .white)
        spinnerIndicator!.center = CGPoint(x:135.0, y: 65.5)
        spinnerIndicator!.color = UIColor.black
        spinnerIndicator!.startAnimating()
        alertController!.view.addSubview(spinnerIndicator!)
    }
    
    func showAlert(status: String, error: Bool) {
        var title: String = "Status"
        if error {
            title = "Error"
        }
        let detailMessage = "\(status)\n\(CommonUtils.getPrintableCurrentDateTime())"
        let alert = UIAlertController(title: title,
                                      message: detailMessage,
                                      preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        if let waitingAlert = self.alertController {
            self.spinnerIndicator?.stopAnimating()
            waitingAlert.dismiss(animated: true, completion: {
                self.alertController = nil
                self.present(alert, animated:true, completion: nil)
            })
        }else{
            self.present(alert, animated:true, completion: nil)
        }
    }
}

// MARK: NFC Feature
extension MainViewController : NFCInputDelegate {
    
    @available(iOS 13.0, *)
    func doStartNFCWorkflow() {
        let passportInputViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController (withIdentifier: "NFCInputViewController") as! NFCInputViewController
        passportInputViewController.delegate = self
        passportInputViewController.modalPresentationStyle = .fullScreen
        self.present(passportInputViewController, animated: true, completion: nil)
    }
    
    @available(iOS 13, *)
    func onInputComplete(passportNumber: String, dateOfBirth: String, dateOfExpiry: String) {
        if self.nfcWorkflowDispatcher == nil {
            initNFCWorkflowDispatcher()
        }
        self.nfcWorkflowDispatcher?.start(passportNumber: passportNumber, dateOfBirth: dateOfBirth, dateOfExpiry: dateOfExpiry)
    }
    
    func showNFCResult(resultDisplayDTO: NFCResultDisplayDTO) {
        guard let _ = resultDisplayDTO.photoImage,
            let _ = resultDisplayDTO.rfidValidationResult,
            let _ = resultDisplayDTO.verifyBiometricsResponse else {
                print("Result not complete to display")
                self.showAlert(status: "Result not complete to display", error: true)
                return
        }
        
        let resultDisplayVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController (withIdentifier: "NFCResultContainerViewController") as! NFCResultContainerViewController
        
        resultDisplayVC.resultDisplayDTO = resultDisplayDTO.copy() as? NFCResultDisplayDTO
        resultDisplayDTO.clearValue()
        self.navigationController?.pushViewController(resultDisplayVC, animated: true)
    }
}


// MARK: OCR Feature
extension MainViewController {
    
    func doStartOCRWorkflow() {
        if self.ocrWorkflowDispatcher == nil {
            self.ocrWorkflowDispatcher = self.storyboard?.instantiateViewController(withIdentifier: "OCRWorkflowDispatcher") as? OCRWorkflowDispatcher
        }
        
        ocrWorkflowDispatcher?.setDocumentProofCaptureCallback { (success, message, docProofCapturedMessage) in
            if success {
                if let docProofCapturedMessage = docProofCapturedMessage {
                    
                    if let docAuthenticationRequest = CommonUtils.convertDocProofCapturedMsgToDocAuthRequest(docAndBiometricsCapturedMessage: docProofCapturedMessage) {
                        self.initWaitingAlert(message: "Waiting for result")
                        DispatchQueue.main.async {
                            self.present(self.alertController!, animated: true, completion: {
                                // send the captured information (doc image + face image) to server for verification
                                DocAuthClient.sendAuthenticationRequest(docAuthenticationRequest: docAuthenticationRequest) {
                                    (success: Bool, response: DocumentAuthenticationResponse?, errorMessage: String?) in
                                    DispatchQueue.main.async {
                                        // response from server is obtained
                                        self.alertController?.dismiss(animated: true, completion: {
                                            if success, let documentAuthenticationResponse = response {
                                                DispatchQueue.main.async {
                                                    self.showOCRResult(documentAuthenticationResponse: documentAuthenticationResponse)
                                                }
                                            }
                                            else {
                                                self.showAlert(status: errorMessage!, error: true)
                                            }
                                        })
                                    }
                                }
                            })
                        }
                    }
                }
            }
            else {
                if let errorMessage = message {
                    // user canceled, do nothing
                    if errorMessage == "Cancel" {
                        print("Capture canceled by user")
                    }
                    self.showAlert(status: errorMessage, error: true)
                }
                else {
                    self.showAlert(status: "Document Capture Failed", error: true)
                }
            }
        }
        ocrWorkflowDispatcher!.modalPresentationStyle = .fullScreen
        self.present(ocrWorkflowDispatcher!, animated: true, completion: nil)
    }
 
    
    func showOCRResult(documentAuthenticationResponse: DocumentAuthenticationResponse) {
        let resultContainerViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OCRResultContainerViewController") as! OCRResultContainerViewController
        resultContainerViewController.documentAuthenticationResponse = documentAuthenticationResponse
        resultContainerViewController.navigationItem.rightBarButtonItem = nil
        self.navigationController?.pushViewController(resultContainerViewController, animated: true)
    }
}
