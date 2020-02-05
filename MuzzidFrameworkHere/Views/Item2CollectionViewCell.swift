//
//  Item2CollectionViewCell.swift
//  AnimalNoseBiometric
//
//  Created by Tai Nguyen on 11/4/19.
//  Copyright © 2019 Tai Nguyen. All rights reserved.
//

import UIKit

protocol Item2CollectionViewCellProtocol {
    func panCircleEnd()
    func pinchCircleEnd()
    func panCircleWork()
    func pinchCircleWork()
}

class Item2CollectionViewCell: UICollectionViewCell {
    
    //MARK: -IBOutlets
    @IBOutlet weak var viewGradient: UIView!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var imgCapture: UIImageView!
    
    @IBOutlet weak var imgOverlay: UIImageView!
    //MARK: -Variables
    var delegate: Item2CollectionViewCellProtocol?
    
    var viewCircle: UIView = UIView(frame: CGRect(x: (UIScreen.main.bounds.width - 200)/2, y: (UIScreen.main.bounds.height - 200)/2, width: 200, height: 200))
    
    //MARK: -Methods
     @objc func handleResultEdge(_ notification: NSNotification) {
        print("Time " + String(globalVarTimeBeginInput) + " milisecond")
//            self.lblResult.text = String(globalVarTimeBeginInput) + " milisecond"
//                    NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "notificationPassImageToItem3"), object: nil, userInfo: nil)

            if let dict = notification.userInfo as NSDictionary? {
                if let overImage = dict["image"] as? UIImage{
                    self.imgOverlay.image = overImage
                    //                let rotateImage = overImage.rotate(radians: .pi/2)
                    //                self.imgOverlay.image = rotateImage
                    //                self.imgOverlay.transform = CGAffineTransform(scaleX: -1, y: 1)
                    
                }
            }
        }
    @objc func handleResult(_ notification: NSNotification) {
        //        self.lblResult.text = String(globalVarTimeBeginInput) + " milisecond"
//        DispatchQueue.main.async {
//            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "notificationPassImageToItem3"), object: nil, userInfo: nil)
//
//            print(String(globalVarTimeBeginInput) + " milisecond")
//            if let dict = notification.userInfo as NSDictionary? {
//                if let overImage = dict["image"] as? UIImage{
//                    let rotateImage = overImage.rotate(radians: .pi/2)
//                    self.imgOverlay.image = rotateImage
//                    self.imgOverlay.transform = CGAffineTransform(scaleX: -1, y: 1)
//
//                }
//            }
//        }
    }
    
    @objc func handleImage(_ notification: NSNotification) {
        self.imgCapture.image = globalVarPhotoCaptureFullScreen
    }
    
    @objc func userSwipedFromEdge(sender: UIScreenEdgePanGestureRecognizer) {
        if sender.state == .began || sender.state == .changed {
            let translation = sender.translation(in: self)
            // note: 'view' is optional and need to be unwrapped
            self.stackView.center = CGPoint(x: self.stackView.center.x + translation.x, y: self.stackView.center.y)
            print(self.stackView.center)
            sender.setTranslation(CGPoint.zero, in: self)
        }
    }
    
    func drawCircle(){
        let circleLayer = CAShapeLayer()
        circleLayer.path = UIBezierPath(ovalIn: viewCircle.bounds).cgPath
        circleLayer.strokeColor = UIColor.systemYellow.cgColor;
        circleLayer.fillColor = UIColor.clear.cgColor;
        circleLayer.lineWidth = 2
        self.viewCircle.layer.addSublayer(circleLayer)
    }
    
    @objc func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        if gestureRecognizer.state == .began || gestureRecognizer.state == .changed {
            self.delegate?.panCircleWork()
            let translation = gestureRecognizer.translation(in: self)
            // note: 'view' is optional and need to be unwrapped
            self.viewCircle.center = CGPoint(x: self.viewCircle.center.x + translation.x, y: self.viewCircle.center.y + translation.y)
            gestureRecognizer.setTranslation(CGPoint.zero, in: self)
        } else {
            self.delegate?.panCircleEnd()
        }
    }
    
    @objc func handlePinch(pinch: UIPinchGestureRecognizer) {
        
        if let view = pinch.view {
            self.viewCircle.transform = self.viewCircle.transform.scaledBy(x: pinch.scale, y: pinch.scale)
            pinch.scale = 1
        }
        if pinch.state == .began || pinch.state == .changed {
            self.delegate?.pinchCircleWork()
        }else {
            self.delegate?.pinchCircleEnd()
        }
    }
    
    
    
    
    //MARK: -IBAction
    @IBAction func backBtn(_ sender: Any) {
        //        self.navigationController?.popViewController(animated: true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.drawCircle()
        self.addSubview(self.viewCircle)
        self.isUserInteractionEnabled = true
       
        // Handle two-finger pans
        let pan2GestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        pan2GestureRecognizer.minimumNumberOfTouches = 2
        pan2GestureRecognizer.maximumNumberOfTouches = 2
        pan2GestureRecognizer.delegate = self
        self.addGestureRecognizer(pan2GestureRecognizer)
        
        // Handle 1-finger pans
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(_:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        panGestureRecognizer.maximumNumberOfTouches = 1
        panGestureRecognizer.delegate = self
        self.viewCircle.addGestureRecognizer(panGestureRecognizer)
        
        // Handle pinch gesture
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action:#selector(self.handlePinch(pinch:)))
        pinchGestureRecognizer.delegate = self
        self.addGestureRecognizer(pinchGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleImage(_:)), name: NSNotification.Name(rawValue: "notificationHandleImage"), object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(self.handleResult(_:)), name: NSNotification.Name(rawValue: "notificationHandleResultTFlite"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleResultEdge(_:)), name: NSNotification.Name(rawValue: "notificationEdgeImage"), object: nil)

        
    }
    
}
//MARK: -UIGestureRecognizerDelegate
extension Item2CollectionViewCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
}
