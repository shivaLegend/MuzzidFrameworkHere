//
//  UIKit.swift
//  SampleTestTensorflow
//
//  Created by Tai Nguyen on 11/26/19.
//  Copyright © 2019 Tai Nguyen. All rights reserved.
//

import UIKit

extension UIView {
    func gradientUIView(fromColor: UIColor, toColor: UIColor){
        let gradient = CAGradientLayer()
        
        gradient.frame = self.bounds
        gradient.colors = [fromColor, toColor]
        
        self.layer.insertSublayer(gradient, at: 0)
    }
}
extension TimeInterval{
    
    func convertIntervalToMilisecond() -> Int {
        
        let time = NSInteger(self)
        
        let ms = Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        //        return String(format: "%0.2d:%0.2d:%0.2d.%0.3d",hours,minutes,seconds,ms)
        return ms
        
    }
}

extension Data {
    /// Creates a new buffer by copying the buffer pointer of the given array.
    ///
    /// - Warning: The given array's element type `T` must be trivial in that it can be copied bit
    ///     for bit with no indirection or reference-counting operations; otherwise, reinterpreting
    ///     data from the resulting buffer has undefined behavior.
    /// - Parameter array: An array with elements of type `T`.
    init<T>(copyingBufferOf array: [T]) {
        self = array.withUnsafeBufferPointer(Data.init)
    }
}

extension Array {
    /// Creates a new array from the bytes of the given unsafe data.
    ///
    /// - Warning: The array's `Element` type must be trivial in that it can be copied bit for bit
    ///     with no indirection or reference-counting operations; otherwise, copying the raw bytes in
    ///     the `unsafeData`'s buffer to a new array returns an unsafe copy.
    /// - Note: Returns `nil` if `unsafeData.count` is not a multiple of
    ///     `MemoryLayout<Element>.stride`.
    /// - Parameter unsafeData: The data containing the bytes to turn into an array.
    init?(unsafeData: Data) {
        guard unsafeData.count % MemoryLayout<Element>.stride == 0 else { return nil }
        #if swift(>=5.0)
        self = unsafeData.withUnsafeBytes { .init($0.bindMemory(to: Element.self)) }
        #else
        self = unsafeData.withUnsafeBytes {
            .init(UnsafeBufferPointer<Element>(
                start: $0,
                count: unsafeData.count / MemoryLayout<Element>.stride
            ))
        }
        #endif  // swift(>=5.0)
    }
}

extension UIImage {
    
    /// Helper function to center-crop image.
    /// - Returns: Center-cropped copy of this image
    func cropToBounds(width: Double, height: Double) -> UIImage {
        
        let cgimage = self.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        // See what size is longer and create the center off of that
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        // Create a new image based on the imageRef and rotate back to the original orientation
        let image: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        return image
    }
    func cropCenter() -> UIImage? {
        let isPortrait = size.height > size.width
        let isLandscape = size.width > size.height
        let breadth = min(size.width, size.height)
        let breadthSize = CGSize(width: breadth, height: breadth)
        let breadthRect = CGRect(origin: .zero, size: breadthSize)
        
        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
        let croppingOrigin = CGPoint(
            x: isLandscape ? floor((size.width - size.height) / 2) : 0,
            y: isPortrait ? floor((size.height - size.width) / 2) : 0
        )
        guard let cgImage = cgImage?.cropping(to: CGRect(origin: croppingOrigin, size: breadthSize))
            else { return nil }
        UIImage(cgImage: cgImage).draw(in: breadthRect)
        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return croppedImage
    }
    func cropCenter(crop: CGRect) -> UIImage? {
        //       let crop = CGRect(x: 0, y: 0, width: 100, height: 100)
        guard let cgImage = cgImage?.cropping(to: crop)
            else { return nil }
        let image = UIImage(cgImage: cgImage)
        return image
    }
    func cropRect(rect: CGRect) -> UIImage? {
        guard let cgImage = cgImage?.cropping(to: rect)
            else { return nil }
        let image = UIImage(cgImage: cgImage)
        return image
    }
    func convertToGrayScale() -> UIImage {
        
        // Create image rectangle with current image width/height
        let imageRect:CGRect = CGRect(x:0, y:0, width:self.size.width, height: self.size.height)
        
        // Grayscale color space
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let width = self.size.width
        let height = self.size.height
        
        // Create bitmap content with current image size and grayscale colorspace
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        
        // Draw image into current context, with specified rectangle
        // using previously defined context (with grayscale colorspace)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.draw(self.cgImage!, in: imageRect)
        let imageRef = context!.makeImage()
        
        // Create a new UIImage object
        let newImage = UIImage(cgImage: imageRef!)
        
        return newImage
    }
    
    
    
    /// Overlay an image on top of current image with alpha component
    /// - Parameters
    ///   - alpha: Alpha component of the image to be drawn on the top of current image
    /// - Returns: The overlayed image or `nil` if the image could not be drawn.
    func overlayWithImage(image: UIImage, alpha: Float) -> UIImage? {
        let areaSize = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        
        UIGraphicsBeginImageContext(self.size)
        self.draw(in: areaSize)
        image.draw(in: areaSize, blendMode: .normal, alpha: CGFloat(alpha))
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func buffer() -> CVPixelBuffer? {
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32AlphaGray, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    func getPixelColor(pos: CGPoint) -> Float {
        
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + (Int(pos.x)))*4
        
        let val = CGFloat(data[pixelInfo]) / CGFloat(255.0)
        //        print(val)
        //        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
        //        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
        //                let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
        //        print((r + g + b) / 3)
        //        return UIColor(red: r, green: g, blue: b, alpha: a)
        return (Float(val))
    }
    
    
    
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        
        return self
    }
}

extension UIColor {
    
    // Check if the color is light or dark, as defined by the injected lightness threshold.
    // A nil value is returned if the lightness couldn't be determined.
    func isLight(threshold: Float = 0.5) -> Bool? {
        let originalCGColor = self.cgColor
        
        // Convert the color to the RGB colorspace as some color such as UIColor.white and .black
        // are grayscale.
        let RGBCGColor = originalCGColor.converted(
            to: CGColorSpaceCreateDeviceRGB(), intent: .defaultIntent, options: nil)
        
        guard let components = RGBCGColor?.components else { return nil }
        guard components.count >= 3 else { return nil }
        
        // Calculate color brightness according to Digital ITU BT.601.
        let brightness = Float(
            ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
        )
        
        return (brightness > threshold)
    }
}

