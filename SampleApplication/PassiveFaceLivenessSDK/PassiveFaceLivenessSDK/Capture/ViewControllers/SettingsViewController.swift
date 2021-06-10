//
//  SettingsViewController.swift
//
//  Copyright © 2017 Aware Inc. All rights reserved.
//

import UIKit
import AVFoundation

// Throw connection status error
enum SettingsStatus: String {
    case noError = "No error"
    case connectionsOK = "Connections OK"
    case noResponseFromPreFaceServer = "No response from Video server. "
    case noResponseFromKnomiServer = "No response from Knomi server. "
    case noUserID = "User ID required, please enter a User ID."
}

protocol SettingsStatusDelegate: class {
    func updateSettingsStatus(
        settings: AppSettingsModel,
        statusList: [SettingsStatus],
        message: String)
}



/// SettingsViewController - UI to set application level settings.
/// These include: userID, and all server URLs. A scrollable view
/// is used and when a textField is selected, the content is shifted
/// up to prevent the keyboard from covering the textField.
class SettingsViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //
    // MARK: Delegates
    //
    
    weak var delegate: SettingsStatusDelegate?
    
    func onUpdateSettingsStatus(statusList: [SettingsStatus], message: String) {
        
        print("[SVC | onUpdateSettingsStatus], appSettings: \(String(describing: appSettings))")
        
        delegate?.updateSettingsStatus(settings: appSettings!, statusList: statusList, message: message)
    }
    
    
    //
    // MARK: Properties
    //
    
    @IBOutlet weak var captureTimeoutTextField: UITextField!
    var captureTimeout: Int = 0
    
    @IBOutlet weak var usernameTextField: UITextField!
    var username = "--- Enter username ---"

    @IBOutlet weak var urlTextField: UITextField!
    let defaultKnomiServerEndpoint = "http://mobileauth.aware-demos.com:8084/knomi"
    var appUrl = ""
    
    @IBOutlet weak var workflowPicker: UIPickerView!
    let workflowPickerData = ["alfa - Passive", "bravo - Events", "charlie - Passive", "delta - Passive back", "echo"]
    // TODO: , "foxtrot", "golf"]
    var selectedWorkflow: String = "alfa"
    
    @IBOutlet weak var displayModePicker: UIPickerView!
    let displayModePickerData = ["verbose", "standard", "minimal", "none"]
    var selectedDisplayMode: DisplayMode = DisplayMode.standard

    @IBOutlet weak var testButton: UIButton!
    @IBOutlet weak var resetSettingsButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var privacyButton: UIButton!
    @IBOutlet weak var licenseButton: UIButton!
    
    @IBOutlet weak var settingsScrollView: UIScrollView!
    var overlay: UIView?
    
    var keyboardHeight: Float = 0.0
    var currentTextField: UITextField!
    
    var appSettings: AppSettingsModel?
    var originalSettings: AppSettingsModel?
    
    
    
    //
    // MARK: UIViewController Delegate Methods
    //
    
    override func viewDidDisappear(_ animated: Bool) {
        print("[SettingsVC | viewDidDisappear]")

        super.viewDidDisappear(animated)
        
        // When this view controller is dismissed, do
        // not get keyboard notifications
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardDidShowNotification,
            object: nil)
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardDidHideNotification,
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("[SettingsVC | viewWillAppear]")

        super.viewWillAppear(animated)
        
        // Do not allow save if no username
        if appSettings?.username == "" {
            self.saveButton.isEnabled = false
        } else {
            self.saveButton.isEnabled = true
        }
        
        // Observe (listen for) keyboard did show notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow(sender:)),
            name: UIResponder.keyboardDidShowNotification,
            object: self.view.window)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidHide(sender:)),
            name: UIResponder.keyboardDidHideNotification,
            object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("[SettingsVC | viewDidAppear]")

        super.viewDidAppear(animated)
        
        if let savedAppSettings = loadSettings() {
            appSettings = savedAppSettings
        } else {
            appSettings = AppSettingsModel(
                captureTimeout: 0,
                username: "",
                serverUrl: defaultKnomiServerEndpoint,
                workflow: "alfa",
                displayMode: DisplayMode.standard.rawValue)
        }
        
        // Update UI
        // TODO: for now, hide license button
        licenseButton.isHidden = true
        
        testButton.setGradientBackgroundGray()
        resetSettingsButton.setGradientBackgroundGray()
        cancelButton.setGradientBackgroundGray()
        saveButton.setGradientBackgroundGray()
        
        testButton.setTitleColor(UIColor.gray, for: .disabled)
        resetSettingsButton.setTitleColor(UIColor.gray, for: .disabled)
        cancelButton.setTitleColor(UIColor.gray, for: .disabled)
        saveButton.setTitleColor(UIColor.gray, for: .disabled)

        captureTimeoutTextField.text = String(format:"%d", (appSettings?.captureTimeout)!)
        usernameTextField.text = appSettings?.username
        urlTextField.text = appSettings?.serverUrl
        
        captureTimeout = (appSettings?.captureTimeout)!
        username = (appSettings?.username)!
        appUrl = (appSettings?.serverUrl)!
        
        setupWorkflowPicker()
        setupDisplayModePicker()
        
        let workflowRow = self.workflowPickerData.index(where: {$0.contains( (appSettings?.workflow)!) })
        workflowPicker.selectRow(workflowRow!, inComponent: 0, animated: true)
        
        let displayModeRow = self.displayModePickerData.index(of: (appSettings?.displayMode)!)
        displayModePicker.selectRow(displayModeRow!, inComponent: 0, animated: true)
        
        self.selectedWorkflow = (appSettings?.workflow)!
        self.selectedDisplayMode = DisplayMode(rawValue: (appSettings?.displayMode)!)!
        
        // Save original settings
        originalSettings = AppSettingsModel(
            captureTimeout: (appSettings?.captureTimeout)!,
            username: (appSettings?.username)!,
            serverUrl: (appSettings?.serverUrl)!,
            workflow: (appSettings?.workflow)!,
            displayMode: (appSettings?.displayMode)!)
        
        // Do not allow save if no username
        if appSettings?.username == "" {
            self.saveButton.isEnabled = false
        } else {
            self.saveButton.isEnabled = true
        }
    }
    
    private func setupWorkflowPicker() {
        
        // Connect data:
        self.workflowPicker.delegate = self
        self.workflowPicker.dataSource = self
    }
    
    private func setupDisplayModePicker() {
        
        // Connect data:
        self.displayModePicker.delegate = self
        self.displayModePicker.dataSource = self
    }
    
    override func viewDidLoad() {
        print("[SettingsVC | viewDidLoad]")
        
        super.viewDidLoad()
        
        // Handle text field's user input through delegate callbacks.
        captureTimeoutTextField.delegate = self
        usernameTextField.delegate = self
        urlTextField.delegate = self
        
        captureTimeoutTextField.addDoneButtonToKeyboard(myAction:  #selector(self.captureTimeoutTextField.resignFirstResponder))

    }
    
    override func didReceiveMemoryWarning() {
        print("[SettingsVC | didReceiveMemoryWarning]")

        super.didReceiveMemoryWarning()
    }

    
    //
    // MARK: UITextField Delegate Methods
    //
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        currentTextField = textField
        
        let textFieldTop: Float = Float(currentTextField.frame.origin.y)
        let textFieldBottom: Float = textFieldTop + Float(currentTextField.frame.size.height)
        
        if textFieldBottom > keyboardHeight && keyboardHeight != 0.0 {
            let offset: CGPoint = CGPoint(x: CGFloat(0), y: CGFloat(textFieldBottom - keyboardHeight))
            
            settingsScrollView.setContentOffset(offset, animated: true)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == usernameTextField {
            username = textField.text!
            
            // Do not allow save if no username
            if username == "" {
                self.saveButton.isEnabled = false
            } else {
                self.saveButton.isEnabled = true
            }
            
        } else if textField == urlTextField {
            appUrl = textField.text!
        } else if textField == captureTimeoutTextField {
            captureTimeout = (captureTimeoutTextField.text?.toInt())!
            captureTimeout = (captureTimeoutTextField.text?.toInt())!
        }
    }
    
    
    //
    // MARK: Conform to Picker
    //
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        switch(pickerView) {
        case workflowPicker:
            return workflowPickerData.count
        case displayModePicker:
            return displayModePickerData.count
        default:
            return 0
        }
    }
    
    // The data to return for the row and component (column)
    // that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        switch(pickerView) {
        case workflowPicker:
            return workflowPickerData[row]
        case displayModePicker:
            return displayModePickerData[row]
        default:
            return ""
        }
    }
    
    // Get the selected picker item
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if pickerView == workflowPicker {
            let wf = workflowPickerData[row]
            selectedWorkflow = wf.mapWorkflowPickerDataNameToSelectedWorkflowName()
        }
        else if pickerView == displayModePicker {
            selectedDisplayMode = DisplayMode.fromString( term: displayModePickerData[row] )
        }
    }
    
    // Set picker text size
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = UIFont(name: "Ariel", size: 20)
            pickerLabel?.textAlignment = .center
        }
        
        if pickerView == workflowPicker {
            pickerLabel?.text = workflowPickerData[row]
        }
        else if pickerView == displayModePicker {
            pickerLabel?.text = displayModePickerData[row]
        }

        // pickerLabel?.textColor = UIColor.white
        pickerLabel?.textColor = UIColor.black

        return pickerLabel!
    }
    
    //
    // MARK: Methods
    //
    
    @objc func keyboardDidShow(sender: Notification) {
        
        // Get height of keyboard
        let info: Dictionary = sender.userInfo!
        let keyboardSize: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = Float(keyboardSize.height)
        
        // Ensure the current text field is visible, if not
        // adjust the contentOffset of the scrollView
        let textFieldTop: Float = Float(currentTextField.frame.origin.y)
        let textFieldBottom: Float = textFieldTop +
            Float(currentTextField.frame.size.height)
        
        if textFieldBottom > keyboardHeight {
            let offset = CGPoint(x: 0, y: CGFloat(textFieldBottom - keyboardHeight))
            settingsScrollView.setContentOffset(offset, animated: true)
        }
    }
    
    @objc func keyboardDidHide(sender: Notification) {
        settingsScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
    }
    
    
    //
    // MARK: Validity and connection Methods
    //
    
    /// Tests the URL settings - will ping the nexaFace and
    /// preFace and config servers. If any do not respond,
    /// an error status is returned.
    ///
    /// - parameters
    ///   - name="versionMessageString">Version message string.</param>
    /// - returns
    ///   - (statusCode, message)
    public func testURLSettings(settings: AppSettingsModel) -> ([SettingsStatus], String) {
        
        var status: SettingsStatus = SettingsStatus.noError
        var versionMessage = ""
        var statusList = Array<SettingsStatus>()
        
        // Test Preface Server
        let prefaceClient = PreFaceClient(endpoint: settings.serverUrl)
        do {
            versionMessage += "Video server: "
            versionMessage += try prefaceClient.version() + "\n"
            versionMessage = versionMessage.replacingOccurrences(of: "<BR>", with: ", ")
            
        } catch {
            status = SettingsStatus.noResponseFromPreFaceServer
            versionMessage += status.rawValue // " - "
            statusList.append(status)
            
            print("[SettingsViewController | testURLSettings] prefaceClient: \(status)")
        }
        
        // Test Knomi Server
        let knomiClient = KnomiClient(endpoint: settings.serverUrl)
        do {
            versionMessage += "\nKnomi server: "
            versionMessage += try knomiClient.version() + "\n"
            versionMessage = versionMessage.replacingOccurrences(of: "<BR>", with: ", ")
            
        } catch {
            status = SettingsStatus.noResponseFromKnomiServer
            versionMessage += status.rawValue // " - "
            statusList.append(status)
            
            print("[SettingsViewController | testURLSettings] knomiClient: \(status)")
        }
        
        versionMessage = versionMessage.removeTrailingCommaSpace()
        
        return (statusList, versionMessage)
    }
    
    private func testConnections(displayAlert: Bool, resetSettingsToOriginal: Bool) -> ([SettingsStatus], String) {
        
        var status: SettingsStatus = SettingsStatus.noError
        var testURLMessage = ""
        
        var statusList = Array<SettingsStatus>()
        
        var currentAppSettings: AppSettingsModel?
        if resetSettingsToOriginal == true {
            // Reset settings to original
            currentAppSettings = AppSettingsModel(
                captureTimeout: (self.originalSettings?.captureTimeout)!,
                username: (self.originalSettings?.username)!,
                serverUrl: (self.originalSettings?.serverUrl)!,
                workflow: (self.originalSettings?.workflow)!,
                displayMode: (self.originalSettings?.displayMode)!)
        } else {
            // Set values entered by user
            currentAppSettings = AppSettingsModel(
                captureTimeout: self.captureTimeout,
                username: self.username,
                serverUrl: self.appUrl,
                workflow: self.selectedWorkflow,
                displayMode: self.selectedDisplayMode.rawValue)
        }
        
        if currentAppSettings?.isUsernameOK() == false {
            status = SettingsStatus.noUserID
            statusList.append(status)
        } else {
            (statusList, testURLMessage) = self.testURLSettings(settings: currentAppSettings!)
        }
        
        return (statusList, testURLMessage)
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
    
    @IBAction func testSettingsButton_TouchUpInstide(_ sender: UIButton) {
            testSettings()
        }

    func testSettings() {
        
        var (statusList, message) = self.testConnections(displayAlert: true, resetSettingsToOriginal: false)
        
        for status in statusList {
            if status == SettingsStatus.noUserID {
                message = status.rawValue
            }
        }
        
        DispatchQueue.main.async {
          
            if statusList.count > 0 {
                let alert = Alerts.displayAcknowledgeAlert(
                    alertTitle: "Warning",
                    buttonTitle: "OK",
                    alterMessage: message)
                self.present(alert, animated: true, completion: nil)
            } else {
                let alert = Alerts.displayAcknowledgeAlert(
                    alertTitle: "Connection - SUCCESS",
                    buttonTitle: "OK",
                    alterMessage: "\nServer versions: " + message)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        self.onUpdateSettingsStatus(statusList: statusList, message: message)
    }
    
    @IBAction func resetSettingsButton_TouchUpInside(_ sender: UIButton) {
        resetSettings()
    }
    
    func resetSettings() {
        // NOTE: Do not change username
        // NOTE: Do not change captureTimeout
        
        DispatchQueue.main.async {
            
            // Update display
            self.urlTextField.text = self.defaultKnomiServerEndpoint
            self.appUrl = self.defaultKnomiServerEndpoint
            
            // Set "charlie" as default
            self.workflowPicker.selectRow(2, inComponent: 0, animated: true)
            self.selectedWorkflow = self.workflowPickerData[2].mapWorkflowPickerDataNameToSelectedWorkflowName()

            // Set "standard" as default
            self.displayModePicker.selectRow(1, inComponent: 0, animated: true)
            self.selectedDisplayMode = DisplayMode.fromString(term: self.displayModePickerData[1])
        }
    }
    
    // Save, persist, app settings
    private func persistSettings() -> Bool {
        
        print("archive path: \(AppSettingsModel.ArchiveURL.path)")
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(appSettings!, toFile: AppSettingsModel.ArchiveURL.path)
        print("[persistSettings] isSuccessfulSave: \(isSuccessfulSave)")

        return isSuccessfulSave
    }
    
    private func loadSettings() -> AppSettingsModel?  {
        return NSKeyedUnarchiver.unarchiveObject(withFile: AppSettingsModel.ArchiveURL.path) as? AppSettingsModel
    }
    
    public func saveDefaultSettings() -> Bool {
        appSettings?.captureTimeout = 0
        appSettings?.username = ""
        appSettings?.serverUrl = defaultKnomiServerEndpoint
        appSettings?.workflow = "alfa"
        appSettings?.displayMode = DisplayMode.standard.rawValue
        
        // Save, persist, default app settings
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(appSettings!, toFile: AppSettingsModel.ArchiveURL.path)
        print("[saveDefaultSettings] isSuccessfulSave: \(isSuccessfulSave)")
        print("[saveDefaultSettings] appSettings AFTER changes: \(self)")
        print("[saveDefaultSettings] appSettings AFTER changes: " + self.description)
        
        return isSuccessfulSave
    }
    
    @IBAction func saveSettingsButton_TouchUpInside(_ sender: UIButton) {
        saveSettings()
    }
    
    func saveSettings() {
        
        DispatchQueue.global(qos: .background).async {
            
            let (statusList, connectionMessage) = self.testConnections(displayAlert: false, resetSettingsToOriginal: false)
            print("message: " + connectionMessage)
            
            DispatchQueue.main.async {
                
                var title = "Confirm"
                var message = "Are you sure?"
                
                if statusList.count > 0 {
                    title = "Warning - Connection"
                    message = connectionMessage
                }
                
                let alertController = UIAlertController(
                    title: title,
                    message: message,
                    preferredStyle: UIAlertController.Style.alert)
                
                let cancelAction = UIAlertAction(
                    title: "Cancel",
                    style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        
                        return
                }
                
                let saveAction = UIAlertAction(
                    title: "Save",
                    style: UIAlertAction.Style.default) {
                        (result : UIAlertAction) -> Void in
                        
                        self.appSettings?.captureTimeout = self.captureTimeout
                        self.appSettings?.username = self.username
                        self.appSettings?.serverUrl = self.appUrl
                        self.appSettings?.workflow = self.selectedWorkflow
                        self.appSettings?.displayMode = self.selectedDisplayMode.rawValue
                        
                        let isSuccessfulSave = self.persistSettings()
                        
                        // Raise event notifying listeners and supply data
                        if isSuccessfulSave {
                            self.onUpdateSettingsStatus(statusList: statusList, message: "Settings Saved")
                        }
                        
                        // Dismiss the alert
                        self.dismiss(animated: true, completion: nil)
                        
                        // Segue back to Home VC.
                        self.performSegue(withIdentifier: "unwindToHome", sender: self)
                }
                
                alertController.addAction(cancelAction)
                alertController.addAction(saveAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelSettingsButton_TouchUpInside(_ sender: UIButton) {
        cancelSettings()
    }
    
    private func cancelSettings() -> Void {
        // Reset settings to original
        appSettings?.captureTimeout = (originalSettings?.captureTimeout)!
        appSettings?.username = (originalSettings?.username)!
        appSettings?.serverUrl = (originalSettings?.serverUrl)!
        appSettings?.workflow = (originalSettings?.workflow)!
        appSettings?.displayMode = (originalSettings?.displayMode)!

        // Update UI
        captureTimeoutTextField.text = String(format:"%d", (appSettings?.captureTimeout)!)
        usernameTextField.text = appSettings?.username
        urlTextField.text = appSettings?.serverUrl
        
        captureTimeout = (appSettings?.captureTimeout)!
        username = (appSettings?.username)!
        appUrl = (appSettings?.serverUrl)!
        
        // TODO -
        workflowPicker.selectRow(0, inComponent: 0, animated: true)
        displayModePicker.selectRow(0, inComponent: 0, animated: true)
        
        let (statusList, message) = testConnections(displayAlert: false, resetSettingsToOriginal: true)
        
        // Notify
        onUpdateSettingsStatus(statusList: statusList, message: message)
        
        // Segue back to Home VC.
        self.performSegue(withIdentifier: "unwindToHome", sender: self)

    }
    
    @IBAction func privacyButton_TouchUpInside(_ sender: UIButton) {
        showPrivacy()
    }

    @IBAction func licenseButton_TouchUpInside(_ sender: UIButton) {
        showLicense()
    }
    
    private func showPrivacy() -> Void {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(NSURL(string: "http://www.aware.com/privacy/mobileapps")! as URL, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
            UIApplication.shared.openURL(NSURL(string: "http://www.aware.com/privacy/mobileapps")! as URL)
        }
    }
    
    private func showLicense() -> Void {
        DispatchQueue.main.async {
            
            // TODO:
            let message = "TODO: License agreement to be pulled from build system."

            let alert = Alerts.displayAcknowledgeAlert(
                alertTitle: "License",
                buttonTitle: "OK",
                alterMessage: message)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
