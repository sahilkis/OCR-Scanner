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

// import Foundation
import UIKit
import AVFoundation


enum Shape {
    case rectangle
    case triangle
    case circle
    case oval
}

class ImageHelper {
    
    // MARK: Image Helper Functions
    
    // Returns UInt8 byte array of input file
    static func fileToBytes( filename: String ) -> [UInt8]? {
        
        var bytes: [UInt8]?
        
        if let data = NSData(contentsOfFile: filename) {
            
            var buffer = [UInt8](repeating: 0, count: data.length)
            data.getBytes(&buffer, length: data.length)
            bytes = buffer
        }
        
        return bytes
    }
    
    // Returns UInt8 byte array of input image
    static func uiImageToCFBytes( img: UIImage ) -> [UInt8]? {
        
        // Adjust orientation
        let newCgIm = img.cgImage!.copy()
        let uiImage = UIImage(cgImage: newCgIm!)
        
        guard let cfdata = uiImage.cgImage?.dataProvider?.data,
            let _ = CFDataGetBytePtr(cfdata) else {
                return nil
        }
        
        // Convert image to byte array
        
        // Create an of Uint8
        let size = CFDataGetLength(cfdata)
        var buffer = Array<UInt8>(repeating: 0, count: size)
        
        // Copy bytes into array
        let fullRange = CFRangeMake(0, CFDataGetLength(cfdata))
        CFDataGetBytes(cfdata, fullRange, &buffer)
        
        return buffer
    }
    
    // Returns UInt8 byte array of input image
    static func uiImageToJpegBytes( img: UIImage, orientation: UIImage.Orientation ) -> [UInt8] {
        
        // Adjust orientation
        _ = img.fixImageOrientation()
        let newCgIm = img.cgImage!.copy()
        let uiImage = UIImage(cgImage: newCgIm!)
        
        // Convert image to byte array
        let data: NSData = uiImage.jpegData(compressionQuality: 1.0)! as NSData
        let count = data.length / MemoryLayout<UInt8>.size
        
        // Create an array of Uint8
        var array = [UInt8](repeating: 0, count: count)
        
        // Copy bytes into array
        data.getBytes(&array, length:count * MemoryLayout<UInt8>.size)
        
        return array
        
    }
    
    // Returns UInt8 byte array of input image
    // NOTE: quality value [0 - 1]
    static func uiImageToJpegBytes( img: UIImage, quality: CGFloat ) -> [UInt8] {
        
        // Adjust orientation
        _ = img.fixImageOrientation()
        let newCgIm = img.cgImage!.copy()
        let uiImage = UIImage(cgImage: newCgIm!)
        
        // Convert image to byte array
        let data: NSData = uiImage.jpegData(compressionQuality: quality)! as NSData
        let count = data.length / MemoryLayout<UInt8>.size
        
        // Create an array of Uint8
        var array = [UInt8](repeating: 0, count: count)
        
        // Copy bytes into array
        data.getBytes(&array, length:count * MemoryLayout<UInt8>.size)
        
        return array
        
    }
    
    // Returns UInt8 byte array of input image
    static func uiImageToPNGBytes( img: UIImage ) -> [UInt8] {
        
        // Adjust orientation
        _ = img.fixImageOrientation()!
        let newCgIm = img.cgImage!.copy()
        let uiImage = UIImage(cgImage: newCgIm!)
        
        // Convert image to byte array
        let data: NSData = uiImage.pngData()! as NSData
        let count = data.length / MemoryLayout<UInt8>.size
        
        // create an array of Uint8
        var array = [UInt8](repeating: 0, count: count)
        
        // copy bytes into array
        data.getBytes(&array, length:count * MemoryLayout<UInt8>.size)
        
        return array
        
    }
    
    static func convertUnsafePtr(length: Int, data: UnsafePointer<UInt8>) -> [UInt8] {
        
        let buffer = UnsafeBufferPointer(start: data, count: length);
        return Array(buffer)
    }

    static func sampleBufferTo32BitBuffer( sampleBuffer: CMSampleBuffer, owidth: inout Int, oheight: inout Int) -> [UInt8]? {
        
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            
            CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
            
            let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
            let width = CVPixelBufferGetWidth(imageBuffer)
            let height = CVPixelBufferGetHeight(imageBuffer)
            
            if let buf = baseAddress?.assumingMemoryBound(to: UInt8.self) {
                
                if bytesPerRow > 0 && width > 0 && height > 0 {
                    
                    // More efficient handling of buffer data to array - Do not loop
                    // through buf, rather, convert to unsafe pointer.
                    let buffer = convertUnsafePtr(length: bytesPerRow * height,
                                                  data: buf)
                    
                    CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
                    
                    owidth = width
                    oheight = height
                    
                    return buffer
                }
            }
        }
        
        return nil
    }
    
    static func sampleBufferToRBG24(sampleBuffer: CMSampleBuffer, owidth: inout Int, oheight: inout Int) -> [UInt8] {
        
        var wd = 0
        var ht = 0
        let bitmapInfo1 = CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue).union(.byteOrder32Little)
        
        let (buf1, _) = ImageHelper.sampleBufferToUIImage(
            sampleBuffer: sampleBuffer,
            bitmapInfo: bitmapInfo1,
            owidth: &wd,
            oheight: &ht)
        
        owidth = wd
        oheight = ht
        
        // Swap R and B channels, and skip alpha
        let n = 4
        let newCount0 = buf1!.count - buf1!.count/n
        var newBuffer0 = Array<UInt8>(repeating: 0, count: newCount0)
        for idx in stride(from: 0, to: newCount0, by: 3) {
            newBuffer0[idx] = buf1![idx + idx/(n - 1) + 2]
            newBuffer0[idx + 1] = buf1![idx + idx/(n - 1) + 1]
            newBuffer0[idx + 2] = buf1![idx + idx/(n - 1)]
        }
        
        return newBuffer0
    }
    
    static func sampleBufferToUIImage( sampleBuffer: CMSampleBuffer, bitmapInfo: CGBitmapInfo, owidth: inout Int, oheight: inout Int) -> ([UInt8]?, UIImage?) {
        
        if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            
            CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
            
            let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
            let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
            let width = CVPixelBufferGetWidth(imageBuffer)
            let height = CVPixelBufferGetHeight(imageBuffer)
            
            if let buf = baseAddress?.assumingMemoryBound(to: UInt8.self) {
                
                if bytesPerRow > 0 && width > 0 && height > 0 {
                    
                    // More efficient handling of buffer data to array - Do not loop
                    // through buf, rather, convert to unsafe pointer.
                    let buffer = convertUnsafePtr(length: bytesPerRow * height,
                                                  data: buf)
                    
                    CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: 0))
                    
                    owidth = width
                    oheight = height
                    
                    // Decode buffer - Create a new colorspace
                    let cs = CGColorSpaceCreateDeviceRGB()
                    
                    // Create new context from buffer
                    let context1 = CGContext(
                        data: baseAddress,
                        width: width,
                        height: height,
                        bitsPerComponent: 8,
                        bytesPerRow: bytesPerRow,
                        space: cs,
                        bitmapInfo: bitmapInfo.rawValue)
                    
                    // Get the image from the context
                    let cgImage = context1?.makeImage()
                    let cgImageSize = CFDataGetLength(cgImage?.dataProvider?.data)
                    
                    let uiImage = UIImage(cgImage: cgImage!)
                    
                    print("cgImageSize: \(cgImageSize), uiImage size: \(CFDataGetLength(uiImage.cgImage?.dataProvider?.data))")
                    
                    return (buffer, uiImage)
                }
            }
        }
        
        return (nil, nil)
    }
    
    static func sampleBufferToUIImage(sampleBuffer: CMSampleBuffer) -> UIImage {
        
        // Get a pixel buffer from the sample buffer
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)! as CVPixelBuffer
        
        // Lock the base address
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        // Prepare to decode buffer
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue).union(.byteOrder32Little)

        // Decode buffer - Create a new colorspace
        let cs = CGColorSpaceCreateDeviceRGB()
        
        let baseAddress = CVPixelBufferGetBaseAddress(pixelBuffer)
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)

        // Image from orig - 32 bit
        
        // Create new context from buffer
        let context = CGContext(
            data: baseAddress,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: cs,
            bitmapInfo: bitmapInfo.rawValue)
        
        // Get the image from the context
        let cgImage = context?.makeImage()

        // Convert it to UIImage
        let uiImage = UIImage(cgImage: cgImage!)
        
        // Unlock and return image
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        return uiImage
    }

    // Returns image type, {jpeg, png, gif, tiff, bmp}
    // of input image.
    
    
    static func contentTypeForImageData(uiImage : UIImage) -> String?
    {
        let data: NSData = uiImage.pngData()! as NSData
        var c = [UInt8](repeating: 0, count: 1)
        _ = data.getBytes( &c, length: 1)

        return contentTypeForImageData(byte: c[0])
    }
    
    static func contentTypeForImageData(byte : UInt8) -> String?
    {
        switch (byte) {   // c[0]) {
        case 0xFF:
            return "image/jpeg"
        case 0x89:
            return "image/png"
        case 0x47:
            return "image/gif"
        case 0x49:
            return "image/tiff"
        case 0x4D:
            return "image/tiff"
        case 0x42:
            return "@image/bmp"
        default:
            return nil
        }
    }
    
}

internal extension UIImage {
    
    
    // Resize a given image
    func convert(toSize size:CGSize, scale:CGFloat) ->UIImage
    {
        let imgRect = CGRect(origin: CGPoint(x:0.0, y:0.0), size: size)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        self.draw(in: imgRect)
        let copied = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return copied!
    }
    
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func imageWithSize(_ size: CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero
        
        let aspectWidth: CGFloat = size.width / self.size.width
        let aspectHeight: CGFloat = size.height / self.size.height
        let aspectRatio: CGFloat = min(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        self.draw(in: scaledImageRect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    func rotateImage90() -> UIImage {
        
        //Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox: UIView =
            UIView(frame: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))

        let t: CGAffineTransform = CGAffineTransform(rotationAngle: CGFloat.pi / 2)
        
        rotatedViewBox.transform = t
        let rotatedSize: CGSize = rotatedViewBox.frame.size
        
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap: CGContext = UIGraphicsGetCurrentContext()!
        
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        bitmap.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
        
        //Rotate the image context
        bitmap.rotate(by: (CGFloat.pi / 2))
        
        //Now, draw the rotated/scaled image into the context
        bitmap.scaleBy(x: 1.0, y: -1.0)
        
        bitmap.draw(
            self.cgImage!,
            in: CGRect(
                x: -self.size.width / 2,
                y: -self.size.height / 2,
                width: self.size.width,
                height: self.size.height))
        
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func fixImageOrientation() -> UIImage? {
        var flip:Bool = false //used to see if the image is mirrored
        var isRotatedBy90:Bool = false // used to check whether aspect ratio is to be changed or not
        
        var transform = CGAffineTransform.identity
        
        //check current orientation of original image
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.rotated(by: CGFloat(Double.pi))
            
        case .left, .leftMirrored:
            transform = transform.rotated(by: CGFloat(Double.pi/2))
            isRotatedBy90 = true
        case .right, .rightMirrored:
            transform = transform.rotated(by: CGFloat(-Double.pi/2))
            isRotatedBy90 = true
        case .up, .upMirrored:
            break
        }
        
        switch self.imageOrientation {
            
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            flip = true
            
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            flip = true
        default:
            break;
        }
        
        // Calculate the size of the rotated view's containing box for our drawing space
        let rotatedViewBox = UIView(frame: CGRect(origin: CGPoint(x:0, y:0), size: self.size))
        rotatedViewBox.transform = transform
        let rotatedSize = rotatedViewBox.frame.size
        
        // Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize)
        let bitmap = UIGraphicsGetCurrentContext()
        
        // Move the origin to the middle of the image so we will rotate and 
        // scale around the center.
        bitmap!.translateBy(x: rotatedSize.width / 2.0, y: rotatedSize.height / 2.0)
        
        // Now, draw the rotated/scaled image into the context
        var yFlip: CGFloat
        
        if(flip){
            yFlip = CGFloat(-1.0)
        } else {
            yFlip = CGFloat(1.0)
        }
        
        bitmap!.scaleBy(x: yFlip, y: -1.0)
        
        //check if we have to fix the aspect ratio
        if isRotatedBy90 {
            bitmap?.draw(
                self.cgImage!,
                in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.height,height: size.width))
        } else {
            bitmap?.draw(
                self.cgImage!,
                in: CGRect(x: -size.width / 2, y: -size.height / 2, width: size.width,height: size.height))
        }
        
        let fixedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return fixedImage
    }
}

internal extension UIButton {
    // Aware Buttons, ref: 6/13/2017 email Danica.
    // Gradient blue:
    //     0x 4C 9F E2 : 76 159 226
    //     0x 2E 73 C5 : 46 115 197
    func setGradientBackground() -> Void {
        
        // Blue gradient
        let colorTop =  UIColor(red: 76.0/255.0, green: 159.0/255.0, blue: 226.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 46.0/255.0, green: 115.0/255.0, blue: 197.0/255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setGradientBackground(cornerRadius: CGFloat) -> Void {
        let colorTop =  UIColor(red: 76.0/255.0, green: 159.0/255.0, blue: 226.0/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 46.0/255.0, green: 115.0/255.0, blue: 197.0/255.0, alpha: 1.0).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
        
        gradientLayer.cornerRadius = cornerRadius
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    func setGradientBackgroundGray() -> Void {
        
        // Gray gradient
        let colorTop =  UIColor.lightGray.cgColor
        let colorBottom = UIColor.lightGray.cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }

    func setGradientBackgroundGray(cornerRadius: CGFloat) -> Void {
        
        // Gray gradient
        let colorTop =  UIColor.lightGray.cgColor
        let colorBottom = UIColor.lightGray.cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
        
        gradientLayer.cornerRadius = cornerRadius

        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

internal extension CAShapeLayer
{
    func drawShapeMaskLayer(boundingViewBox: CGRect, shape: Shape, boundingBox:CGRect)
    {
        let fillColor = UIColor.darkGray.cgColor
        let strokeColor = UIColor.red.cgColor
        drawShapeMaskLayer(boundingViewBox: boundingViewBox, shape: shape, boundingBox: boundingBox, fillColor: fillColor, strokeColor: strokeColor)
    }
    
    func drawShapeMaskLayer(boundingViewBox: CGRect, shape: Shape, boundingBox: CGRect, fillColor: CGColor, strokeColor: CGColor)
    {
        var viewPath = UIBezierPath()
        viewPath = UIBezierPath(rect: boundingViewBox)
        
        let shapePath = silhouetteOvalPath(boundingBox: boundingBox)
        // NOTE: Competing silhouette
        // let shapePath = silhouetteBezierPath(boundingBox: boundingBox)
        
        // Add shapePath to viewPath
        viewPath.append(shapePath)
        
        self.path = viewPath.cgPath
        self.fillRule = CAShapeLayerFillRule.evenOdd
        self.fillColor = fillColor
        self.strokeColor = strokeColor
        self.lineWidth = 2
        self.opacity = 0.8
    }
    
    func silhouetteOvalPath(boundingBox: CGRect) -> UIBezierPath {
        return silhouetteShapePath(boundingBox: boundingBox, shape: Shape.oval)
    }
    
    func silhouetteShapePath(boundingBox: CGRect, shape: Shape) -> UIBezierPath {
        // Create cut out geometry
        let yShapeTop = boundingBox.minY
        let yShapeBottom = boundingBox.maxY
        let xShapeLeft = boundingBox.minX
        let xShapeRight = boundingBox.maxX
        let circleShapeRadius = (boundingBox.maxY - boundingBox.minY) / 2
        let xShapeCtr = (boundingBox.maxX - boundingBox.minX) / 2 + xShapeLeft
        let yShapeCtr = (boundingBox.maxY - boundingBox.minY) / 2 + yShapeTop
        let xCircleLeft = xShapeCtr - circleShapeRadius
        let yCircleTop = yShapeCtr - circleShapeRadius
        
        var shapePath = UIBezierPath()
        
        switch (shape)
        {
        case Shape.rectangle:
            shapePath = UIBezierPath(rect: boundingBox)
        case Shape.triangle:
            shapePath.addLine(to: CGPoint(x: (xShapeLeft + xShapeRight) / 2, y: yShapeTop))
            shapePath.addLine(to: CGPoint(x: xShapeLeft, y: yShapeBottom))
            shapePath.addLine(to: CGPoint(x: xShapeRight, y: yShapeBottom))
        case Shape.circle:
            shapePath = UIBezierPath(rect: CGRect(x: xCircleLeft, y: yCircleTop, width: 2 * circleShapeRadius, height: 2 * circleShapeRadius))
        case Shape.oval:
            shapePath = UIBezierPath(ovalIn: boundingBox)
        }
        
        return shapePath
    }
    
    func silhouetteBezierPath(boundingBox: CGRect) -> UIBezierPath {
        let height = boundingBox.height
        let width = boundingBox.width
        let xOffset = boundingBox.origin.x
        let yOffset = boundingBox.origin.y
        
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: CGPoint(x: CGFloat(0.0 + width/32 + xOffset) , y: CGFloat(height/3 + height/8 + yOffset)))
        
        // Top of head
        bezierPath.addCurve(
            to: CGPoint(x: width - width/32 + xOffset, y: height/3 + height/8 + yOffset),
            controlPoint1: CGPoint(x: CGFloat(width/16 + xOffset), y: CGFloat(0.0 + yOffset)),
            controlPoint2: CGPoint(x: CGFloat(15*width/16 + xOffset), y: CGFloat(0.0 + yOffset)))
        
        // Right ear
//        bezierPath.addLine(
//            to: CGPoint(x: width - width/32 + xOffset, y: height/3 + height/8 + yOffset))
        bezierPath.addCurve(
            to: CGPoint(x: width - width/8 + xOffset, y: 3*height/4 - height/16 + yOffset),
            controlPoint1: CGPoint(x: CGFloat(width + width/8 + xOffset), y: CGFloat(height/3 + height/8 + yOffset)),
            controlPoint2: CGPoint(x: CGFloat(width + xOffset), y: CGFloat(3*height/4 - height/16 + yOffset)))
        
        
        // Bottom, chin
        bezierPath.addCurve(
            to: CGPoint(x: CGFloat(width/8 + xOffset), y: CGFloat(3*height/4 - height/16 + yOffset)),
            controlPoint1: CGPoint(x: CGFloat(3*width/4 + xOffset), y: CGFloat(height + yOffset)),
            controlPoint2: CGPoint(x: CGFloat(width/4 + xOffset), y: CGFloat(height + yOffset)))
        
        // Left ear
        bezierPath.addCurve(
            to: CGPoint(x: width/32 + xOffset, y: height/3 + height/8 + yOffset),
            controlPoint1: CGPoint(x: CGFloat(0 + xOffset), y: CGFloat(3*height/4 - height/16 + yOffset)),
            controlPoint2: CGPoint(x: CGFloat(-1 * width/8 + xOffset), y: CGFloat(height/3 + height/8 + yOffset)))
//        bezierPath.addLine(
//            to: CGPoint(x: 0 + xOffset, y: height/3 + yOffset))
        
        return bezierPath
    }
    
    func silhouetteBezierPath_Orig(boundingbox: CGRect) -> UIBezierPath {
        let height = boundingbox.height
        let width = boundingbox.width
        let xOffset = boundingbox.origin.x
        let yOffset = boundingbox.origin.y
        
        let bezierPath = UIBezierPath()
        
        bezierPath.move(to: CGPoint(x: CGFloat(0.0 + xOffset) , y: CGFloat(height/3 + yOffset)))
        
        // Top of head
        bezierPath.addCurve(
            to: CGPoint(x: width + xOffset, y: height/3 + yOffset),
            controlPoint1: CGPoint(x: CGFloat(width/8 + xOffset), y: CGFloat(0.0 + yOffset)),
            controlPoint2: CGPoint(x: CGFloat(7*width/8 + xOffset), y: CGFloat(0.0 + yOffset)))
        
        // Right ear
        bezierPath.addLine(
            to: CGPoint(x: width - width/32 + xOffset, y: height/3 + height/8 + yOffset))
        bezierPath.addCurve(
            to: CGPoint(x: width - width/8 + xOffset, y: 3*height/4 - height/16 + yOffset),
            controlPoint1: CGPoint(x: CGFloat(width + width/8 + xOffset), y: CGFloat(height/3 + height/8 + yOffset)),
            controlPoint2: CGPoint(x: CGFloat(width + xOffset), y: CGFloat(3*height/4 - height/16 + yOffset)))
        
        
        // Bottom, chin
        bezierPath.addCurve(
            to: CGPoint(x: CGFloat(width/8 + xOffset), y: CGFloat(3*height/4 - height/16 + yOffset)),
            controlPoint1: CGPoint(x: CGFloat(2*width/3 + xOffset), y: CGFloat(height + yOffset)),
            controlPoint2: CGPoint(x: CGFloat(width/3 + xOffset), y: CGFloat(height + yOffset)))
        
        // Left ear
        bezierPath.addCurve(
            to: CGPoint(x: width/32 + xOffset, y: height/3 + height/8 + yOffset),
            controlPoint1: CGPoint(x: CGFloat(0 + xOffset), y: CGFloat(3*height/4 - height/16 + yOffset)),
            controlPoint2: CGPoint(x: CGFloat(-1 * width/8 + xOffset), y: CGFloat(height/3 + height/8 + yOffset)))
        bezierPath.addLine(
            to: CGPoint(x: 0 + xOffset, y: height/3 + yOffset))
        
        return bezierPath
    }
    
}

