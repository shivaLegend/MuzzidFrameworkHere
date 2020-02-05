// Copyright 2019 The TensorFlow Authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import CoreImage
import TensorFlowLite
import UIKit

/// A result from invoking the `Interpreter`.
struct Result {
    let inferenceTime: Double
    let inferences: [Inference]
}

/// An inference from invoking the `Interpreter`.
struct Inference {
    let confidence: Float
    let label: String
}

/// Information about a model file or labels file.
typealias FileInfo = (name: String, extension: String)

/// Information about the MobileNet model.
enum MobileNet {
    static let modelNostril: FileInfo = (name: "nostril_graph", extension: "tflite")
    static let modelPhiltrum: FileInfo = (name: "philtrum_graph", extension: "tflite")
    static let labelsInfo: FileInfo = (name: "labels", extension: "txt")
}


/// This class handles all data preprocessing and makes calls to run inference on a given frame
/// by invoking the `Interpreter`. It then formats the inferences obtained and returns the top N
/// results for a successful inference.
class ModelDataHandler {
    
    // MARK: - Internal Properties
    
    /// The current thread count used by the TensorFlow Lite Interpreter.
    let threadCount: Int
    
    let resultCount = 3
    let threadCountLimit = 10
    
    // MARK: - Model Parameters
    
    let batchSize = 1
    let inputChannels = 3
    let inputWidth = 480
    let inputHeight = 480
    
    // MARK: - Private Properties
    
    /// List of labels from the given labels file.
    private var labels: [String] = []
    
    /// TensorFlow Lite `Interpreter` object for performing inference on a given model.
    private var interpreter: Interpreter
    
    /// Information about the alpha component in RGBA data.
    private let alphaComponent = (baseOffset: 4, moduloRemainder: 3)
    
    // MARK: - Initialization
    
    /// A failable initializer for `ModelDataHandler`. A new instance is created if the model and
    /// labels files are successfully loaded from the app's main bundle. Default `threadCount` is 1.
    init?(modelFileInfo: FileInfo, labelsFileInfo: FileInfo, threadCount: Int = 1) {
        let modelFilename = modelFileInfo.name
        
        // Construct the path to the model file.
        guard let modelPath = Bundle.main.path(
            forResource: modelFilename,
            ofType: modelFileInfo.extension
            ) else {
                print("Failed to load the model file with name: \(modelFilename).")
                return nil
        }
        
        // Specify the options for the `Interpreter`.
        self.threadCount = threadCount
        var options = InterpreterOptions()
        options.threadCount = threadCount
        do {
            // Create the `Interpreter`.
            interpreter = try Interpreter(modelPath: modelPath, options: options)
            // Allocate memory for the model's input `Tensor`s.
            try interpreter.allocateTensors()
        } catch let error {
            print("Failed to create the interpreter with error: \(error.localizedDescription)")
            return nil
        }
        // Load the classes listed in the labels file.
        loadLabels(fileInfo: labelsFileInfo)
    }
    
    //MARK: -Algorithm ( Write By Tai, Not use because we have C Methods )
    var indexOfComponent = -1
    
    var visited = Array(repeating: Array(repeating: Bool(0), count: 500), count: 500)
    
    var resultAlgorithm : [[[Int:Int]]] = []
    
    func isSafe(array: [[Int]], row: Int, col: Int, c: Int, n: Int, l: Int) -> Bool {
        return (row >= 0 && row < n)
            && (col >= 0 && col < l)
            && (array[row][col] == c && !visited[row][col])
    }
    
    func isPointAtEdge(array: [[Int]],x: Int, y: Int) -> Bool{
        if ((array[x][y] == 1) && (array[x - 1][y - 1] == 1 && array[x][y - 1] == 1 && array[x + 1][y - 1] == 1 && array[x - 1][y] == 1 && array[x + 1][y] == 1 && array[x - 1][y + 1] == 1 && array[x][y + 1] == 1 && array[x + 1][y + 1] == 1 )){
            return false
        }
        return true
    }
    
    func DFS(M: [[Int]], row: Int, col: Int, c: Int, n: Int, l: Int) {
        
        let rowNbr = [-1,1,0,0,-1,1,1,-1]
        let colNbr = [0,0,1,-1,-1,-1,1,1]
        
        visited[row][col] = true
        
        resultAlgorithm[indexOfComponent].append([col : row])
        for k in 0..<8 {
            if (isSafe(array: M, row: row + rowNbr[k], col: col + colNbr[k], c: c, n: n, l: l) && isPointAtEdge(array: M, x: row + rowNbr[k], y: col + colNbr[k])) {
                DFS(M: M, row: row + rowNbr[k], col: col + colNbr[k], c: c, n: n, l: l)
            }
        }
    }
    
    func connectedComponents(array: [[Int]], n: Int) -> Int{
        var connectedComp = 0
        let l = array[0].count
        
        for i in 0..<n {
            for j in 0..<l {
                if ((!visited[i][j]) && (array[i][j] == 1)){
                    if isPointAtEdge(array: array, x: i, y: j) {
                        print("New result element")
                        self.resultAlgorithm.append([])
                        self.indexOfComponent = self.indexOfComponent + 1
                        DFS(M: array, row: i, col: j, c: 1, n: n, l: l)
                        connectedComp = connectedComp + 1
                    }
                    
                }
            }
        }
        
        return connectedComp
    }
    
    func findEdgeConnectedComponent(array: [[Int]]){
        
        var indexOfNostrilLeft = 0
        var indexOfNostrilRight = 0
        var minXOfLeftNostril = 480
        var maxXOfRightNostril = 0
        
        let n = 480
//        let numberComponent = (connectedComponents(array: array, n: n))
        
        var newOverImageEdge = Array(repeating: Array(repeating: Int(0), count: 480), count: 480)
        for indexOfResultAlgorithm in 0..<self.resultAlgorithm.count{
            for t in self.resultAlgorithm[indexOfResultAlgorithm] {
                for (key,value) in t {
                    newOverImageEdge[key][value] = 1
                    if key < minXOfLeftNostril {
                        minXOfLeftNostril = key
                        indexOfNostrilLeft = indexOfResultAlgorithm
                    }
                    
                    if key > maxXOfRightNostril {
                        maxXOfRightNostril = key
                        indexOfNostrilRight = indexOfResultAlgorithm
                    }
                }
            }
        }
        
        if self.resultAlgorithm.count > 0 {
            //Left nostril
            
            for t in self.resultAlgorithm[indexOfNostrilLeft] {
                if t.values.first! < globalVarYOfPointTopLeftNostril {
                    globalVarYOfPointTopLeftNostril = t.values.first!
                    globalVarXOfPointTopLeftNostril = t.keys.first!
                }
                if t.keys.first! > globalVarXOfPointBotLeftNostril {
                    globalVarXOfPointBotLeftNostril = t.keys.first!
                    globalVarYOfPointBotLeftNostril = t.values.first!
                }
            }
            
            //Right nostril
            for t in self.resultAlgorithm[indexOfNostrilRight]{
                if t.values.first! < globalVarYOfPointTopRightNostril {
                    globalVarYOfPointTopRightNostril = t.values.first!
                    globalVarXOfPointTopRightNostril = t.keys.first!
                }
                if t.keys.first! < globalVarXOfPointBotRightNostril {
                    globalVarXOfPointBotRightNostril = t.keys.first!
                    globalVarYOfPointBotRightNostril = t.values.first!
                }
            }
        }
        
        
        //MARK: - Draw edge of nostril
        var pixels : [PixelData] = []
        
        for j in 0..<480 {
            for i in 0..<480 {
                if newOverImageEdge[i][j] == 1 {
                    let pixel = PixelData(a: 0, r: 0, g: 255, b: 0)
                    pixels.append(pixel)
                } else { //Not in connected component
                    let pixel = PixelData(a: 0, r: 0, g: 0, b: 0)
                    pixels.append(pixel)
                }
            }
        }
        
        let image = imageFromARGB32Bitmap(pixels: pixels, width: 480, height: 480)
        
        let imageDataDict:[String: UIImage] = ["image": image!]
        // post a notification
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationEdgeImage"), object: nil, userInfo: imageDataDict)
        
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationFourPoint"), object: nil, userInfo: imageDataDict)
        
    }
    
    // MARK: - Methods
    
    /// Performs image preprocessing, invokes the `Interpreter`, and processes the inference results.
    func runModel() -> Result? {
        //    onFrame pixelBuffer: CVPixelBuffer: Paramater
        //    let sourcePixelFormat = CVPixelBufferGetPixelFormatType(pixelBuffer)
        //    assert(sourcePixelFormat == kCVPixelFormatType_32ARGB ||
        //             sourcePixelFormat == kCVPixelFormatType_32BGRA ||
        //               sourcePixelFormat == kCVPixelFormatType_32RGBA)
        
        
        let imageChannels = 4
        assert(imageChannels >= inputChannels)
        
        // Crops the image to the biggest square in the center and scales it down to model dimensions.
        //        let scaledSize = CGSize(width: inputWidth, height: inputHeight)
        //    guard let thumbnailPixelBuffer = pixelBuffer.centerThumbnail(ofSize: scaledSize) else {
        //      return nil
        //    }
        
        let interval: TimeInterval
        let outputTensor: Tensor
        do {
            //            let inputTensor = try interpreter.input(at: 0)
            let rgbData = globalDataPhoto
            
            // Remove the alpha component from the image buffer to get the RGB data.
            //      guard let rgbData = rgbDataFromBuffer(
            //        thumbnailPixelBuffer,
            //        byteCount: batchSize * inputWidth * inputHeight * inputChannels,
            //        isModelQuantized: inputTensor.dataType == .uInt8
            //      ) else {
            //        print("Failed to convert the image buffer to RGB data.")
            //        return nil
            //      }
            
            // Copy the RGB data to the input `Tensor`.
            try interpreter.copy(rgbData, toInputAt: 0)
            
            // Run inference by invoking the `Interpreter`.
            let startDate = Date()
            try interpreter.invoke()
            interval = Date().timeIntervalSince(startDate) * 1000
            
            // Get the output `Tensor` to process the inference results.
            outputTensor = try interpreter.output(at: 0)
            let timeIntervalHandle = Date().timeIntervalSince(startDate)
            globalVarTimeBeginInput = timeIntervalHandle.convertIntervalToMilisecond()
            
        } catch let error {
            print("Failed to invoke the interpreter with error: \(error.localizedDescription)")
            return nil
        }
        
        let results: [Float]
        switch outputTensor.dataType {
        case .uInt8:
            guard let quantization = outputTensor.quantizationParameters else {
                print("No results returned because the quantization values for the output tensor are nil.")
                return nil
            }
            let quantizedResults = [UInt8](outputTensor.data)
            results = quantizedResults.map {
                quantization.scale * Float(Int($0) - quantization.zeroPoint)
            }
        case .float32:
            results = [Float32](unsafeData: outputTensor.data) ?? []
            
            globalVarHowManyModelResult = globalVarHowManyModelResult + 1
            //MARK: -Algorithm take edge
            //Parse one dimension array to two dimension array
            var cookies = [[Int]]()
            if globalVarHowManyModelResult == 1 {
                var i = 0
                for _ in 0..<480 {
                    var row = [Int]()
                    for _ in 0..<480 {
                        if results[i] > 0.7 {
                            row.append(1)
                        } else {
                            row.append(0)
                        }
                        i = i + 1
                    }
                    cookies.append(row)
                }
                globalVarFinalResult = cookies
            } else if globalVarHowManyModelResult == 2 {
                var i = 0
                for x in 0..<480 {
                    for y in 0..<480 {
                        if results[i] > 0.7 { // Add new 1 into globalVarFirstResult
                            globalVarFinalResult[x][y] = 1
                        }
                        i = i + 1
                    }
                }
            }
            
            if globalVarHowManyModelResult == 2 {
                self.findEdgeConnectedComponent(array: globalVarFinalResult)
                
                var img: [UInt8] = Array(repeating: 0, count: 480*480)
                var indexOfImg = 0
                for i in 0..<globalVarFinalResult.count {
                    for j in 0..<globalVarFinalResult.count {
                        img[indexOfImg] = UInt8(globalVarFinalResult[i][j])
                        indexOfImg = indexOfImg + 1
                    }
                }
//                print(img)
                self.extractBoundaryCMethod(img: &img)
            }
            
        default:
            print("Output tensor data type \(outputTensor.dataType) is unsupported for this example app.")
            return nil
        }
        
        // Process the results.
        let topNInferences = getTopN(results: results)
        
        // Return the inference time and inference results.
        return Result(inferenceTime: interval, inferences: topNInferences)
    }
    
    //TODO: - Call C Methods
    func extractBoundaryCMethod(img: inout [UInt8]){
        
        let nWidth : UInt32 = 480
        let nHeight : UInt32 = 480
        var label = [UInt32](repeating: 0, count: (480*480))
        let b8nbd : UInt8 = 1
        
        let ncomp = getCC(&img, nWidth, nHeight, &label, b8nbd)
        print("n8nbd=%d, ncomp=%d\n", b8nbd, ncomp);
        //        printLabel(&label, nWidth, nHeight)
        print("\n")
        
        var arrayPtVec : [UPoint2DVec] = []
        for i in 1..<(ncomp + 1 ){
            let ptVec = extractBoundary(&label, nWidth, nHeight, i)
            arrayPtVec.append(ptVec)
        }
        
//        for i in 0..<(ncomp) {
//            print(arrayPtVec[Int(i)].nSize)
//        }
//
        ///Take 3 biggest component by sort array, then we get 3 first element in sort array 0,1,2
        let sortArrayPtVec = arrayPtVec.sorted { (x1, x2) -> Bool in
            x1.nSize > x2.nSize
        }
        
        
        
        
        
//        print(ptVec)
//        for i in 0..<ptVec.nSize {
//            print(ptVec.pData![Int(i)].x)
//            print(ptVec.pData![Int(i)].y)
//        }
        
        //MARK: - Draw edge of nostril

        let pixel = PixelData(a: 0, r: 0, g: 0, b: 0)
        var pixels : [PixelData] = Array(repeating: pixel, count: 480*480)
        
        ///Just using three biggest element component
        if sortArrayPtVec.count >= 3 {
            for i in 0..<3 {
                let ptVec = sortArrayPtVec[i]
                for j in 0..<ptVec.nSize {
                    let x = ptVec.pData![Int(j)].x
                    let y = ptVec.pData![Int(j)].y
                    let pixel = PixelData(a: 0, r: 0, g: 255, b: 0)
                    pixels[Int(480*y + x)] = pixel

                }
            }
        } else {
            for i in 0..<sortArrayPtVec.count { // If less then 3, just take sortArrayPtVec.count
                let ptVec = sortArrayPtVec[i]
                for j in 0..<ptVec.nSize {
                    let x = ptVec.pData![Int(j)].x
                    let y = ptVec.pData![Int(j)].y
                    let pixel = PixelData(a: 0, r: 0, g: 255, b: 0)
                    pixels[Int(480*y + x)] = pixel

                }
            }
        }
        
        
//        for j in 0..<480 {
//            for i in 0..<480 {
//                if newOverImageBoundary[i][j] == 1 {
//                    let pixel = PixelData(a: 0, r: 0, g: 255, b: 0)
//                    pixels.append(pixel)
//                } else { //Not in connected component
//                    let pixel = PixelData(a: 0, r: 0, g: 0, b: 0)
//                    pixels.append(pixel)
//                }
//            }
//        }
        
        let image = imageFromARGB32Bitmap(pixels: pixels, width: 480, height: 480)
        
        let imageDataDict:[String: UIImage] = ["image": image!]
        // post a notification
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationEdgeImage"), object: nil, userInfo: imageDataDict)
        
        //        printBoundary(&label, nWidth, nHeight, ptVec);
        freeUPoint2DVec(&arrayPtVec)
    }
    
    // MARK: - Private Methods
    
    /// Returns the top N inference results sorted in descending order.
    private func getTopN(results: [Float]) -> [Inference] {
        // Create a zipped array of tuples [(labelIndex: Int, confidence: Float)].
        let zippedResults = zip(labels.indices, results)
        
        // Sort the zipped results by confidence value in descending order.
        let sortedResults = zippedResults.sorted { $0.1 > $1.1 }.prefix(resultCount)
        
        // Return the `Inference` results.
        return sortedResults.map { result in Inference(confidence: result.1, label: labels[result.0]) }
    }
    
    /// Loads the labels from the labels file and stores them in the `labels` property.
    private func loadLabels(fileInfo: FileInfo) {
        let filename = fileInfo.name
        let fileExtension = fileInfo.extension
        guard let fileURL = Bundle.main.url(forResource: filename, withExtension: fileExtension) else {
            fatalError("Labels file not found in bundle. Please add a labels file with name " +
                "\(filename).\(fileExtension) and try again.")
        }
        do {
            let contents = try String(contentsOf: fileURL, encoding: .utf8)
            labels = contents.components(separatedBy: .newlines)
        } catch {
            fatalError("Labels file named \(filename).\(fileExtension) cannot be read. Please add a " +
                "valid labels file and try again.")
        }
    }
    
    /// Returns the RGB data representation of the given image buffer with the specified `byteCount`.
    ///
    /// - Parameters
    ///   - buffer: The pixel buffer to convert to RGB data.
    ///   - byteCount: The expected byte count for the RGB data calculated using the values that the
    ///       model was trained on: `batchSize * imageWidth * imageHeight * componentsCount`.
    ///   - isModelQuantized: Whether the model is quantized (i.e. fixed point values rather than
    ///       floating point values).
    /// - Returns: The RGB data representation of the image buffer or `nil` if the buffer could not be
    ///     converted.
    private func rgbDataFromBuffer(
        _ buffer: CVPixelBuffer,
        byteCount: Int,
        isModelQuantized: Bool
    ) -> Data? {
        CVPixelBufferLockBaseAddress(buffer, .readOnly)
        defer { CVPixelBufferUnlockBaseAddress(buffer, .readOnly) }
        guard let mutableRawPointer = CVPixelBufferGetBaseAddress(buffer) else {
            return nil
        }
        let count = CVPixelBufferGetDataSize(buffer)
        let bufferData = Data(bytesNoCopy: mutableRawPointer, count: count, deallocator: .none)
        var rgbBytes = [UInt8](repeating: 0, count: byteCount)
        var index = 0
        for component in bufferData.enumerated() {
            let offset = component.offset
            let isAlphaComponent = (offset % alphaComponent.baseOffset) == alphaComponent.moduloRemainder
            guard !isAlphaComponent else { continue }
            rgbBytes[index] = component.element
            index += 1
        }
        if isModelQuantized { return Data(bytes: rgbBytes) }
        return Data(copyingBufferOf: rgbBytes.map { Float($0) / 255.0 })
    }
    
    //MARK: -Functions
    func imageFromARGB32Bitmap(pixels: [PixelData], width: Int, height: Int) -> UIImage? {
        guard width > 0 && height > 0 else { return nil }
        guard pixels.count == width * height else { return nil }
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        
        var data = pixels // Copy to mutable []
        guard let providerRef = CGDataProvider(data: NSData(bytes: &data,
                                                            length: data.count * MemoryLayout<PixelData>.size)
            )
            else { return nil }
        
        guard let cgim = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: width * MemoryLayout<PixelData>.size,
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
            )
            else { return nil }
        
        return UIImage(cgImage: cgim)
    }
}




