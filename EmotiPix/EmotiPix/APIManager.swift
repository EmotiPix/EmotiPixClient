//
//  APIManager.swift
//  EmotiPix
//
//  Created by Pawel Cegielski on 13/12/2017.
//  Copyright © 2017 Pawel Cegielski. All rights reserved.
//

import Foundation
import Photos
import MobileCoreServices

enum Emotion {
    case Neutral
    case Anger
    case Disgust
    case Happy
    case Sadness
    case Surprise
    case No_emotion
    static let allValues = [Neutral, Anger, Disgust, Happy, Sadness, Surprise, No_emotion]
    
    init(rawValue: String) {
        switch rawValue.lowercased() {
        case "neutral": self = .Neutral
        case "anger": self = .Anger
        case "disgust": self = .Disgust
        case "happy": self = .Happy
        case "sadness": self = .Sadness
        case "surprise": self = .Surprise
        default: self = .No_emotion
        }
    }
    func stringValue() -> String {
        switch self {
        case .Neutral:
            return "Neutral"
        case .Anger:
            return "Anger"
        case .Disgust:
            return "Disgust"
        case .Happy:
            return "Happy"
        case .Sadness:
            return "Sadness"
        case .Surprise:
            return "Surprise"
        case .No_emotion:
            return "No_emotion"
        }
    }
    func indexOfEmotion() -> Int {
        return Emotion.allValues.index(of: self)!
    }
}


class APIManager {
    static let shared = APIManager()
    
    func imageTobase64(image: UIImage) -> String {
        var base64String = ""
        let  cim = CIImage(image: image)
        if (cim != nil) {
            let imageData = image.lowestQualityJPEGNSData
            base64String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions.endLineWithLineFeed)
        }
        return base64String
    }
    
    func imageTobase64Old(image: UIImage) -> String {
        var base64String = ""
        let  cim = CIImage(image: image)
        if (cim != nil) {
            let imageData = image.lowestQualityJPEGNSData
            base64String = imageData.base64EncodedString(options: NSData.Base64EncodingOptions.lineLength64Characters)
        }
        return base64String
    }
    
    func convertBase64ToImage(base64String: String) -> UIImage? {
        let decodedData = NSData(base64Encoded: base64String, options: NSData.Base64DecodingOptions(rawValue: 0) )
        if let decodedimage = UIImage(data: decodedData! as Data) {
            return decodedimage
        } else {
            return nil
        }
    }
    
    func postRequestWithPhoto(photo: UIImage, completion: @escaping (_ result: String?) -> Void) {
        
        let imageData2 = imageTobase64(image: photo)
        
        let outStr = "data:image/jpeg;base64,"  + imageData2
        let body = [
            "image": outStr,
            ]
        
        let session = URLSession.shared
        
        guard let url = URL(string: "https://crmudc6r57.execute-api.us-east-2.amazonaws.com/prod/emotion") else { return }
        
        let request = NSMutableURLRequest(url: url,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        let hd = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache",
            "Postman-Token": "de39f0b0-db24-dff6-9413-90ddb4172f21"
        ]
        
        
        let json = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        request.httpBody = json as Data
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = hd
        
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
                completion(nil)
            } else {
                let httpResponse = response as! HTTPURLResponse
                print(httpResponse)
                
                let statusCode = httpResponse.statusCode
                switch statusCode {
                case 200:
                    print("POST sucessful")
                    guard let data = data else {return}
                    let emotionString = String(data: data, encoding: .utf8)
                    print(emotionString)
                    completion(emotionString)
                case 500:
                    print("Internal server error on posting value")
                    completion(nil)
                default:
                    String.init(data: data!, encoding: .utf8)
                    print("error posting request")
                    completion(nil)
                    
                }
            }})
        dataTask.resume()
        
    }
    
    func postRequestWithPhotoAndEmotion(photo: UIImage, emotion: Emotion, completion: @escaping (_ result: UIImage?) -> Void) {
        
        //        for i in 0...10000 {
        let imageData2 = imageTobase64(image: photo)
        
        let outStr = "data:image/jpeg;base64,"  + imageData2
        
        let body = [
            "image": outStr,
            "emotion": emotion.stringValue().uppercased()
        ]
        
        let session = URLSession.shared
        
        let urlString  = "https://crmudc6r57.execute-api.us-east-2.amazonaws.com/prod/process" //new url
        
        guard let url = URL(string: urlString) else { return }
        
        let request = NSMutableURLRequest(url: url as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 2.0)
        
        let hd = [
            "Content-Type": "application/json",
            "Cache-Control": "no-cache",
            "Postman-Token": "de39f0b0-db24-dff6-9413-90ddb4172f21"
        ]
        
        
        let json = try! JSONSerialization.data(withJSONObject: body, options: [])
        
        request.httpBody = json as Data
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = hd
        
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error)
                completion(nil)
            } else {
                let httpResponse = response as! HTTPURLResponse
                print(httpResponse)
                
                let statusCode = httpResponse.statusCode
                guard let data = data else {return}
                
                switch statusCode {
                case 200:
                    print("POST sucessful")
                    let data = data
                    let img = self.convertBase64ToImage(base64String: String(data: data, encoding: .utf8)!)
                    completion(img)
                    
                case 500:
                    print("Internal server error on posting value")
                    completion(nil)
                default:
                    print("error posting request")
                    completion(nil)
                    
                    
                    
                }
            }})
        dataTask.resume()
        //        }
    }
    
}
    
    
   

extension UIImage {
    var highestQualityJPEGNSData:NSData { return UIImageJPEGRepresentation(self, 1.0)! as NSData }
    var highQualityJPEGNSData:NSData    { return UIImageJPEGRepresentation(self, 0.75)! as NSData}
    var mediumQualityJPEGNSData:NSData  { return UIImageJPEGRepresentation(self, 0.5)! as NSData }
    var lowQualityJPEGNSData:NSData     { return UIImageJPEGRepresentation(self, 0.25)! as NSData}
    var lowestQualityJPEGNSData:NSData  { return UIImageJPEGRepresentation(self, 0.0)! as NSData }
}
extension UIImage {
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        let newSize = widthRatio > heightRatio ?  CGSize(width: size.width * heightRatio, height: size.height * heightRatio) : CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
}

extension UIImage{
    
    func resizeImageFourTimes() -> UIImage {
        
        
        let newSize = CGSize(width: size.width/4, height: size.height/4)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    
}


