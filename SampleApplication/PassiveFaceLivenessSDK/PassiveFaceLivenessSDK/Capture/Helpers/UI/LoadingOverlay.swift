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


/// Full screen overlay
public class LoadingOverlay: UIView {

    //
    // MARK: Properties
    //
    
    private static var loadingOverlay: LoadingOverlay?
    
    // private static var loadingOverlay = LoadingOverlay(frame: UIView.self, message: "Loading... yaya")
    
    // Control declarations
    var activitySpinner: UIActivityIndicatorView
    var messageLabel: UILabel

    // override
    private init(frame: CGRect, message: String) {
        activitySpinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        messageLabel = UILabel()

        super.init(frame: frame)

        // Configurable bits
        self.backgroundColor = UIColor.black
        self.alpha = 0.75
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let labelHeight = 22.0
        let labelWidth = frame.width - 20.0

        // derive the center x and y
        let centerX = frame.width / 2.0
        let centerY = frame.height / 2.0

        // Center the activitySpinner horizontally
        // and put it 5 points above center x
        activitySpinner.frame =
            CGRect(
                x: centerX - (activitySpinner.frame.width / 2.0),
                y: centerY - activitySpinner.frame.height - 20.0,
                width: activitySpinner.frame.width,
                height: activitySpinner.frame.height)

        activitySpinner.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addSubview(activitySpinner)
        activitySpinner.startAnimating()

        messageLabel = UILabel(frame: CGRect(
            x: centerX - (labelWidth / 2.0),
            y: centerY + 20.0,
            width: labelWidth,
            height: CGFloat(labelHeight)))

        messageLabel.backgroundColor = UIColor.clear
        messageLabel.textColor = UIColor.white
        messageLabel.text = message

        messageLabel.textAlignment = .center
        messageLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        addSubview(messageLabel)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// <summary>
    /// Fades out the control and then removes it from the super view
    /// </summary>
    open func hide() -> Void {
        DispatchQueue.main.async {

            UIView.animate(
                withDuration: 0.5,
                animations: { self.alpha = 0 },
                completion: { (Bool) in self.removeFromSuperview()}
            )
        }
    }

    
    //
    // MARK: UI Hourglass
    //
    
    open static func updateHourglass(message: String) -> Void {
        loadingOverlay?.messageLabel.text = message
    }
    
    open static func hideHourglass() -> Void {
        loadingOverlay?.hide()
        loadingOverlay?.removeFromSuperview()
    }
    
    open static func showHourglass(view: UIView, message: String) -> Void {
        let bounds = UIScreen.main.bounds
        
        // show the loading overlay on the UI thread using
        // the correct orientation sizing
        loadingOverlay = LoadingOverlay(frame: bounds, message: message)
        view.addSubview(loadingOverlay!)
    }
    
}

