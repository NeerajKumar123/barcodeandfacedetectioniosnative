/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import MobileCoreServices
import TesseractOCR
import GPUImage
import Vision


class ViewController: UIViewController {
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  // IBAction methods
  @IBAction func backgroundTapped(_ sender: Any) {
    view.endEditing(true)
  }
  
  @IBAction func takePhoto(_ sender: Any) {
    // 1
    let imagePickerActionSheet =
      UIAlertController(title: "Snap/Upload Image",
                        message: nil,
                        preferredStyle: .actionSheet)

    // 2
    if UIImagePickerController.isSourceTypeAvailable(.camera) {
      let cameraButton = UIAlertAction(
        title: "Take Photo",
        style: .default) { (alert) -> Void in
          // TODO: Add more code here...
        // 1
        self.activityIndicator.startAnimating()
        // 2
        let imagePicker = UIImagePickerController()
        // 3
        imagePicker.delegate = self
        // 4
        imagePicker.sourceType = .camera
        // 5
        imagePicker.mediaTypes = [kUTTypeImage as String]
        // 6
        self.present(imagePicker, animated: true, completion: {
          // 7
          self.activityIndicator.stopAnimating()
        })

      }
      imagePickerActionSheet.addAction(cameraButton)
    }

    // 3
    let libraryButton = UIAlertAction(
      title: "Choose Existing",
      style: .default) { (alert) -> Void in
        // TODO: Add more code here...
      self.activityIndicator.startAnimating()
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = self
      imagePicker.sourceType = .photoLibrary
      imagePicker.mediaTypes = [kUTTypeImage as String]
      self.present(imagePicker, animated: true, completion: {
        self.activityIndicator.stopAnimating()
      })
    }
    imagePickerActionSheet.addAction(libraryButton)

    // 4
    let cancelButton = UIAlertAction(title: "Cancel", style: .cancel)
    imagePickerActionSheet.addAction(cancelButton)

    // 5
    present(imagePickerActionSheet, animated: true)

  }

  // Tesseract Image Recognition
  func performImageRecognition(_ image: UIImage) {
    // TODO: Add more code here...
    // 1
    let scaledImage = image.scaledImage(1000) ?? image
    let preprocessedImage = scaledImage.preprocessedImage() ?? scaledImage
    
    if let tesseract = G8Tesseract(language: "eng+fra") {
      // 2
      tesseract.engineMode = .tesseractCubeCombined
      // 3
      tesseract.pageSegmentationMode = .auto
      // 4
      tesseract.image = preprocessedImage
      // 5
      tesseract.recognize()
      // 6
      textView.text = tesseract.recognizedText
    }
    // 7
    activityIndicator.stopAnimating()

  }
}

// MARK: - UINavigationControllerDelegate
extension ViewController: UINavigationControllerDelegate {
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    // TODO: Add more code here...
    // 1
    guard let selectedPhoto =
      info[.originalImage] as? UIImage else {
        dismiss(animated: true)
        return
    }
    // 2
    activityIndicator.startAnimating()
    // 3
    dismiss(animated: true) {
      self.performImageRecognition(selectedPhoto)
    }

  }
}

// MARK: - UIImage extension

//1
extension UIImage {
  // 2
  func scaledImage(_ maxDimension: CGFloat) -> UIImage? {
    // 3
    var scaledSize = CGSize(width: maxDimension, height: maxDimension)
    // 4
    if size.width > size.height {
      scaledSize.height = size.height / size.width * scaledSize.width
    } else {
      scaledSize.width = size.width / size.height * scaledSize.height
    }
    // 5
    UIGraphicsBeginImageContext(scaledSize)
    draw(in: CGRect(origin: .zero, size: scaledSize))
    let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    // 6
    return scaledImage
  }
  
  func preprocessedImage() -> UIImage? {
    // 1
    let stillImageFilter = GPUImageAdaptiveThresholdFilter()
    // 2
    stillImageFilter.blurRadiusInPixels = 15.0
    // 3
    let filteredImage = stillImageFilter.image(byFilteringImage: self)
    // 4
    return filteredImage
  }
  
  func getPixelColor(pos: CGPoint) -> UIColor {

          let pixelData = self.cgImage!.dataProvider!.data
          let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)

          let pixelInfo: Int = ((Int(self.size.width) * Int(pos.y)) + Int(pos.x)) * 4

          let r = CGFloat(data[pixelInfo]) / CGFloat(255.0)
          let g = CGFloat(data[pixelInfo+1]) / CGFloat(255.0)
          let b = CGFloat(data[pixelInfo+2]) / CGFloat(255.0)
          let a = CGFloat(data[pixelInfo+3]) / CGFloat(255.0)

          return UIColor(red: r, green: g, blue: b, alpha: a)
      }
}




