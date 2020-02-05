//
//  Item3CollectionViewCell.swift
//  AnimalNoseBiometric
//
//  Created by Tai Nguyen on 11/4/19.
//  Copyright © 2019 Tai Nguyen. All rights reserved.
//

import UIKit

class Item3CollectionViewCell: UICollectionViewCell {
    // MARK: -IBOutlets
    @IBOutlet weak var imgCapture: UIImageView!
    
    // MARK: -IBActions

    // MARK: -Properties

    // MARK: -Methods
    @objc func handleImage(_ notification: NSNotification) {
        self.imgCapture.image = globalVarPhotoCaptureFullScreen
    }
    // MARK: -Life cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleImage(_:)), name: NSNotification.Name(rawValue: "notificationPassImageToItem3"), object: nil)

    }

}
