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
import FaceLiveness
import PassiveFaceLivenessSDK

public class PassiveFaceLivenessManagerViewController: UIViewController, ServerResponseDelegate
{
    
    let responseLock = NSLock()
    static var livenessAppUIClientServerViewController: LivenessAppUIClientServerViewController?
    var appSettings: AppSettingsModel?
    // determine if start capture viewcontroller in viewDidAppear
    var hasCaptureProcessStarted = false
    public var shouldSkipDisplayIfLivenessSucceed = true

    // handle callbacks
    public typealias GotFaceCaptureCallback = (
        _ error: Bool,
        _ faceBuffer: [UInt8]?
        ) -> Void
    var mFaceCaptureCallback: GotFaceCaptureCallback? = {_, _ in }
    open func setCallback(callback: @escaping GotFaceCaptureCallback) {
        mFaceCaptureCallback = callback
    }
    
    var sessionId: String?
    
    public override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        super.viewWillAppear(animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if PassiveFaceLivenessManagerViewController.livenessAppUIClientServerViewController == nil {
            
           
            // Setup and prejjsent
            PassiveFaceLivenessManagerViewController.livenessAppUIClientServerViewController = UIStoryboard(name: "PassiveFaceLiveness", bundle: Bundle.init(identifier: "com.aware.auth.PassiveFaceLivenessSDK")).instantiateViewController(withIdentifier: "LivenessAppUIClientServerViewController") as! LivenessAppUIClientServerViewController
            PassiveFaceLivenessManagerViewController.livenessAppUIClientServerViewController?.setBioSPLivenessCheckingUrl(url: CommonConstants.FACE_LIVENESS_CHECK_WITH_SESSION_URL)
            PassiveFaceLivenessManagerViewController.livenessAppUIClientServerViewController?.setBioSPServerCredentials(username: CommonConstants.SERVICE_USERNAME, password: CommonConstants.SERVICE_PASSWORD)
            
            PassiveFaceLivenessManagerViewController.livenessAppUIClientServerViewController?.setBiospRequestType(type: BioSPRequestType.BASE64)
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasCaptureProcessStarted {
            self.hasCaptureProcessStarted = true
            applyAppSettings()
            self.runAppUIClientServerLivenessComponent()
        }
    }
    
//    // apply user defailed settings
    private func applyAppSettings(){
        appSettings = AppSettingsModel(
            captureTimeout: 0,
            serverUrl:CommonConstants.FACE_LIVENESS_CHECK_WITH_SESSION_URL,
            workflow: CommonConstants.defaultWorkflow,
            displayMode:CommonConstants.defaultDisplayMode)
    }
    
    // handling after liveness capture and server checking. At this moment, the communication with server has been done.
    public func responseDidReceive(restCommand: ClientRestCommand, status: Bool, jsonDict: [String : Any], imageData: Data?) {
        do {
            objc_sync_enter(responseLock)
            defer { objc_sync_exit(responseLock) }

            // Is command result ok:
            let isSuccess = status
            
            // Is content of result ok:
            if isSuccess, restCommand == ClientRestCommand.analyze {

                let title = NSLocalizedString("CAPTURE", comment: "")
                
                // Unpack the JSON response
                do {
                    let analyzeResponse = try AnalyzeResponse(json: jsonDict)
                    var message = ""
                    if let displayMessage = analyzeResponse?.display(
                        mode: DisplayMode.fromString(term: CommonConstants.defaultDisplayMode),
                        videoThreshold: CommonConstants.defaultVideoLivenessThreshold,
                        voiceThreshold: nil) {
                        message = displayMessage
                    }
                    print("[HomeClientServerVC] display: " + message)
                    
                    // NOTE: Captured image already deserialized and sent as a parameter to
                    // responseDidReceive.
                    
                    // Get video liveness score, if any.
                    var isLivenessWorkflow = false
                    var videoScore: Double? = nil
                    if let ar = analyzeResponse {
                        if let vl = ar.videoLiveness {
                            if let lr = vl.livenessResult {
                                isLivenessWorkflow = true
                                videoScore = lr.score
                            }
                        }
                    }
                    
                    
                    // Livenesss Pass/Fail determination.
                    var isLive: Bool?
                    isLive = checkLive(
                        videoLivenessScore: videoScore)

                    // Display results
                    DispatchQueue.main.async {
                        self.showResultAlert(restCommand: restCommand, message: message, imageData: imageData, isLivenessWorkflow: isLivenessWorkflow, isLive: isLive)
                    }

                } catch {
                    // Display invalid response result
                    var message = NSLocalizedString("Try Again", comment: "")
                    if appSettings?.displayMode == DisplayMode.verbose.rawValue {
                        message = (jsonDict as Any as! String)
                    }
                    
                    DispatchQueue.main.async {
                        self.showResultAlert(restCommand: nil, message: message, imageData: nil, isLivenessWorkflow: true, isLive: false)
                    }
                }
            }
            else {
                var message = "Face Liveness Capture Failed"
                if let errorMsg = jsonDict["error"] as? String {
                    message = errorMsg
                }
                DispatchQueue.main.async {
                    self.showResultAlert(restCommand: nil, message: message, imageData: nil, isLivenessWorkflow: true, isLive: false)
                }
            }
        }
    }
    
    //
    // MARK: Conform to ServerResponseDelegate
    //
    
    // Check line for video only
    //    - true if the score is greater than the threshold
    //    - false if the score is less than the threshold
    //    - nil if the input was nil. This indicates that liveness
    //      was not requested
    private func checkLive(videoLivenessScore: Double?) -> Bool? {
        
        var isLive = false
        if let sc = videoLivenessScore {
            if sc > CommonConstants.defaultVideoLivenessThreshold {
                isLive = true
            }
        } else {
            return nil
        }
        
        return isLive
    }

    public func runAppUIClientServerLivenessComponent() -> Void {
        DispatchQueue.main.async {
            print("runAppUIClientServerLivenessComponent - BEGIN")

            PassiveFaceLivenessManagerViewController.livenessAppUIClientServerViewController?.restDelegate = self
            PassiveFaceLivenessManagerViewController.livenessAppUIClientServerViewController?.captureTimeout = (self.appSettings?.captureTimeout)!
            PassiveFaceLivenessManagerViewController.livenessAppUIClientServerViewController?.username = (self.appSettings?.username)!
            PassiveFaceLivenessManagerViewController.livenessAppUIClientServerViewController?.serverEndpoint = (self.appSettings?.serverUrl)!
            PassiveFaceLivenessManagerViewController.livenessAppUIClientServerViewController?.selectedWorkflow = (self.appSettings?.workflow)!
            
            
            PassiveFaceLivenessManagerViewController.livenessAppUIClientServerViewController?.setSessionId(sessionId: self.sessionId)
            
            print("[HomeVC | runAppUICSLC] serverEndpoint: \(String(describing: PassiveFaceLivenessManagerViewController.livenessAppUIClientServerViewController?.serverEndpoint))")
            PassiveFaceLivenessManagerViewController.livenessAppUIClientServerViewController!.modalPresentationStyle = .fullScreen
            self.present(PassiveFaceLivenessManagerViewController.livenessAppUIClientServerViewController!, animated: true, completion: nil)
        
            print("runAppUIClientServerLivenessComponent - END")
        }
            
    }

    private func showResultAlert(
        restCommand: ClientRestCommand?,
        message: String,
        imageData: Data?,
        isLivenessWorkflow: Bool,
        isLive: Bool?) {
        
        var error = false
        var actionText = "OK"
        var statusText = NSLocalizedString("Success", comment: "")
        
        if imageData == nil || imageData?.count == 0 {
            actionText = "OK - NO Image"
            statusText = NSLocalizedString("Try Again", comment: "")
            error = true
        }
        if isLivenessWorkflow == true && isLive == false {
            statusText = NSLocalizedString("Try Again", comment: "")
            error = true
        }
        let cmd = restCommand
        var header = NSLocalizedString(cmd?.rawValue ?? "CAPTURE", comment: "")
        let colorized = PassiveFaceLivenessHelpers.colorizeMessage(message: message)
        var alertController = UIAlertController(
            title: header,
            message: message,
            preferredStyle: .alert)
        alertController.setValue(colorized, forKey: "attributedMessage")
        
        let alertWidth = alertController.view.frame.size.width
        var image: UIImage?
        if let imgData = imageData {
            if imgData.count > 0 {
                
                image = UIImage(data: imageData!)
                alertController.addImage(image: image!)
            }
        }
        
        if error {
            let cancelAction = UIAlertAction(
                title: "Cancel",
                style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    self.dismiss(animated: true, completion: {
                        self.mFaceCaptureCallback?(true, nil)
                    })
            }
            let retryAction = UIAlertAction(
                title: "Retry",
                style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    self.runAppUIClientServerLivenessComponent()
            }
            alertController.addAction(cancelAction)
            alertController.addAction(retryAction)
        }
        else {
            let okAction = UIAlertAction(
                title: actionText,
                style: UIAlertAction.Style.default) {
                    (result : UIAlertAction) -> Void in
                    self.dismiss(animated: true, completion: {
                        self.mFaceCaptureCallback?(false, [UInt8](imageData!))
                    })
            }
            alertController.addAction(okAction)
        }
        if shouldSkipDisplayIfLivenessSucceed && !error {
            self.dismiss(animated: true, completion: {
                self.mFaceCaptureCallback?(false, [UInt8](imageData!))
            })
        }
        else {
            self.present(alertController, animated: true, completion: nil)
        }
//        self.present(alertController, animated: true, completion: nil)
    }
    
}

