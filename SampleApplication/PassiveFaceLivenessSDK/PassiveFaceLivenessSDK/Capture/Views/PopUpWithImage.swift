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

import UIKit

class PopUpWithImage: UIView {

    //
    // MARK: Properties
    //
    
    var capturedImageView = UIImageView()
    var closeButton = UIButton()
    
    // FUTURE - TODO: var textView = UITextView()

    
    
    //
    // MARK: Initializers
    //
    
    // Initializer to be used programmatically
    override init(frame: CGRect) {
        
        super.init(frame: frame)

        setup()
    }
    
    // Initializer to be used from the Storyboard.
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        setup()
    }
    

    //
    // MARK: Private Methods
    //
    
    private func setup() -> Void {
        
        DispatchQueue.main.async {
            self.isHidden = false

            // Size, setup, add subviews
            self.setupCapturedImageView()
            self.setupCloseButton()
            
            // Add actions
            self.closeButton.addTarget(
                self, action:
                #selector(self.didPressCloseButton),
                for: .touchUpInside)
        }
    }
    
    private func setupCapturedImageView() -> Void {
        
        let cornerRadius = CGFloat(20)
        
        // Set size of image view within custom view.
        let frame = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height)
        capturedImageView.frame = frame
        
        capturedImageView.contentMode = .scaleAspectFit
        
        capturedImageView.layer.borderWidth = 1
        capturedImageView.layer.cornerRadius = cornerRadius
        capturedImageView.layer.borderColor = UIColor.black.cgColor
        
        // Set radius to same as for capturedImageView
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        
        // Add subviews
        self.addSubview(capturedImageView)
    }
    
    private func setupCloseButton() -> Void {
        
        closeButton.backgroundColor = UIColor.red
        
        // Add subviews
        self.addSubview(closeButton)
        
        // Add constraints
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        // Get the superview's layout
        let margins = self.layoutMarginsGuide
        
        // Pin the top edge of myView to the margin's top edge
        closeButton.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
        
        // Pin the trailing edge of myView to the margin's trailing edge
        closeButton.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
        
        // Set height and width
        closeButton.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        
        // Content
        closeButton.setTitle("X", for: UIControl.State.normal)
        closeButton.contentHorizontalAlignment = .center
        closeButton.titleLabel?.adjustsFontSizeToFitWidth = true
    }
    
    
    //
    // MARK: Actions
    //

    @objc func didPressCloseButton() -> Void {
        
        print("didPressCloseButton")
        self.isHidden = true
    }
    
}
