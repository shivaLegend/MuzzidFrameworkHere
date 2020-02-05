//
//  MainViewController.swift
//  AnimalNoseBiometric
//
//  Created by Tai Nguyen on 11/4/19.
//  Copyright © 2019 Tai Nguyen. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    //MARK: -Properties
    let screenWidth = UIScreen.main.bounds.width
    let screenHeight = UIScreen.main.bounds.height
    
    
    //MARK: -Methods
    //TODO: - Call C Methods
//    func runCMethod(){
//
//        var img : [UInt8] = [
//            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
//            0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,
//            0,1,1,1,1,1,1,1,1,0,0,1,1,1,1,0,0,
//            0,0,0,1,1,1,1,0,0,0,1,1,1,1,0,0,0,
//            0,0,1,1,1,1,0,0,0,1,1,1,0,0,1,1,0,
//            0,1,1,1,0,0,1,1,0,0,0,1,1,1,0,0,0,
//            0,0,1,1,0,0,0,0,0,1,1,0,0,0,1,1,0,
//            0,0,0,0,0,0,1,1,1,1,0,0,1,1,1,1,0,
//            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
//        ]
//
//        let nWidth : UInt32 = 17
//        let nHeight : UInt32 = 9
//        var label = [UInt32](repeating: 0, count: (17*9))
//        let b8nbd : UInt8 = 1
//
//        let ncomp = getCC(&img, nWidth, nHeight, &label, b8nbd)
//        print("n8nbd=%d, ncomp=%d\n", b8nbd, ncomp);
//        //        printLabel(&label, nWidth, nHeight)
//        print("\n")
//        //
//        let compIdx : UInt32 = 2
//        var ptVec = extractBoundary(&label, nWidth, nHeight, compIdx)
//
//        for i in 0..<ptVec.nSize {
//            print(ptVec.pData![Int(i)].x)
//            print(ptVec.pData![Int(i)].y)
//        }
//
//        //        printBoundary(&label, nWidth, nHeight, ptVec);
//        freeUPoint2DVec(&ptVec)
//    }
    
    // handle notification
    @objc func handleImage(_ notification: NSNotification) {
        scrollToNextCell()
        // Post a notification
        NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: "notificationHandleImage"), object: nil, userInfo: nil)
    }
    
    func scrollToNextCell(){
        self.collectionView.isScrollEnabled = true
        
        //get cell size
        let cellSize = CGSize(width: self.screenWidth, height: self.screenHeight)
        
        //get current content Offset of the Collection view
        let contentOffset = collectionView.contentOffset
        
        //scroll to next cell
        collectionView.scrollRectToVisible(CGRect(x: contentOffset.x + cellSize.width, y: contentOffset.y, width: cellSize.width, height: cellSize.height), animated: true)
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        //        print(scrollView.contentOffset.x)
        if scrollView.contentOffset.x == self.screenWidth {
            self.collectionView.isScrollEnabled = true
        } else {
            self.collectionView.isScrollEnabled = false
        }
    }
    
    @objc func handlePanGestureInCollectionView(){
        //        print("handlePanGestureInCollectionView" + String(Date().timeIntervalSinceNow))
    }
    
    //MARK: -IBOutlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    //MARK: -LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.runCMethod()

//        testExtractBoundary01()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        //Swipe Collection View
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureInCollectionView))
        gesture.minimumNumberOfTouches = 2
        gesture.maximumNumberOfTouches = 2
        
        let gesture2 = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureInCollectionView))
        gesture2.minimumNumberOfTouches = 3
        gesture2.maximumNumberOfTouches = 3
        
        collectionView.addGestureRecognizer(gesture)
        collectionView.addGestureRecognizer(gesture2)
        
        //        self.collectionView.isScrollEnabled = false
        
        self.collectionView.register(UINib(nibName: "Item1CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Item1CollectionViewCell")
        self.collectionView.register(UINib(nibName: "Item2CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Item2CollectionViewCell")
        self.collectionView.register(UINib(nibName: "Item3CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Item3CollectionViewCell")
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleImage(_:)), name: NSNotification.Name(rawValue: "notificationHasImage"), object: nil)
        
    }
    
}

//MARK: -UICollectionView Delegate & Datasource & Flow Layout

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Item1CollectionViewCell", for: indexPath) as! Item1CollectionViewCell
            
            return cell
        } else if indexPath.row == 1 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Item2CollectionViewCell", for: indexPath) as! Item2CollectionViewCell
            cell.delegate = self
            return cell
        }
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Item3CollectionViewCell", for: indexPath) as! Item3CollectionViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.screenWidth, height: self.screenHeight)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) { // Clear old data
        if scrollView.contentOffset.x == 0 {
            globalVarFinalResult = []
            globalVarHowManyModelResult = 0
        }
        
    }
    
    
}

//MARK: -Item2Collection
extension MainViewController: Item2CollectionViewCellProtocol {
    func panCircleWork() {
        self.collectionView.isScrollEnabled = false
    }
    
    func pinchCircleWork() {
        self.collectionView.isScrollEnabled = false
        
    }
    
    func panCircleEnd() {
        self.collectionView.isScrollEnabled = true
    }
    
    func pinchCircleEnd() {
        self.collectionView.isScrollEnabled = true
    }
    
}


