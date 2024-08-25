import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var colorView1: UIView!
    @IBOutlet weak var colorView2: UIView!
    @IBOutlet weak var colorView3: UIView!
    @IBOutlet weak var colorView4: UIView!
    @IBOutlet weak var colorView5: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func selectImage(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            processImage(image)
        } else {
            print("Failed to get the image")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func extractPixels(from image: UIImage) -> [UIColor]? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let rawData = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        let context = CGContext(data: rawData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var colors = [UIColor]()
        for x in 0..<width {
            for y in 0..<height {
                let offset = 4 * ((y * width) + x)
                let red = rawData[offset]
                let green = rawData[offset + 1]
                let blue = rawData[offset + 2]
                let alpha = rawData[offset + 3]
                let color = UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: CGFloat(alpha) / 255.0)
                colors.append(color)
            }
        }
        
        rawData.deallocate()
        return colors
    }
    
    private func processImage(_ image: UIImage) {
        guard let pixelColors = extractPixels(from: image) else {
            print("Failed to extract pixels from image")
            return
        }
        
        let kmeans = KMeans(k: 5)
        let dominantColors = kmeans.clusterColors(pixelColors)
        
        if dominantColors.count >= 5 {
            colorView1.backgroundColor = dominantColors[0]
            colorView2.backgroundColor = dominantColors[1]
            colorView3.backgroundColor = dominantColors[2]
            colorView4.backgroundColor = dominantColors[3]
            colorView5.backgroundColor = dominantColors[4]
        } else {
            print("Not enough colors found")
        }
    }
}
