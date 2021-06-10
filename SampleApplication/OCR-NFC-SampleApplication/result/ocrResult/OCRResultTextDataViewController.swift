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

class OCRResultTextDataViewController: UIViewController, IndicatorInfoProvider,  UITableViewDelegate, UITableViewDataSource {
    
    var tabName: String?
    var documentAuthenticationResponse: DocumentAuthenticationResponse? {
        didSet {
            self.fieldTypes = documentAuthenticationResponse?.documentAuthenticationResult?.fieldType
        }
    }
    var fieldTypes: [OCRFieldType]?
    
    @IBOutlet weak var fieldTypeNameTitleLabel: UILabel!
    @IBOutlet weak var barcodeOrMrzTitleLabel: UILabel!
    @IBOutlet weak var ocrTitleLabel: UILabel!
    @IBOutlet weak var OCRMatchingWithBarcodeOrMrzTitleLabel: UILabel!
    @IBOutlet weak var isValidTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var displayBarcode = false
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tabName)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self

        fieldTypeNameTitleLabel.text = "Field type"
        ocrTitleLabel.text = "Visual\nOCR"
        isValidTitleLabel.text = "Result"
        self.tableView.estimatedRowHeight = 60
        
        self.displayBarcode = shouldDisplayBarcode()
        
        if displayBarcode {
            barcodeOrMrzTitleLabel.text = "Barcode"
            OCRMatchingWithBarcodeOrMrzTitleLabel.text = "Barcode-Visual"
        }
        else {
            barcodeOrMrzTitleLabel.text = "Mrz"
            OCRMatchingWithBarcodeOrMrzTitleLabel.text = "Mrz-Visual"
        }
    }
    
    private func shouldDisplayBarcode() -> Bool {
        var containsMrz = false
        var containsBarcode = false
        for fieldType in self.fieldTypes! {
            if let fieldResult = fieldType.fieldResult {
                if let mrzVal = fieldResult.mrz, mrzVal != "" {
                    containsMrz = true
                }
                
                if let barcodeVal = fieldResult.barcode, barcodeVal != "" {
                    containsBarcode = true
                }
            }
        }
        
        if containsMrz { return false}
        
        if containsBarcode { return true}
        
        return false
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fieldTypes?.count == nil ? 0 : (fieldTypes?.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "fieldTypeCell", for: indexPath) as! OCRDocumentFieldTypeCellTableViewCell
        let fieldType = self.fieldTypes![indexPath.row]
        cell.fieldTypeNameLabel.text = fieldType.name!

        cell.barcodeOrMrzLabel.text = displayBarcode ? (fieldType.fieldResult?.barcode != nil ? fieldType.fieldResult?.barcode! : "") : (fieldType.fieldResult?.mrz != nil ? fieldType.fieldResult?.mrz! : "")
        
        cell.ocrLabel.text = fieldType.fieldResult?.visual != nil ? fieldType.fieldResult?.visual! : ""
        cell.OCRMatchingBarcodeOrMrzLabel.text = displayBarcode ? ((fieldType.fieldResult?.visualBarcodeCompareValid == FieldComparisonResult.COMPARE_TRUE.rawValue) ? "✅" : (fieldType.fieldResult?.visualBarcodeCompareValid == FieldComparisonResult.COMPARE_FALSE.rawValue) ? "❌" : "❔") : ((fieldType.fieldResult?.mrzVisualCompareValid == FieldComparisonResult.COMPARE_TRUE.rawValue) ? "✅" : (fieldType.fieldResult?.mrzVisualCompareValid == FieldComparisonResult.COMPARE_FALSE.rawValue) ? "❌" : "❔")
        
        cell.barcodeOrMrzLabel.textColor = displayBarcode ? ((fieldType.fieldResult?.isBarcodeStatusValid == FieldValidationResult.VALIDATE_FALSE.rawValue) ? UIColor.red : UIColor.black) : ((fieldType.fieldResult?.isMrzStatusValid == FieldValidationResult.VALIDATE_FALSE.rawValue) ? UIColor.red : UIColor.black)
        
        
        
        cell.ocrLabel.textColor = (fieldType.fieldResult?.isVisualStatusValid == FieldValidationResult.VALIDATE_FALSE.rawValue) ? UIColor.red : UIColor.black
        cell.isValidLabel.text = (fieldType.overallResult == AuthenticationResult.OK.rawValue) ? "✅" : (fieldType.overallResult == AuthenticationResult.FAILED.rawValue) ? "❌" : "❔"
        
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
