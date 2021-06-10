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

class OCRResultViewController: ButtonBarPagerTabStripViewController {

    var documentAuthenticationResponse: DocumentAuthenticationResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonBarView.selectedBar.backgroundColor = .green
        buttonBarView.selectedBar.tintColor = .clear
    }

    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {

        pagerTabStripController.view.backgroundColor = UIColor.clear
        
        let summaryViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OCRResultSummaryViewController") as! OCRResultSummaryViewController
        summaryViewController.tabName = "Summary"
        summaryViewController.documentAuthenticationResponse = documentAuthenticationResponse

        let textDataViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "OCRResultTextDataViewController") as! OCRResultTextDataViewController
        textDataViewController.tabName = "Text Data"
        textDataViewController.documentAuthenticationResponse = documentAuthenticationResponse
        
        let childViewControllers = [summaryViewController, textDataViewController]
        return Array(childViewControllers)
    }
}
