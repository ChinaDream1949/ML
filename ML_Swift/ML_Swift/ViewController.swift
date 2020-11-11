//
//  ViewController.swift
//  ML_Swift
//
//  Created by MR.Sahw on 2020/11/11.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func pick(_ sender: Any) {
        let picker =  UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        present(picker, animated: true, completion: nil)
    }
    
}

extension ViewController: UIImagePickerControllerDelegate , UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            guard let ciImage = CIImage(image: image) else {
                fatalError("不能把图像转化为CIImage")
            }
            
            guard let model = try? VNCoreMLModel(for: MobileNetV2().model) else {
                fatalError("加载model失败")
            }
            
            let request = VNCoreMLRequest(model: model) { (request, errror) in
                guard let res = request.results else {
                    fatalError("图像识别失败")
                }
                let classifications = res as! [VNClassificationObservation]
                if classifications.isEmpty{
                    self.navigationItem.title = "不知道是什么"
                }else{
                    self.navigationItem.title = classifications.first!.identifier
                }
            }
            
            request.imageCropAndScaleOption = .centerCrop
            
            do {
                try VNImageRequestHandler(ciImage: ciImage).perform([request])
            }catch{
                print("执行图片识别请求失败，原因是：\(error.localizedDescription)")
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
