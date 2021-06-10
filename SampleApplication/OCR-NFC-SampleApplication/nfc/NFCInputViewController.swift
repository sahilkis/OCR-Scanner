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

@available(iOS 13, *)
protocol NFCInputDelegate {
    // called when the inputs are complete and validated
    func onInputComplete(passportNumber: String, dateOfBirth: String, dateOfExpiry: String);
}

@available(iOS 13.0, *)
class NFCInputViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var passportNumberTextField: UITextField!
    @IBOutlet weak var dateOfBirthTextField: UITextField!
    @IBOutlet weak var dateOfExpiryTextField: UITextField!
    var delegate : NFCInputDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        let tapRecognizer = UITapGestureRecognizer(target: self,action: #selector(self.hideKeyboard))
        tapRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapRecognizer)
        passportNumberTextField.delegate = self
        dateOfBirthTextField.delegate = self
        dateOfExpiryTextField.delegate = self
        passportNumberTextField.autocorrectionType = .no
        dateOfBirthTextField.autocorrectionType = .no
        dateOfBirthTextField.autocorrectionType = .no
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == dateOfBirthTextField || textField == dateOfExpiryTextField{
            DatePickerDialog().show(title: "Pick up Date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) {
                (date) -> Void in
                if let dt = date {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyMMdd"
                    DispatchQueue.main.async {
                        textField.text = formatter.string(from: dt)
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        super.viewWillAppear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        let systemVersion = UIDevice.current.systemVersion
        print("systemVersion: \(systemVersion)")
        
        // Document number input is always capitalized
        passportNumberTextField.autocapitalizationType = .allCharacters
        passportNumberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)

        // memorize previously saved values
        if let passportNumberSaved = UserDefaults.standard.string(forKey: "passportNumber"),
            let dateOfBirthSaved =  UserDefaults.standard.string(forKey: "dateOfBirth"), let dateOfExpirySaved = UserDefaults.standard.string(forKey: "dateOfExpiry") {
            passportNumberTextField.text = passportNumberSaved
            dateOfBirthTextField.text = dateOfBirthSaved
            dateOfExpiryTextField.text = dateOfExpirySaved
        }
    }
    
    @objc func textFieldDidChange() {
        passportNumberTextField.text = passportNumberTextField.text?.uppercased()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)

        return false
    }

    @objc func hideKeyboard(sender: UITapGestureRecognizer) {
        
        passportNumberTextField.resignFirstResponder()
        dateOfBirthTextField.resignFirstResponder()
        dateOfExpiryTextField.resignFirstResponder()
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func startBtnPressed(_ sender: UIButton) {

        let (isValid, errorMessage) = isInputValid()
        
        guard isValid else {
            print("invalid input: \(errorMessage ?? "")")
            self.showAlert(status: "Invalid input: \(errorMessage ?? "")", error: true)
            return
        }
        
        let passportNumber = passportNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let dateOfBirth = dateOfBirthTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        let expiryDate = dateOfExpiryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        UserDefaults.standard.set(passportNumber, forKey: "passportNumber")
        UserDefaults.standard.set(dateOfBirth, forKey: "dateOfBirth")
        UserDefaults.standard.set(expiryDate, forKey: "dateOfExpiry")
        
        self.dismiss(animated: true) {
            self.delegate?.onInputComplete(passportNumber: passportNumber!, dateOfBirth: dateOfBirth!, dateOfExpiry: expiryDate!)
        }
    }
    
    
    
    
    
    private func isInputValid() -> (Bool, String?) {
        guard let passportNumber = self.passportNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), passportNumber.count >= 8 else {
            return (false, "passport number is invalid")
        }
        
        guard let dateOfBirth = self.dateOfBirthTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), dateOfBirth.count == 6 else {
            return (false, "date of birth is invalid")
        }
        
        guard let expiryDate = self.dateOfExpiryTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), expiryDate.count == 6 else {
            return (false, "date of birth is invalid")
        }
        
        guard let dateOfBirthMonth = Int(dateOfBirth[2..<4]),
            dateOfBirthMonth > 0, dateOfBirthMonth <= 12,
            let dateOfBirthDate = Int(dateOfBirth[4..<dateOfBirth.count]),
            dateOfBirthDate > 0, dateOfBirthDate <= 31 else {
                return (false, "date of birth is invalid")
        }
        
        guard let expiryDateMonth = Int(expiryDate[2..<4]),
            expiryDateMonth > 0, expiryDateMonth <= 12,
            let expiryDateDate = Int(expiryDate[4..<expiryDate.count]),
            expiryDateDate > 0, expiryDateDate <= 31 else {
                return (false, "date of birth is invalid")
        }
        return (true, nil)
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
        self.present(alert, animated:true, completion: nil)
    }
}
