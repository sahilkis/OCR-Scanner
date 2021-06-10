/*
 *  © 2017-2019 Aware, Inc.  All Rights Reserved.
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
import FaceLiveness



public protocol ServerResponseDelegate: class {
    
    // Propogate response
    func responseDidReceive(
        restCommand: ClientRestCommand,
        status: Bool,
        jsonDict: [String: Any],
        imageData: Data?)
    
}

protocol AutocaptureOnDeviceDelegate: class {
    
    // TODO: Handle ability to stop if cannot autocapture at all...
    
    // Propogate captured image
    func autocaptureOnDeviceImage(
        image: UIImage?)
}

/// This class demonstrates how to consume the Aware LivenessComponent,
/// disable the built-in default UI, and add App level UI.
public class LivenessAppUIClientServerViewController: UIViewController, RestDelegate {
    
    // only allow portrait orientation
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
    
    public override var shouldAutorotate: Bool {
        get {
            return false
        }
    }
    
    //
    // MARK: UI Properties
    //
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var feedbackLabel: UILabel!
    @IBOutlet weak var positionDeviceLabel: UILabel!
    @IBOutlet weak var faceLiveness: FaceLiveness!
    @IBOutlet weak var devicePositionControl: DevicePositionControl!
    
    @IBOutlet weak var startStopButton: UIButton!
    
    var shapeMaskLayer: CAShapeLayer?
    
    
    //
    // MARK: Properties
    //
    
    var autocapturedImage: UIImage?
    
    var isDidLoadFailure: Bool = false
    var loadFailureMessage: String = ""
    var isWorkflowRunning: Bool = false
    
    public var captureTimeout: Int?
    public var username: String?
    public var serverEndpoint: String?
    public var selectedWorkflow: String = ""
    public var performConstruction: Bool = false
    public var captureOnDevice: Bool = false

    // Device Overriding Configurations
    public var deviceOverridingSettings: String?
    
    var bioSPClient: BioSPClient?
    var bioSPLivenessCheckingUrl: String?
    var bioSPUsername: String?
    var bioSPPassword: String?
    var sessionId: String?
    
    // default is sending base64
    static var biospRequestType: BioSPRequestType = BioSPRequestType.BASE64
    
    public func setBiospRequestType(type: BioSPRequestType) {
        LivenessAppUIClientServerViewController.biospRequestType = type
    }
    
    public func setBioSPLivenessCheckingUrl(url: String) {
        self.bioSPLivenessCheckingUrl = url
    }
    
    public func setBioSPServerCredentials(username: String, password: String) {
        self.bioSPUsername = username
        self.bioSPPassword = password
    }

    public func setSessionId(sessionId: String?) {
        self.sessionId = sessionId
    }
    
    //
    // MARK: Init/deinit
    //
    
    init() {
        print("[ClientServer | init]")
        
        super.init(nibName: "", bundle: nil)
        if bioSPClient == nil {
            bioSPClient = BioSPClient()
            bioSPClient?.delegate = self
        }
        setStaticProperties()
    }
    
    required init?(coder aDecoder: NSCoder) {
        print("[ClientServer | init?]")
        
        super.init(coder: aDecoder)
        if bioSPClient == nil {
            bioSPClient = BioSPClient()
            bioSPClient?.delegate = self
        }
        setStaticProperties()
    }
    
    deinit {
        faceLiveness = nil
    }
    
    private func setStaticProperties() {
        do {
            try FaceLiveness.setStaticPropertyString(name: StaticPropertyTag.faceModel, value: "mobile")
        } catch let err {
            let message = "EXCEPTION: setup static properties of livenessComponent - error " + err.localizedDescription
            print(message)
            return
        }
    }
    
    //
    // MARK: Delegates
    //
    
    public weak var restDelegate: ServerResponseDelegate?
    
    func notifyResponseDidReceive(restCommand: ClientRestCommand, status: Bool, jsonDict: [String: Any], imageData: Data?) {
        
        print("[LAUICSVC | notifyResponseDidReceive] thread: \(Thread.current)")
        
        DispatchQueue.main.async {
            self.hideHourglass()
            
            self.dismiss(animated: true, completion: {
                self.autocapturedImage = nil
                self.restDelegate?.responseDidReceive(restCommand: restCommand, status: status, jsonDict: jsonDict, imageData: imageData)
            })
        }
    }
    
    weak var autocaptureDelegate: AutocaptureOnDeviceDelegate?
    
    // Send notification to HomeClientServerViewController
    func notifyAutocaptureDidOccur(image: UIImage?) {
        
        print("[LAUICSVC | notifyAutocaptureDidOccur] thread: \(Thread.current)")
        self.autocaptureDelegate?.autocaptureOnDeviceImage(image: image)
        self.dismiss(animated: true, completion: nil)
    }
    
    //
    // MARK: Conform to RestDelegate
    //
    
    // Propogate data to HVC
    func responseReceived(
        restCommand: ClientRestCommand,
        status: Bool,
        response: [String: Any]?,
        message: String) {
        
        print("[LAUICSVC | responseReceived] BEGIN")
        
        var resp = response
        var msg = message
        var isResponseValid = false
        
        if resp != nil {
            if (resp?.count)! > 0 {
                do {
                    // DEBUG:
                    let encounterJSON =
                        try JSONSerialization.data(withJSONObject: resp!, options: JSONSerialization.WritingOptions.prettyPrinted)
                    print("[LAUICSVC | responseReceived] response (from JSONSerialization):" + String(data: encounterJSON, encoding: .utf8)!)
                    
                    isResponseValid = true
                } catch {
                    print("[LAUICSVC | responseReceived] Could not deserialize json response. Invalid response")
                    resp = [String: Any]()
                    msg = "Invalid response"
                }
            }
        } else {
            resp = [String: Any]()
            
            msg += "\nServer connection lost."
            resp!["error"] = msg
            // DEBUG:
            // print("[LAUICSVC | responseReceived] " + "Command: " + restCommand.rawValue + ", response is nil. status: \(status), " + msg)
        }
        
        if isResponseValid {
            // Valid response, continue:
            
            switch restCommand {
                
            case ClientRestCommand.analyze:
                
                print("[LAUICSVC | responseReceived] responseReceived - analyze")
                
                // Propogate data to classes that implement ServerResponseDelegate
                var capturedImage: Data?
                
                //DEBUG
                print("videoResponseJSON: \(resp as Any)")
                
                do {
                    
                    // Parse JSON
                    let analyzeResponse = try AnalyzeResponse(json: resp!)
                    
                    // Get video portion
                    let analyzeVideoResponse = analyzeResponse?.videoLiveness
                    if let capturedImageBase64 = analyzeVideoResponse?.autocaptureResult.capturedFrame {
                        capturedImage = Data(base64Encoded: capturedImageBase64)
                    }
                    
                } catch {
                    // swallow, no image
                    print("No image")
                }
                
                // Propogate to home VC:
                notifyResponseDidReceive(restCommand: restCommand, status: status, jsonDict: resp!, imageData: capturedImage)
            }
        } else {
            // Display action alert, unwind to HomeViewController
            notifyResponseDidReceive(restCommand: restCommand, status: status, jsonDict: resp!, imageData: nil)
        }
    }
    
    //
    // MARK: UIViewController Methods
    //
    
    override public func viewWillDisappear(_ animated: Bool) {
        print("[LAUICSVC | viewWillDisappear] - BEGIN")
        LoadingOverlay.hideHourglass()
        print("[LAUICSVC | viewWillDisappear] - END")
    }
    
    override public func viewDidDisappear(_ animated: Bool) {
        print("[LAUICSVC | viewDidDisappear")
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        
        print("[LAUICSVC | viewDidAppear")
        
        // DEBUG
        print("[LAUICSVC | viewDidAppear] serverEndpoint: \(String(describing: serverEndpoint))")
        
        if isDidLoadFailure == true {
            let msg = NSLocalizedString("Load failure", comment: "") + ": " + loadFailureMessage
            print(msg)
            
            DispatchQueue.main.async {
                
                // Show alert
                let alertController = UIAlertController(
                    title: NSLocalizedString("Error", comment: ""),
                    message: msg,
                    preferredStyle: .alert)
                
                let okAction = UIAlertAction(
                    title: "OK",
                    style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        
                        self.dismiss(animated: true, completion: nil)
                }
                
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
            return
        }
        
        do {
            print("[LAUICSVC | viewDidAppear] BEFORE isWorkflowRunning == \(isWorkflowRunning)")
            try locateAppUI()
        } catch FaceLivenessError.regionOfInterestNotAvailable {
            print("region of interest not available")
        } catch {
            print("Exhaustive catch on locateAppUI")
        }
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        
        print("[LAUICSVC | viewWillAppear")
        
        // UI
        if shapeMaskLayer != nil {
            shapeMaskLayer?.removeFromSuperlayer()
            shapeMaskLayer = nil
        }
        
        // Setup livenessComponent
        //  * Set callbacks
        //  * (Optional) Specify username
        //  * Set workflow - NOTE: MUST run setWorkflow BEFORE set camera
        //  * Set camera
        //  * Set/get app UI info
        //  * Start worklow
    
        do {
            print(faceLiveness.getVersion())
            faceLiveness.setDevicePositionCallback(callback: didReceiveDevicePosition)
            faceLiveness.setFeedbackCallback(callback: didReceiveFeedback)
            faceLiveness.setWorkflowStateCallback(callback: didReceiveWorkflowState)
            try faceLiveness.setPropertyBool(name: .captureOnDevice, value: self.captureOnDevice)
            try faceLiveness.setPropertyBool(name: .constructImage, value: self.performConstruction)
            try faceLiveness.setPropertyString(name: .username, value: "TestUser")
            try faceLiveness.setPropertyDouble(name: .captureTimeout, value: Double(self.captureTimeout!))
            
            
            showAppLevelUI()
            
            // Select Workflow
            try faceLiveness.selectWorkflow(workflow: selectedWorkflow, overrideParametersJson: deviceOverridingSettings)
            
            // NOTE: MUST retrieve regionOfInterest AFTER workflow is selected and AFTER
            // layoutSubviews. Therefore do this in viewDidAppear ONLY!!!
            // try locateAppUI()
            
            try faceLiveness.start()
            isWorkflowRunning = true
            
            self.startStopButton.setTitle(NSLocalizedString("STOP", comment: ""), for: UIControl.State.normal)
        } catch FaceLivenessError.faceModelNotSupportWorkflow {
            loadFailureMessage = FaceLivenessError.faceModelNotSupportWorkflow.description + ".\nGo to Setting screen to change."
            self.isDidLoadFailure = true
            return
        } catch let err {
            let message = "EXCEPTION: setup livenessComponent - error " + err.localizedDescription
            print(message)
            loadFailureMessage = ""
            self.isDidLoadFailure = true
            return
        }
    }
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.setNeedsDisplay()
    }
    
    //
    // MARK: Callback completion handlers
    //
    
    
    // Handler for device position
    func didReceiveDevicePosition(y: CGFloat, isInPosition: Bool) {
        
        // Update devicePositionControl
        self.devicePositionControl.updateSegments(y: y, isInPosition: isInPosition)
    }
    
    // Handler for feedback result
    func didReceiveFeedback(feedback: FeedbackResult) -> Void {
        
        DispatchQueue.main.async {
            self.feedbackLabel.text = feedback.autocaptureFeedback.description
        }
    }
    
    // Handler for workflow state
    private func didReceiveWorkflowState(
        workflowState: WorkflowState,
        data: String) -> Void {
        
        switch(workflowState) {
        case .workflowPreparing:
            DispatchQueue.main.async {
                
                // Make sure livenessComponent is not hidden
                self.faceLiveness.isHidden = false
                
                // Content
                self.statusLabel.text = NSLocalizedString("Position Device", comment: "")
                
                // Show all UI
                self.showAppLevelUI()
                self.positionDeviceLabel.isHidden = false
                self.feedbackLabel.isHidden = true
                
                self.positionDeviceLabel.text = NSLocalizedString("Tilt Device", comment: "")
            }
            break
        case .workflowDeviceInPosition:
            DispatchQueue.main.async {
                self.statusLabel.text = NSLocalizedString("Position Face", comment: "")
                self.positionDeviceLabel.isHidden = true
                self.feedbackLabel.isHidden = false
            }
            break
        case .workflowHoldSteady:
            DispatchQueue.main.async {
                
                self.feedbackLabel.isHidden = false
                self.feedbackLabel.text = NSLocalizedString("Hold", comment: "")
                
                self.shapeMaskLayer?.strokeColor = UIColor.green.cgColor
                self.shapeMaskLayer?.fillColor = lightBlueA5.cgColor
            }
            break
        case .workflowCapturing:
            DispatchQueue.main.async {
                self.statusLabel.text = NSLocalizedString("Hold", comment: "")
                self.feedbackLabel.isHidden = true
                self.shapeMaskLayer?.strokeColor = UIColor.green.cgColor
                self.shapeMaskLayer?.fillColor = lightBlue.cgColor
            }
            break
        case .workflowEvent:
            DispatchQueue.main.async {
                
                self.statusLabel.text = NSLocalizedString(data, comment: "")
                self.feedbackLabel.isHidden = false
            }
            break
        case .workflowShowUI:
            DispatchQueue.main.async {
                // Show all UI
                self.statusLabel.isHidden = false
                self.feedbackLabel.isHidden = false
                self.devicePositionControl.isHidden = false
                self.startStopButton.isHidden = false
                self.shapeMaskLayer?.isHidden = false
            }
            break
        case .workflowHideUI:
            DispatchQueue.main.async {
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                // Hide all UI
                self.statusLabel.isHidden = true
                self.feedbackLabel.isHidden = true
                self.devicePositionControl.isHidden = true
                self.startStopButton.isHidden = true
                self.shapeMaskLayer?.isHidden = true
            }
            break
        case .workflowPostProcessing:
            DispatchQueue.main.async {
                
                LoadingOverlay.showHourglass(view: self.view, message: "...Calculating...")
                
                // Hide all UI
                self.statusLabel.isHidden = true
                self.feedbackLabel.isHidden = true
                self.devicePositionControl.isHidden = true
                self.startStopButton.isHidden = true
                self.shapeMaskLayer?.isHidden = true
            }
            break
        case .workflowComplete:
            
            // These helper hourglass functions put onto main thread
            hideHourglass()
            showHourglass(message: "Loading Data...")
            
            self.isWorkflowRunning = false
            
            //
            // MARK: Section for Autocapture on device
            //
            if self.captureOnDevice {
                do {
                    self.autocapturedImage = try self.faceLiveness.getCapturedImage()
                } catch let err {
                    print("getCapturedImage threw - no image: \(err)")
                }
                self.notifyAutocaptureDidOccur(image: self.autocapturedImage)
            }
            
            //
            // MARK: Section for populating server package
            //
            
            // Get JSON package to send to server
            
            do {
                let serverPackage =  try self.faceLiveness.getServerPackage()
                
                // DEBUG:
                print("[LAUICSVC | didReceiveWorkflowState] serverPackage: ")
//                print(serverPackage.prettyPrint())
                if let url = self.bioSPLivenessCheckingUrl, let username = self.bioSPUsername, let password = self.bioSPPassword {
                    try self.sendRequestToServer(url: url, username: username, password: password, sessionId: self.sessionId, package: serverPackage)
                }
                else {
                    print("Invalid BioSP server configuration. Either BioSP URL or credentials are missing")
                }
            } catch {
                print("test getServerPackage or sendRequestToServer threw")
                
                self.isDidLoadFailure = true
                LoadingOverlay.hideHourglass()
                
                self.didReceiveWorkflowState(
                    workflowState: WorkflowState.workflowAborted,
                    data: "")
            }
            
            break
            
        case .workflowAborted:
            isWorkflowRunning = false
            
            // Hide UI
            DispatchQueue.main.async {
                // Hide all UI
                self.statusLabel.isHidden = true
                
                self.feedbackLabel.isHidden = true
                self.devicePositionControl.isHidden = true
                self.startStopButton.isHidden = true
                self.shapeMaskLayer?.isHidden = true
                
                // Segue back to Home VC where handler will throw up an alert message
                // from there displaying timedout abort occured.
//                self.performSegue(withIdentifier: "timedOutUnwindToHome", sender: self)
                self.notifyResponseDidReceive(restCommand: ClientRestCommand.analyze, status: false, jsonDict: [String: Any](), imageData: nil)
            }
            
            break
        case .workflowTimedOut:
            isWorkflowRunning = false
                        
                        // Hide UI
                        DispatchQueue.main.async {
                            // Hide all UI
                            self.statusLabel.isHidden = true
                            
                            self.feedbackLabel.isHidden = true
                            self.devicePositionControl.isHidden = true
                            self.startStopButton.isHidden = true
                            self.shapeMaskLayer?.isHidden = true
                            
                            // Segue back to Home VC where handler will throw up an alert message
                            // from there displaying timedout abort occured.
            //                self.performSegue(withIdentifier: "timedOutUnwindToHome", sender: self)
                            self.notifyResponseDidReceive(restCommand: ClientRestCommand.analyze, status: false, jsonDict: [String: Any](), imageData: nil)
                        }
                        
                        break
        }
    }
    
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //
    // MARK: Methods
    //
    
    private func sendRequestToServer(url: String, username: String, password: String, sessionId: String?, package: [String: Any]) throws -> Void {
        bioSPClient?.analyzeVideo(urlFullString: url, bioSPUsername: username, biospPassword: password, sessionId: sessionId, json: package)
    }
    
    private func showAppLevelUI() {
        DispatchQueue.main.async {
            
            self.positionDeviceLabel.isHidden = false
            self.statusLabel.isHidden = false
            self.feedbackLabel.isHidden = true
            self.devicePositionControl.isHidden = false
            self.startStopButton.isHidden = false
            self.shapeMaskLayer?.isHidden = false
            self.shapeMaskLayer?.strokeColor = UIColor.red.cgColor
            self.shapeMaskLayer?.fillColor = UIColor.gray.withAlphaComponent(0.75).cgColor
        }
    }
    
    private func locateAppUI() throws -> Void {
        
        // Get the roi data from the lc
        let roidata = try faceLiveness.getRegionOfInterest()
        let roiX = Double(roidata[0])
        let roiY = Double(roidata[1])
        let roiW = Double(roidata[2])
        let roiH = Double(roidata[3])
        
        let maskFrame = CGRect(
            x: 0.0,
            y: 0.0,
            width: UIScreen.main.bounds.width,
            height: UIScreen.main.bounds.height)
        
        let viewFrame = CGRect(
            x: self.faceLiveness.frame.minX,
            y: self.faceLiveness.frame.minY,
            width: self.faceLiveness.frame.width,
            height: self.faceLiveness.frame.height
        )
        
        var scaleFactor = 0.8
        var shiftX = Double(UIScreen.main.bounds.width) * (1 - scaleFactor) / 2
        var shiftY = (Double(UIScreen.main.bounds.height) - roiH + roiH * (1 - scaleFactor)) / 2
        shiftY -= 18
        // set scale Factor based on iPhone model's screen width/height ratio
        // iPhone X similar will be 0.46, and iPhone 7 similar will be 0.56
        let screenWHRatio = Double(UIScreen.main.bounds.width) / Double(UIScreen.main.bounds.height)
//        print(screenWHRatio)
        
        if screenWHRatio < 0.5 {
            // iPhone X similar
            scaleFactor = 0.7
            shiftX = Double(UIScreen.main.bounds.width) * (1 - scaleFactor) / 2
            shiftY = (Double(UIScreen.main.bounds.height) - roiH + roiH * (1 - scaleFactor)) / 2
            shiftY -= 30
        }
        print("scaleFactor: \(scaleFactor)")

        let roiFrame = CGRect(
            x: roiX * scaleFactor + shiftX,
            y: roiY * scaleFactor + shiftY,
            width: roiW * scaleFactor,
            height: roiH * scaleFactor)
        
        // Set shape mask layer
        shapeMaskLayer = CAShapeLayer()
        shapeMaskLayer?.frame = maskFrame
        
        let maskFillColor = UIColor.gray.withAlphaComponent(0.75).cgColor
        let maskStrokeColor = UIColor.red.cgColor
        
        drawBezierShapeMaskLayer(
            boundingViewBox: viewFrame,
            boundingBox: roiFrame,
            fillColor: maskFillColor,
            strokeColor: maskStrokeColor)
        
        self.view.layer.addSublayer(shapeMaskLayer!)
        self.view.setNeedsDisplay()
        
        // Force display of App level UI views to front
        self.view.bringSubviewToFront(statusLabel)
        self.view.bringSubviewToFront(feedbackLabel)
        self.view.bringSubviewToFront(startStopButton)
        self.view.bringSubviewToFront(devicePositionControl)
        
        // Set button properties
        setupStartStopButton()
    }
    
    func setupStartStopButton() {
        
        startStopButton.setTitle("STOP", for: UIControl.State.normal)
        startStopButton.setTitleColor(UIColor.black, for: .normal)
        startStopButton.titleLabel?.textAlignment = .center
        startStopButton.backgroundColor = UIColor.white
        startStopButton.layer.cornerRadius = 5
        startStopButton.layer.borderWidth = 1
        startStopButton.layer.borderColor = UIColor.black.cgColor
        
        // Associate action with button
        // Can do this through Storyboard/designer, or
        // programmatically. Shown here programmatically
        startStopButton.addTarget(
            self,
            action: #selector(startStopButton_TouchUpInside(_:)),
            for: .touchUpInside)
        
        startStopButton.isEnabled = true
    }
    
    private func alertError(message: String) -> Void {
        DispatchQueue.main.async {
            let ac = UIAlertController(
                title: NSLocalizedString("ERROR", comment: ""),
                message: message,
                preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
        }
    }
    
    private func drawBezierShapeMaskLayer(
        boundingViewBox: CGRect,
        boundingBox: CGRect,
        fillColor: CGColor,
        strokeColor: CGColor)
    {
        // Create path and add bounding box
        let viewPath = UIBezierPath()
        viewPath.append(UIBezierPath(rect: boundingViewBox))
        
        // Add silhouette path
        viewPath.append(createSilhouetteBezierPath(boundingBox: boundingBox, verticalParts: 3))
        
        // Set shape mask
        shapeMaskLayer?.path = viewPath.cgPath
        shapeMaskLayer?.fillRule = CAShapeLayerFillRule.evenOdd
        shapeMaskLayer?.fillColor = fillColor
        shapeMaskLayer?.strokeColor = strokeColor
        shapeMaskLayer?.lineWidth = 2
        shapeMaskLayer?.opacity = 0.8
    }
    
    // "Race track" bezier path
    // verticalParts: Example: if 4 then curve part of racetrack is 1/4 of height
    func createSilhouetteBezierPath(boundingBox: CGRect, verticalParts: CGFloat) -> UIBezierPath {
        let boxHeight = boundingBox.height
        let boxWidth = boundingBox.width
        let boxMinX = boundingBox.minX
        let boxMinY = boundingBox.minY
        let boxMaxX = boundingBox.maxX
        let boxMaxY = boundingBox.maxY
        let quarterWidth = boxWidth / 4
        let halfWidth = boxWidth / 2
        let verticalPartHeight = boxHeight / verticalParts
        let verticalPartHalfHeight = verticalPartHeight / 2
        
        // Start path
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: boxMinX, y: boxMinY + verticalPartHeight))
        
        // First half of top
        bezierPath.addCurve(
            to: CGPoint(x: boxMinX + halfWidth, y: boxMinY),
            controlPoint1: CGPoint(x: boxMinX, y: boxMinY + verticalPartHalfHeight),
            controlPoint2: CGPoint(x: boxMinX + quarterWidth, y: boxMinY)
        )
        
        // Second half of top
        bezierPath.addCurve(
            to: CGPoint(x: boxMaxX, y: boxMinY + verticalPartHeight),
            controlPoint1: CGPoint(x: boxMaxX - quarterWidth, y: boxMinY),
            controlPoint2: CGPoint(x: boxMaxX, y: boxMinY + verticalPartHalfHeight)
        )
        
        // Connect top to bottom
        bezierPath.addLine(
            to: CGPoint(x: boxMaxX, y: boxMaxY - verticalPartHeight)
        )
        
        // First half of bottom
        bezierPath.addCurve(
            to: CGPoint(x: boxMinX + halfWidth, y: boxMaxY),
            controlPoint1: CGPoint(x: boxMaxX, y: boxMaxY - verticalPartHalfHeight),
            controlPoint2: CGPoint(x: boxMaxX - quarterWidth, y: boxMaxY)
        )
        
        // Second half of bottom
        bezierPath.addCurve(
            to: CGPoint(x: boxMinX, y: boxMaxY - verticalPartHeight),
            controlPoint1: CGPoint(x: boxMinX + quarterWidth, y: boxMaxY),
            controlPoint2: CGPoint(x: boxMinX, y: boxMaxY - verticalPartHalfHeight)
        )
        
        // Connect bottom to top
        bezierPath.addLine(
            to: CGPoint(x: boxMinX, y: boxMinY + verticalPartHeight)
        )
        
        return bezierPath
    }
    
    func showHourglass(message: String) -> Void {
        DispatchQueue.main.async {
            LoadingOverlay.showHourglass(view: self.view, message: message)
        }
    }
    
    func hideHourglass() -> Void {
        DispatchQueue.main.async {
            LoadingOverlay.hideHourglass()
        }
    }
    
    
    //
    // MARK: Actions
    //
    
    // Start / stop worklow, update UI
    @IBAction func startStopButton_TouchUpInside(_ sender: UIButton) {
        
        if isWorkflowRunning {
            do {
                try faceLiveness.stop()
                isWorkflowRunning = false
                self.startStopButton.setTitle(NSLocalizedString("START", comment: ""), for: UIControl.State.normal)
                self.devicePositionControl.isHidden = true
//                self.performSegue(withIdentifier: "stopUnwindToHome", sender: self)
                notifyResponseDidReceive(restCommand: ClientRestCommand.analyze, status: false, jsonDict: [String: Any](), imageData: nil)
            } catch {
                let message = "EXCEPTION from livenessComponent.stop()"
                print(message)
                
                self.isDidLoadFailure = true
                return
                
            }
        } else {
            do {
                try faceLiveness.start()
                isWorkflowRunning = true
                self.startStopButton.setTitle(NSLocalizedString("STOP", comment: ""), for: UIControl.State.normal)
                self.devicePositionControl.isHidden = false
            } catch {
                let message = "EXCEPTION from livenessComponent.start()"
                print(message)
                
                self.isDidLoadFailure = true
                return
            }
        }
    }
    
}


