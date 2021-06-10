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

class OCRResultContainerViewController: UIViewController {

    @IBOutlet weak var nameLabelField: UILabel!
    @IBOutlet weak var genderAgeLabelField: UILabel!
    @IBOutlet weak var overallLabelField: UILabel!
    @IBOutlet weak var portraitImageView: UIImageView!
    @IBOutlet weak var signatureImageView: UIImageView!
    
    
    var documentAuthenticationResponse: DocumentAuthenticationResponse?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        super.viewWillAppear(animated)

        if let response = self.self.documentAuthenticationResponse {
            if let overallResult = response.overallAuthenticationResult {
                self.overallLabelField.text = (overallResult == AuthenticationResult.OK.rawValue) ? "✅" : "❌"
            }

            if let age = response.documentAuthenticationResult?.getFieldType(byTypeId: 185)?.fieldResult?.getValue(), let gender = response.documentAuthenticationResult?.getFieldType(byTypeId: 12)?.fieldResult?.getValue() {
                self.genderAgeLabelField.text = "\(gender), \(age)"
            }
            else if let age = response.documentAuthenticationResult?.getFieldType(byTypeId: 185)?.fieldResult?.getValue() {
                self.genderAgeLabelField.text = "\(age)"
            } else if let gender = response.documentAuthenticationResult?.getFieldType(byTypeId: 12)?.fieldResult?.getValue() {
                self.genderAgeLabelField.text = "\(gender)"
            }
            
            if let surnameAndGivenNames = response.documentAuthenticationResult?.getFieldType(byTypeId: 25)?.fieldResult?.getValue() {
                self.nameLabelField.text = "\(surnameAndGivenNames)"
            }
            else if let surName = response.documentAuthenticationResult?.getFieldType(byTypeId: 8)?.fieldResult?.getValue(), let givenName = response.documentAuthenticationResult?.getFieldType(byTypeId: 9)?.fieldResult?.getValue() {
                self.nameLabelField.text = "\(surName) \(givenName)"
            } else if let surName = response.documentAuthenticationResult?.getFieldType(byTypeId: 8)?.fieldResult?.getValue() {
                self.nameLabelField.text = "\(surName)"
            } else if let givenName = response.documentAuthenticationResult?.getFieldType(byTypeId: 9)?.fieldResult?.getValue() {
                self.nameLabelField.text = "\(givenName)"
            }
            
            if let portraitImageBase64String = response.biometricsAuthenticationResult?.portraitImage, let portraitUIImage = CommonUtils.convertImageFromBase64StringToUIImage(base64Str: portraitImageBase64String) {
                self.portraitImageView.image = portraitUIImage
            }
            
            if let signatureImageBase64String = response.documentAuthenticationResult?.signatureImage, let signatureUIImage = CommonUtils.convertImageFromBase64StringToUIImage(base64Str: signatureImageBase64String) {
                self.signatureImageView.image = signatureUIImage
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "containerToOCRDetailsSegue" {
            let resultDetailViewController: OCRResultViewController = segue.destination as! OCRResultViewController
            resultDetailViewController.documentAuthenticationResponse = self.documentAuthenticationResponse
        }
    }


}
