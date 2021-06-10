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
import XLPagerTabStrip

class NFCResultSummaryViewController: UIViewController, IndicatorInfoProvider {
    
    var tabName: String?
    var resultDisplayDTO: NFCResultDisplayDTO?
    
    @IBOutlet weak var resultTextField: UILabel!
    @IBOutlet weak var resultImage: UIImageView!
    @IBOutlet weak var resultComplexView: UIView!
    

    @IBOutlet weak var signatureOnSODValidTextField: UILabel!
    @IBOutlet weak var certificateChainValidTextField: UILabel!
    @IBOutlet weak var dataGroupHashesValidTextField: UILabel!
    @IBOutlet weak var facialMatchScoreTextField: UILabel!
    @IBOutlet weak var facialMatchResultTextField: UILabel!
    @IBOutlet weak var activeAuthenticationResultTextField: UILabel!
    

    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tabName)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.resultComplexView.layer.borderWidth = 3
        self.resultComplexView.layer.borderColor = UIColor.systemBlue.cgColor
        
        var overallVerificationResult = true
        
        if let rfidValidationResult = resultDisplayDTO?.rfidValidationResult {
            self.signatureOnSODValidTextField.text = "SignatureOnSODValid: \((rfidValidationResult.signatureOnSODValid ?? false) ? "SUCCESS" : "FAIL")"
            self.certificateChainValidTextField.text = "CertificateChainValid: \((rfidValidationResult.certificateChainValid ?? false) ? "SUCCESS" : "FAIL")"
            self.dataGroupHashesValidTextField.text = "DataGroupHashesValid: \((rfidValidationResult.dataGroupHashesValid ?? false) ? "SUCCESS" : "FAIL")"
            overallVerificationResult = overallVerificationResult
                                        && (rfidValidationResult.signatureOnSODValid ?? false)
                                        && (rfidValidationResult.certificateChainValid ?? false)
                                        && (rfidValidationResult.dataGroupHashesValid ?? false)
        }
        else {
            overallVerificationResult = false
        }
        
        if let matchResult = resultDisplayDTO?.verifyBiometricsResponse, let facialMatchScore = matchResult.matchScore {
            facialMatchScoreTextField.text = "Facial Match Score: \(String(format: "%.3f", facialMatchScore))"
            
            // controlled in mobile side
            facialMatchResultTextField.text = "Facial Match Result: \((facialMatchScore > 2.0) ? "SUCCESS" : "FAIL")"
            overallVerificationResult = overallVerificationResult && (facialMatchScore > 2.0)
        }
        else {
            overallVerificationResult = false
        }
        
        /*
        if let matchResult = resultDisplayDTO?.verifyBiometricsResponse, let verifyResult = matchResult.verifyResult {
            facialMatchResultTextField.text = "Facial Match Result: \(verifyResult ? "SUCCESS" : "FAIL")"
            overallVerificationResult = overallVerificationResult && verifyResult
        } else {
            overallVerificationResult = false
        }
 */
        
        if let aaResult = resultDisplayDTO?.rfidValidationResult?.activeAuthenticationResult {
            activeAuthenticationResultTextField.text = "AA Result: \(aaResult)"
        } else {
            // active authentication not supported
            activeAuthenticationResultTextField.text = "AA Result: NotSupported"
        }

        if overallVerificationResult == true {
            setResultSuccess()
        } else {
            setResultFail()
        }
    }
    
    private func setResultFail() {
        resultTextField.text = "Failure"
        resultTextField.textColor = UIColor.red
        resultImage.image = UIImage(named: "VerifyFailed")
    }
    
    private func setResultSuccess() {
        resultTextField.text = "Success"
        resultTextField.textColor = UIColor.green
        resultImage.image = UIImage(named: "VerifySuccess")
    }
}
