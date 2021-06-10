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

enum ResultDisplayProcesssType {
    case CANCEL, RESCAN, OK, ERROR
}


class DocCaptureResultViewController: UIViewController {

    private var resultDisplayCallback: ResultDisplayCallback? = {_ in }
        public typealias ResultDisplayCallback = (_ processType: ResultDisplayProcesssType) -> Void
        public func setCallback(callback: @escaping ResultDisplayCallback) {
            resultDisplayCallback = callback
        }

        @IBOutlet weak var imageDisplayView: UIView!
        @IBOutlet weak var cancelBtn: UIButton!
        @IBOutlet weak var reCaptureBtn: UIButton!
        @IBOutlet weak var okBtn: UIButton!
        
        public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            get {
                return .landscapeRight
            }
        }
        
        public override var shouldAutorotate: Bool {
            return false
        }

        var imagesToDisplay: [UIImage] = [UIImage]()
        var isForFinalResult = true;
        
        override func viewDidLoad() {
            
        }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.all)
    }
        
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            guard let _ = resultDisplayCallback else {
                print("result display callback not set")
                self.dismiss(animated: true, completion: nil)
                return
            }
            
            let images = imagesToDisplay
            
            guard images.count == 1 || images.count == 2 else {
                print("display images number error")
                self.dismiss(animated: true) {
                    self.resultDisplayCallback!(.ERROR)
                }
                return
            }

            
            // Adding title
            
            var titleHeight: Double = 0
            
            if !isForFinalResult {
                titleHeight = Double(35)
                let titleView = UILabel(frame: CGRect(x: Double(0), y: Double(0), width: Double(imageDisplayView.bounds.size.width), height: titleHeight - 5))
                titleView.text = "Invalid Document Type. Please Try Again."
                titleView.textAlignment = .center
                titleView.font = UIFont.boldSystemFont(ofSize: 20)
                titleView.textColor = .red
                imageDisplayView.addSubview(titleView)
                okBtn.isHidden = true
            }
            
            
            // Adding images
            let totalWidth = Double(imageDisplayView.bounds.size.width)
            let totalHeight = Double(imageDisplayView.bounds.size.height) - titleHeight

            var isHeightFilled = true
            if images.count == 1 {
                
                let singleImage = images[0]
                
                var singleImageHeight = totalHeight
                var singleImageWidth = totalHeight * Double(singleImage.size.width / singleImage.size.height)
                
                if singleImageWidth > totalWidth {
                    singleImageWidth = totalWidth
                    singleImageHeight = totalWidth * Double(singleImage.size.height / singleImage.size.width)
                    isHeightFilled = false
                }
                
                let imageView = isHeightFilled ? UIImageView(
                    frame: CGRect(  x: (totalWidth - singleImageWidth) / 2,
                                    y: titleHeight,
                                    width: singleImageWidth,
                                    height: singleImageHeight)) : UIImageView(frame: CGRect(x: 0, y: (totalHeight - singleImageHeight) / 2, width: singleImageWidth, height: singleImageHeight))

                imageView.image = singleImage
                imageDisplayView.addSubview(imageView)
            }
            else {
                
                let firstImage = images[0]
                let secondImage = images[1]
                
                var eachImageHeight = totalHeight
                var eachImageWidth = totalHeight * Double(firstImage.size.width / firstImage.size.height)
                
                let totalImagesWidth = eachImageWidth * 2
                
                if (totalImagesWidth > totalWidth) {
                    eachImageWidth = totalWidth / 2
                    eachImageHeight = eachImageWidth * Double(firstImage.size.height / firstImage.size.width)
                    isHeightFilled = false
                }
                
                
                
                let firstImageView = isHeightFilled ?
                            UIImageView(frame: CGRect(  x: (totalWidth - eachImageWidth * 2) / 2,
                                                        y: titleHeight,
                                                        width: eachImageWidth,
                                                        height: eachImageHeight)) :
                            UIImageView(frame: CGRect(  x: 0,
                                                        y: (totalHeight - eachImageHeight) / 2 + titleHeight,
                                                        width: eachImageWidth,
                                                        height: eachImageHeight))
                
                
                let secondImageView = isHeightFilled ?
                            UIImageView(frame: CGRect(  x: (totalWidth - eachImageWidth * 2) / 2 + eachImageWidth,
                                                        y: titleHeight,
                                                        width: eachImageWidth,
                                                        height: eachImageHeight)) :
                            UIImageView(frame: CGRect(  x: 0 + eachImageWidth,
                                                        y: (totalHeight - eachImageHeight) / 2 + titleHeight,
                                                        width: eachImageWidth,
                                                        height: eachImageHeight))
                
                firstImageView.image = firstImage
                secondImageView.image = secondImage
                
    //            firstImageView.contentMode = .scaleAspectFill
    //            secondImageView.contentMode = .scaleAspectFill
                
                firstImageView.contentMode = .scaleToFill
                secondImageView.contentMode = .scaleToFill
                
                imageDisplayView.addSubview(firstImageView)
                imageDisplayView.addSubview(secondImageView)
            }
            
            
            
        }
        
        @IBAction func OKBtnPressed(_ sender: UIButton) {
        
            self.dismiss(animated: true) {
                if self.isForFinalResult {
                    self.resultDisplayCallback!(.OK)
                }
                else {
                    self.resultDisplayCallback!(.RESCAN)
                }
            }
        }
        
        @IBAction func recaptureBtnPressed(_ sender: UIButton) {
            self.dismiss(animated: true) {
                self.resultDisplayCallback!(.RESCAN)
            }
        }
        
        @IBAction func cancelBtnPressed(_ sender: UIButton) {
            self.dismiss(animated: true) {
                self.resultDisplayCallback!(.CANCEL)
            }
        }
        
        
        
      

}

