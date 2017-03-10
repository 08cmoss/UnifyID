//
//  ViewController.swift
//  UnifyID
//
//  Created by Cameron Moss on 3/9/17.
//  Copyright © 2017 Cameron Moss. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate {
    
    @IBOutlet weak var previewView: UIView!
    var captureSession = AVCaptureSession()
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer!
    var cameraOutput = AVCapturePhotoOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        let devices = AVCaptureDevice.devices()
        
        for device in devices! {
            if ((device as AnyObject).hasMediaType(AVMediaTypeVideo)) {
                if((device as AnyObject).position == AVCaptureDevicePosition.front) {
                    captureDevice = device as? AVCaptureDevice
                }
            }
        }
        
        if captureDevice != nil {
            
            beginSession()
            
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func snapshotButtonPressed(_ sender: Any) {
        
        if captureSession.isRunning {
            capturePhoto()
        } else {
            print("There is an error")
        }
        
        
    }
    
    func beginSession() {
        captureSession.beginConfiguration()
        if captureSession.inputs.isEmpty {
        do {
            
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            
        } catch _ {
            print("error")
        }
        }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer!)
        previewLayer?.frame = self.previewView.layer.frame
        captureSession.commitConfiguration()
        captureSession.startRunning()
    }
    
    func capturePhoto() {
        
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat
        self.cameraOutput.capturePhoto(with: settings, delegate: self)
        
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if (error != nil) {
            print("error")
        }
        if ((photoSampleBuffer) != nil) {
            let data:Data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)!

            let image:UIImage = UIImage(data: data)!
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            }, completionHandler: { success, error in
                if success {
                    print("Saved successfully!")
                }
                else if error != nil {
                    // Save photo failed with error
                }
                else {
                    // Save photo failed with no error
                }
            })
            
        }
    }
    
    

}

