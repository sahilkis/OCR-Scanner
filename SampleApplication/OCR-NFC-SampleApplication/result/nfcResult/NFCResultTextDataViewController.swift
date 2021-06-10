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

class NFCResultTextDataViewController: UIViewController, IndicatorInfoProvider,  UITableViewDelegate, UITableViewDataSource {

    var tabName: String?
    var fieldTypes: [NFCFieldType] = [NFCFieldType]()
    var resultDisplayDTO: NFCResultDisplayDTO? {
        didSet {
            if let rfidValidationResult = resultDisplayDTO?.rfidValidationResult, let dg1BiographicInfo = rfidValidationResult.dg1BiographicInfo {
                
                // get variable name and values by reflection
                let dg1Mirror = Mirror(reflecting: dg1BiographicInfo)
                for child in dg1Mirror.children {
                    if let variableName = child.label {
                        if let variableValue = child.value as? String, !variableValue.isEmpty {
                            fieldTypes.append(NFCFieldType(key: variableName, value: variableValue))
                        }
                    }
                }
                
            }
            
            if let rfidValidationResult = resultDisplayDTO?.rfidValidationResult, let dg11BiographicInfo = rfidValidationResult.dg11BiographicInfo {
                
                let dg11Mirror = Mirror(reflecting: dg11BiographicInfo)
                for child in dg11Mirror.children {
                    if let variableName = child.label {
                        if let variableValue = child.value as? String, !variableValue.isEmpty {
                            fieldTypes.append(NFCFieldType(key: variableName, value: variableValue))
                        }
                    }
                        
                        
                }
            }
        }
    }

    
    
    @IBOutlet weak var fieldTypeNameTitleLabel: UILabel!
    @IBOutlet weak var fieldTypeValueTitleLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: tabName)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        fieldTypeNameTitleLabel.text = "Field type"
        fieldTypeValueTitleLabel.text = "NFC"
        self.tableView.estimatedRowHeight = 60
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fieldTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "nfcFieldTypeCell", for: indexPath) as! NFCDocumentFieldTypeCellTableViewCell
        let fieldType = self.fieldTypes[indexPath.row]
        cell.fieldTypeKeyLabel.text = fieldType.key ?? ""
        cell.fieldTypeValueLabel.text = fieldType.value ?? ""
        cell.indexPath = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
