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

import Foundation
import UIKit


/// UI Alert helper class
public class Alerts {
    
    public static func displayError(vc: UIViewController, err: String) ->Void {
        DispatchQueue.main.async {

            let msg = NSLocalizedString(err, comment: "")
            
            let ac = UIAlertController(
                title: NSLocalizedString("Error", comment: ""),
                message: msg,
                preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            vc.present(ac, animated: true)
        }
    }
    
    public static func showError(vc: UIViewController, err: String) ->Void {
        DispatchQueue.main.async {
            // NOTE: Overriding err
            let msg = NSLocalizedString("Try Again", comment: "")
            
            let ac = UIAlertController(
                title: NSLocalizedString("Error", comment: ""),
                message: msg, // err,
                preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            vc.present(ac, animated: true)
        }
    }
    
    public static func displayAcknowledgeAlert(alertTitle: String, buttonTitle: String, alterMessage: String) -> UIAlertController {
        let alert = UIAlertController(title: alertTitle, message: alterMessage, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertAction.Style.default, handler: nil))
        
        // To left justify text in UIAlertController
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = NSTextAlignment.left
        
        let messageText = NSMutableAttributedString(
            string: alterMessage,
            attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        )
        alert.setValue(messageText, forKey: "attributedMessage")
        
        return alert
    }
}


