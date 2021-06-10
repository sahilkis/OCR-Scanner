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

class NFCResultContainerViewController: UIViewController {

    @IBOutlet weak var nameLabelField: UILabel!
    @IBOutlet weak var portraitImageView: UIImageView!

    
    var resultDisplayDTO: NFCResultDisplayDTO?
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
        if let photo = resultDisplayDTO?.photoImage {
            portraitImageView.image = photo
        }
        
        if let firstName = resultDisplayDTO?.rfidValidationResult?.dg1BiographicInfo?.primaryIdentifier, let lastName = resultDisplayDTO?.rfidValidationResult?.dg1BiographicInfo?.secondaryIdentifier {
            nameLabelField.text = "\(firstName)\n\(lastName)"
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "containerToNFCDetailsSegue" {
            let resultDetailViewController: NFCResultViewController = segue.destination as! NFCResultViewController
            resultDetailViewController.resultDisplayDTO = self.resultDisplayDTO
        }
    }
}
