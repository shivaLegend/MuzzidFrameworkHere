//
//  Global.swift
//  AnimalNoseBiometric
//
//  Created by Tai Nguyen on 11/4/19.
//  Copyright © 2019 Tai Nguyen. All rights reserved.
//

import UIKit

var globalVarPhotoCaptureFullScreen: UIImage!
//var globalDataPhotoTflite480 = Data()
var globalResultArrayPhotoData : [Float] = []
//var globalVarTimeBeginInput : Int = 0

var globalDataPhoto = Data()
var globalVarFinalResult : [[Int]] = []
var globalVarTimeBeginInput : Int = 0
var globalVarInputAlgorithm = [[Int]]()
var globalVarArray2DResultImage = [[Int]]() // 0 or 1 value

var globalVarHowManyModelResult = 0


//TODO: -Declare 4 point we need
var globalVarXOfPointTopLeftNostril = 480
var globalVarYOfPointTopLeftNostril = 480
var globalVarXOfPointBotLeftNostril = 0
var globalVarYOfPointBotLeftNostril = 0

var globalVarXOfPointTopRightNostril = 0
var globalVarYOfPointTopRightNostril = 480
var globalVarXOfPointBotRightNostril = 480
var globalVarYOfPointBotRightNostril = 0
