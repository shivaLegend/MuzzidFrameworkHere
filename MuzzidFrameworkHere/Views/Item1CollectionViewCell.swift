//
//  Item1CollectionViewCell.swift
//  AnimalNoseBiometric
//
//  Created by Tai Nguyen on 11/4/19.
//  Copyright © 2019 Tai Nguyen. All rights reserved.
//

import AVFoundation
import UIKit
import MediaPlayer
import Foundation
import NVActivityIndicatorView

class Item1CollectionViewCell: UICollectionViewCell {
    
    // MARK: -IBOutlet
    @IBOutlet weak var btnCapture: UIButton!
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var viewActivity: NVActivityIndicatorView!
    @IBOutlet weak var slider: UISlider!
    
    //MARK: -Properties
    private var resultNostril: Result?
    private var resultPhiltrum: Result?
//    private var modelDataHandler: ModelDataHandler? =     ModelDataHandler(modelFileInfo: MobileNet.modelInfo, labelsFileInfo: MobileNet.labelsInfo)
    private var modelNostrilDataHandler: ModelDataHandler? =
        ModelDataHandler(modelFileInfo: MobileNet.modelNostril, labelsFileInfo: MobileNet.labelsInfo)
    private var modelPhiltrumDataHandler: ModelDataHandler? =
        ModelDataHandler(modelFileInfo: MobileNet.modelPhiltrum, labelsFileInfo: MobileNet.labelsInfo)
    let numberOfPhotoInLaplacianAlgorithm = 5
    var kernel : [[Float]] = [[1/6, 2/3, 1/6],[2/3, -10/3, 2/3], [1/6, 2/3, 1/6]]
    var countCapture = 0
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoDataOutput = AVCaptureVideoDataOutput()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var captureDevice: AVCaptureDevice!
    var didTakePhoto : Bool = false
    var countPhotoOutput = 0
    var arrayCapturePhoto : [UIImage] = []
    
    //MARK: -IBAction
    @IBAction func slider(_ sender: UISlider) {
        captureDevice.setFocusModeLocked(lensPosition: sender.value) { (time) in
            //            print(self.captureDevice.lensPosition)
        }
    }
    
    @IBAction func btnCapture(_ sender: UIButton) {
        
        //        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        //        stillImageOutput.capturePhoto(with: settings, delegate: self)
        self.didTakePhoto = true
    }
    
    //MARK: -Methods
    // Convert CIImage to CGImage
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            //               showAlertWith(title: "Save error", message: error.localizedDescription)
        } else {
            //               showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
        }
    }
    
    
    @objc func volumeChanged(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let volumeChangeType = userInfo["AVSystemController_AudioVolumeChangeReasonNotificationParameter"] as? String {
                if volumeChangeType == "ExplicitVolumeChange" {
                    // your code goes here
                    self.btnCapture(btnCapture)
                }
            }
        }
    }
    
    func runCheckLaplacianArray(){
        var maxLaplacian: Float = 0.0
        var arrayLaplacian : [Float] = []
        for image in self.arrayCapturePhoto {
            let imageWasChoose = image
            let cropCenterFor200 = imageWasChoose.cropCenter()!
            let cropFor200 = cropCenterFor200.cropRect(rect: CGRect(x: (cropCenterFor200.size.width - 200)/2, y: (cropCenterFor200.size.width - 200)/2, width: 200, height: 200))!
            let grayscale200 = cropFor200.convertToGrayScale()
            let resize200Againt = grayscale200.resizeImage(targetSize: CGSize(width: 200, height: 200)) ///We have to resize againt because if we don't, we will get the error
            var resultAfterKernel = Array(repeating: Array(repeating: Float(0), count: 198), count: 198)
            
            for x in 1..<199{
                for y in 1..<199 {
                    let summary = (resize200Againt.getPixelColor(pos: CGPoint(x: x - 1, y: y - 1))) * 255 * kernel[0][0] + (resize200Againt.getPixelColor(pos: CGPoint(x: x, y: y - 1))) * 255 * kernel[1][0] + (resize200Againt.getPixelColor(pos: CGPoint(x: x + 1, y: y - 1))) * 255 * kernel[2][0] + (resize200Againt.getPixelColor(pos: CGPoint(x: x - 1, y: y))) * 255 * kernel[0][1] + (resize200Againt.getPixelColor(pos: CGPoint(x: x , y: y))) * 255 * kernel[1][1] +
                        (resize200Againt.getPixelColor(pos: CGPoint(x: x + 1, y: y))) * 255 * kernel[2][1] +
                        (resize200Againt.getPixelColor(pos: CGPoint(x: x - 1, y: y + 1))) * 255 * kernel[0][2] +
                        (resize200Againt.getPixelColor(pos: CGPoint(x: x , y: y + 1))) * 255 * kernel[1][2] +
                        (resize200Againt.getPixelColor(pos: CGPoint(x: x + 1, y: y + 1))) * 255 * kernel[2][2]
                    let average = summary
                    
                    resultAfterKernel[x - 1][y - 1] = average*average
                }
            }
            
            let summaryOf2DArrayAfterKernel = resultAfterKernel.joined().reduce(0, +)
            //            print(summaryOf2DArrayAfterKernel/(198*198))
            arrayLaplacian.append(summaryOf2DArrayAfterKernel/(198*198))
            if summaryOf2DArrayAfterKernel/(198*198) > maxLaplacian {
                maxLaplacian = summaryOf2DArrayAfterKernel/(198*198)
            }
            
            //                            self.lblLaplacian.text = "Laplacian: " + String(summaryOf2DArrayAfterKernel/(198*198))
            
        }
//        print("maxLaplacian" + String(maxLaplacian))
        guard let indexOfMaxLaplacian = arrayLaplacian.firstIndex(of: maxLaplacian) else {return}
        
        ///Pass photo was choose by laplacian kernel to global variable
        globalVarPhotoCaptureFullScreen = arrayCapturePhoto[indexOfMaxLaplacian]
        
        ///Calculate width image to Crop
        let widthImageAfterCropOfImageFullscreen = globalVarPhotoCaptureFullScreen.size.height*(UIScreen.main.bounds.width/UIScreen.main.bounds.height)
        let newImageAfterCropTrueSizeForNostril = globalVarPhotoCaptureFullScreen.cropRect(rect: CGRect(x: (globalVarPhotoCaptureFullScreen.size.width - widthImageAfterCropOfImageFullscreen)/2, y: 0, width: widthImageAfterCropOfImageFullscreen, height: globalVarPhotoCaptureFullScreen.size.height))!
        
        DispatchQueue.main.sync {
            self.viewActivity.stopAnimating()
            // Post a notification
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "notificationHasImage"), object: nil, userInfo: nil)
        }
        
        //MARK: -Segmentation
        let tempSegmentationPhoto = newImageAfterCropTrueSizeForNostril
        let cropCenterSegmen = tempSegmentationPhoto.cropCenter()!
        let cropCenterSegmen480 = cropCenterSegmen.resizeImage(targetSize: CGSize(width: 480, height: 480))
        
        let grayScaledImageSegmen480 = cropCenterSegmen480.convertToGrayScale()
        
        DispatchQueue.main.async {
            let resizeImage = grayScaledImageSegmen480.resizeImage(targetSize: CGSize(width: 480, height: 480))
            
            var tempData = Data()
            for y in 0..<480 { //Input data follow each row
                for x in 0..<480 {
                    var val = (resizeImage.getPixelColor(pos: CGPoint(x: x, y: y)))
                    
                    let data = Data(buffer: UnsafeBufferPointer(start: &val, count: 1))
                    tempData.append(data)
                }
            }
            
            globalDataPhoto = tempData // Pass data here
            
            self.resultNostril = self.modelNostrilDataHandler?.runModel() // Run model
            self.resultPhiltrum = self.modelPhiltrumDataHandler?.runModel()
        }
        
        
        
    }
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //                        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.videoGravity = .resizeAspectFill
        
        previewView.layer.addSublayer(videoPreviewLayer)
        
        //Step12
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            //Step 13
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
    }
    
    //MARK: -Init
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //Capture Photo by Volume
        let volumeView = MPVolumeView(frame: CGRect(x: -CGFloat.greatestFiniteMagnitude, y: 0.0, width: 0.0, height: 0.0))
        self.addSubview(volumeView)
        NotificationCenter.default.addObserver(self, selector: #selector(self.volumeChanged(notification:)), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
        
        // Setup your camera here...
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let backCamera = AVCaptureDevice.default(for: .video) else {
            print("Unable to access back camera!")
            return
        }
        
        captureDevice = backCamera
        
        do {
            try captureDevice.lockForConfiguration()
        } catch {
            
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            //Next step: configure the output
            
            //Photo
            //            stillImageOutput = AVCapturePhotoOutput()
            //            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
            //                captureSession.addInput(input)
            //                captureSession.addOutput(stillImageOutput)
            //                setupLivePreview()
            //            }
            
            //Video
            let sampleBufferQueue = DispatchQueue(label: "sampleBufferQueue")
            videoDataOutput.setSampleBufferDelegate(self, queue: sampleBufferQueue)
            //            videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
            
            videoDataOutput.alwaysDiscardsLateVideoFrames = true
            videoDataOutput.videoSettings = [ String(kCVPixelBufferPixelFormatTypeKey) : kCMPixelFormat_32BGRA]
            
            if captureSession.canAddOutput(videoDataOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(videoDataOutput)
                videoDataOutput.connection(with: .video)?.videoOrientation = .portrait
                setupLivePreview()
            }
            
        } catch let error {
            print("Error unable to initalize back camera: \(error.localizedDescription)")
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //TODO: -Touch focus
        //        let screenSize = previewView.bounds.size
        //        if let touchPoint = touches.first {
        //            let x = touchPoint.location(in: previewView).y / screenSize.height
        //            let y = 1.0 - touchPoint.location(in: previewView).x / screenSize.width
        //            let focusPoint = CGPoint(x: x, y: y)
        //
        //            self.captureDevice.focusPointOfInterest = focusPoint
        //            //device.focusMode = .continuousAutoFocus
        //            self.captureDevice.focusMode = .autoFocus
        //            //device.focusMode = .locked
        //            self.captureDevice.exposurePointOfInterest = focusPoint
        //            self.captureDevice.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
        //
        //        }
    }
    
}

//MARK: -AVCapturePhotoCaptureDelegate
extension Item1CollectionViewCell: AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        
    }
    
}

extension Item1CollectionViewCell: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if didTakePhoto {
            DispatchQueue.main.async {
                self.viewActivity.startAnimating()
            }
            
            if self.countPhotoOutput >= self.numberOfPhotoInLaplacianAlgorithm {
                self.didTakePhoto = false
                self.countPhotoOutput = 0
                self.runCheckLaplacianArray()
                arrayCapturePhoto = []
                
                return
            } else {
                
                let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
                
                guard let imagePixelBuffer = pixelBuffer else {
                    return
                }
                
                let ciimage : CIImage = CIImage(cvPixelBuffer: imagePixelBuffer)
                let image : UIImage = self.convert(cmage: ciimage)
                self.countPhotoOutput = self.countPhotoOutput + 1
                
                let originLens = self.captureDevice.lensPosition
                var lens = self.captureDevice.lensPosition
                
                if self.countPhotoOutput == self.numberOfPhotoInLaplacianAlgorithm/2 {
                    lens = originLens
                } else if self.countPhotoOutput < self.numberOfPhotoInLaplacianAlgorithm/2 {
                    lens = lens + 0.05*0.8*Float(self.countPhotoOutput)
                } else {
                    lens = lens - 0.05*Float(self.countPhotoOutput - 3)*0.8
                }
                print(lens)
                
                if lens <= 0 {
                    lens = 0
                } else if lens >= 0.8 {
                    lens = 0.8
                }
                
                self.captureDevice.setFocusModeLocked(lensPosition: lens) { (time) in
                    
                }
                
                self.arrayCapturePhoto.append(image)
                
            }
            
        }
        
    }
}
