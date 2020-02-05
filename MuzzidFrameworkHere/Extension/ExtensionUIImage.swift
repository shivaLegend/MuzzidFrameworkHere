//// Copyright 2019 The TensorFlow Authors. All Rights Reserved.
////
//// Licensed under the Apache License, Version 2.0 (the "License");
//// you may not use this file except in compliance with the License.
//// You may obtain a copy of the License at
////
////    http://www.apache.org/licenses/LICENSE-2.0
////
//// Unless required by applicable law or agreed to in writing, software
//// distributed under the License is distributed on an "AS IS" BASIS,
//// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//// See the License for the specific language governing permissions and
//// limitations under the License.
//
//import UIKit
//
///// Helper functions for the UIImage class that is useful for this sample app.
//extension UIImage {
//    
//    /// Helper function to center-crop image.
//    /// - Returns: Center-cropped copy of this image
//    func cropToBounds(width: Double, height: Double) -> UIImage {
//
//        let cgimage = self.cgImage!
//        let contextImage: UIImage = UIImage(cgImage: cgimage)
//        let contextSize: CGSize = contextImage.size
//        var posX: CGFloat = 0.0
//        var posY: CGFloat = 0.0
//        var cgwidth: CGFloat = CGFloat(width)
//        var cgheight: CGFloat = CGFloat(height)
//
//        // See what size is longer and create the center off of that
//        if contextSize.width > contextSize.height {
//            posX = ((contextSize.width - contextSize.height) / 2)
//            posY = 0
//            cgwidth = contextSize.height
//            cgheight = contextSize.height
//        } else {
//            posX = 0
//            posY = ((contextSize.height - contextSize.width) / 2)
//            cgwidth = contextSize.width
//            cgheight = contextSize.width
//        }
//
//        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
//
//        // Create bitmap image from context using the rect
//        let imageRef: CGImage = cgimage.cropping(to: rect)!
//
//        // Create a new image based on the imageRef and rotate back to the original orientation
//        let image: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
//
//        return image
//    }
//    func cropCenter() -> UIImage? {
//        let isPortrait = size.height > size.width
//        let isLandscape = size.width > size.height
//        let breadth = min(size.width, size.height)
//        let breadthSize = CGSize(width: breadth, height: breadth)
//        let breadthRect = CGRect(origin: .zero, size: breadthSize)
//        
//        UIGraphicsBeginImageContextWithOptions(breadthSize, false, scale)
//        let croppingOrigin = CGPoint(
//            x: isLandscape ? floor((size.width - size.height) / 2) : 0,
//            y: isPortrait ? floor((size.height - size.width) / 2) : 0
//        )
//        guard let cgImage = cgImage?.cropping(to: CGRect(origin: croppingOrigin, size: breadthSize))
//            else { return nil }
//        UIImage(cgImage: cgImage).draw(in: breadthRect)
//        let croppedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return croppedImage
//    }
//    func cropRect(rect: CGRect) -> UIImage? {
//        guard let cgImage = cgImage?.cropping(to: rect)
//        else { return nil }
//        let image = UIImage(cgImage: cgImage)
//        return image
//    }
//    
//    
//    
//    /// Overlay an image on top of current image with alpha component
//    /// - Parameters
//    ///   - alpha: Alpha component of the image to be drawn on the top of current image
//    /// - Returns: The overlayed image or `nil` if the image could not be drawn.
//    func overlayWithImage(image: UIImage, alpha: Float) -> UIImage? {
//        let areaSize = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
//        
//        UIGraphicsBeginImageContext(self.size)
//        self.draw(in: areaSize)
//        image.draw(in: areaSize, blendMode: .normal, alpha: CGFloat(alpha))
//        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return newImage
//    }
//    
//    func resizeImage(targetSize: CGSize) -> UIImage {
//        let size = self.size
//        
//        let widthRatio  = targetSize.width  / size.width
//        let heightRatio = targetSize.height / size.height
//        
//        // Figure out what our orientation is, and use that to form the rectangle
//        var newSize: CGSize
//        if(widthRatio > heightRatio) {
//            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
//        } else {
//            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
//        }
//        
//        // This is the rect that we've calculated out and this is what is actually used below
//        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
//        
//        // Actually do the resizing to the rect using the ImageContext stuff
//        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
//        self.draw(in: rect)
//        let newImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return newImage!
//    }
//    
//        func buffer() -> CVPixelBuffer? {
//          let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
//          var pixelBuffer : CVPixelBuffer?
//    //        let t = CVPixelBufferCreate(<#T##allocator: CFAllocator?##CFAllocator?#>, <#T##width: Int##Int#>, <#T##height: Int##Int#>, , <#T##pixelBufferAttributes: CFDictionary?##CFDictionary?#>, <#T##pixelBufferOut: UnsafeMutablePointer<CVPixelBuffer?>##UnsafeMutablePointer<CVPixelBuffer?>#>)
//          let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(self.size.width), Int(self.size.height), kCVPixelFormatType_32AlphaGray, attrs, &pixelBuffer)
//          guard (status == kCVReturnSuccess) else {
//            return nil
//          }
//    
//          CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
//          let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
//    
//          let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
//          let context = CGContext(data: pixelData, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
//    
//          context?.translateBy(x: 0, y: self.size.height)
//          context?.scaleBy(x: 1.0, y: -1.0)
//    
//          UIGraphicsPushContext(context!)
//          self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
//          UIGraphicsPopContext()
//          CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
//    
//          return pixelBuffer
//        }
//    
//    func getPixelColor(pos: CGPoint) -> Float {
//        
//        let pixelData = self.cgImage!.dataProvider!.data
//        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
//        
//        let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + (Int(pos.x)))*4
//       
//        let val = CGFloat(data[pixelInfo]) / CGFloat(255.0)
////        print(val)
//        //        let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
//        //        let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
////                let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)
//        //        print((r + g + b) / 3)
//        //        return UIColor(red: r, green: g, blue: b, alpha: a)
//        return (Float(val))
//    }
//    
//    
//    
//    func rotate(radians: CGFloat) -> UIImage {
//        let rotatedSize = CGRect(origin: .zero, size: size)
//            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
//            .integral.size
//        UIGraphicsBeginImageContext(rotatedSize)
//        if let context = UIGraphicsGetCurrentContext() {
//            let origin = CGPoint(x: rotatedSize.width / 2.0,
//                                 y: rotatedSize.height / 2.0)
//            context.translateBy(x: origin.x, y: origin.y)
//            context.rotate(by: radians)
//            draw(in: CGRect(x: -origin.y, y: -origin.x,
//                            width: size.width, height: size.height))
//            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
//
//            return rotatedImage ?? self
//        }
//
//        return self
//    }
//    
//    func convertToGrayScale() -> UIImage {
//        
//        // Create image rectangle with current image width/height
//        let imageRect:CGRect = CGRect(x:0, y:0, width:self.size.width, height: self.size.height)
//        
//        // Grayscale color space
//        let colorSpace = CGColorSpaceCreateDeviceGray()
//        let width = self.size.width
//        let height = self.size.height
//        
//        // Create bitmap content with current image size and grayscale colorspace
//        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
//        
//        // Draw image into current context, with specified rectangle
//        // using previously defined context (with grayscale colorspace)
//        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
//        context?.draw(self.cgImage!, in: imageRect)
//        let imageRef = context!.makeImage()
//        
//        // Create a new UIImage object
//        let newImage = UIImage(cgImage: imageRef!)
//        
//        return newImage
//    }
//}
//
