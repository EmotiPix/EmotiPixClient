//
//  ViewController.swift
//  EmotiPix
//
//  Created by Pawel Cegielski on 12/12/2017.
//  Copyright © 2017 Pawel Cegielski. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emotionLabel: UILabel!
    let picker = UIImagePickerController()
    
    @IBOutlet weak var processPictureButton: UIButton!
    @IBOutlet weak var emotionPickerView: UIPickerView!
    @IBOutlet weak var emotionPickerViewHeight: NSLayoutConstraint!
    @IBOutlet weak var labelWidth: NSLayoutConstraint!
    
    var originalSmallImage = UIImage()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        picker.delegate = self
        emotionPickerView.dataSource = self
        emotionPickerView.delegate = self
        //Camera
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                //access granted
            } else {
                
            }
        }
        
        //Photos
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    print("yay") 
                } else {}
            })
        }
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    @IBAction func didTapProcessPicture(_ sender: UIButton) {
        UIView.animate(withDuration: 1.0, animations: {
            self.emotionPickerViewHeight.constant = 0
            self.emotionPickerView.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: nil)
        
        
        //make request to spring server
        
        let emotion = Emotion.allValues[emotionPickerView.selectedRow(inComponent: 0)]
        
        APIManager.shared.postRequestWithPhotoAndEmotion(photo: originalSmallImage, emotion: emotion) { (img) in
            
            DispatchQueue.main.async { [weak self] in
                guard let mySelf = self else {return}
                
                if let image = img {
                    mySelf.imageView.image = img
                }
                UILabel.animate(withDuration: 0.5, animations: {
                    mySelf.imageView.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
                }, completion: { (isTrue) in
                    UIView.animate(withDuration: 0.5, animations: {
                        mySelf.imageView.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
                    })
                })
            }
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Emotion.allValues.count
    }
    @IBAction func didTapChangeEmotion(_ sender: Any) {
        UIView.animate(withDuration: 1.0, animations: {
            self.emotionPickerViewHeight.constant = 100
            self.emotionPickerView.alpha = 1
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Emotion.allValues[row].stringValue()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func didTapTakePicture(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
            picker.cameraFlashMode = .off
            self.present(picker, animated: true, completion: nil)
        } else {
            print("cam not available")
        }
    }
    
    @IBAction func didTapChoosePicture(_ sender: UIButton) {
        
    }
    
    func postImage(img: UIImage) {
        APIManager.shared.postRequestWithPhoto(photo: img) { emotionString in
            guard let emotionString = emotionString else {return}
            
            DispatchQueue.main.async { [weak self] in
                guard let mySelf = self else {return}
                
                let emotion = Emotion(rawValue: emotionString)
                mySelf.emotionPickerView.selectRow(emotion.indexOfEmotion(), inComponent: 0, animated: false)
                
                mySelf.emotionLabel.text = emotionString
                UILabel.animate(withDuration: 0.5, animations: {
                    mySelf.emotionLabel.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
                }, completion: { (isTrue) in
                    mySelf.emotionLabel.transform = CGAffineTransform.init(scaleX: 1.0, y: 1.0)
                })
            }
            
        }
    }
}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let smallImg = image.resizeImageFourTimes()
        imageView.image = smallImg
        originalSmallImage = smallImg
        picker.dismiss(animated: true, completion: nil)
        postImage(img: smallImg)
        
        
    }
}

