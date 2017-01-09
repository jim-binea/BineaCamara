//
//  AssetLoadTask.swift
//  VideoRecorder
//
//  Created by Leo on 2016/12/16.
//  Copyright © 2016年 Binea. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import GLKit

//enum CameraFlashMode {
//    case light
//    case auto
//    case off
//}

class STRecoder: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    var videoDevice: AVCaptureDevice?
    var videoDeviceInput: AVCaptureDeviceInput?
    var videoInput: AVAssetWriterInput?
    
    var captureSession: AVCaptureSession
    
    var videoOutput: AVCaptureVideoDataOutput
    
    private(set) var isRecording: Bool = false
    private(set) var hasStartSession: Bool = false
    
//    var eaglContext: EAGLContext
//    var ciContext: CIContext
//    var blurFilter: CIFilter
    
    var previewLayer: CoreImageView
    var previewView: UIView? {
        didSet {
            previewLayer.removeFromSuperview()
            if let view = previewView {
                previewLayer.frame = view.bounds
                view.insertSubview(previewLayer, at: 0)
            }
        }
    }
    
    
    
    private(set) var videoDevicePosition: AVCaptureDevicePosition = .back {
        didSet {
            if videoDevicePosition != oldValue {
                captureSession.beginConfiguration()
                if let videoDevice = STRecoder.videoDeviceForPosition(position: videoDevicePosition), let videoInput = try? AVCaptureDeviceInput(device: videoDevice) {
                    captureSession.removeInput(videoDeviceInput)
                    self.videoDevice = videoDevice
                    self.videoDeviceInput = videoInput
                    if captureSession.canAddInput(videoInput) {
                        captureSession.addInput(videoInput)
                    }
                }
                captureSession.commitConfiguration()
            }
        }
    }
    
    override init() {
        previewLayer = CoreImageView()
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPreset1280x720
        
        if let videoDevice = STRecoder.videoDeviceForPosition(position: videoDevicePosition), let videoInput = try? AVCaptureDeviceInput(device: videoDevice){
            self.videoDevice = videoDevice
            self.videoDeviceInput = videoInput
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
        }
        
        videoOutput = AVCaptureVideoDataOutput()
//        videoOutput.alwaysDiscardsLateVideoFrames = true
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        super.init()
        
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global())
        captureSession.startRunning()
        
    }
    
    deinit {
        captureSession.stopRunning()
    }
    
    func prepareToRecord() {
        
    }
    
    func startRuning() {
        if captureSession.isRunning {
            return
        }
        captureSession.startRunning()
    }
    
    func stopRuning() {
        captureSession.stopRunning()
    }
    
    func switchCaptureDevices() {
        videoDevicePosition = videoDevice?.position == .back ? .front : .back
    }
    func setFlashMode(flashMode: AVCaptureFlashMode) {
        if let device = videoDevice, device.hasFlash {
            do {
                try device.lockForConfiguration()
                if flashMode == .on {
                    device.flashMode = .off
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                    device.flashMode = flashMode
                }
                device.unlockForConfiguration()
            } catch {
                
            }
        }
    }
    
    static func videoDeviceForPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        guard let videoDevices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo) as? [AVCaptureDevice] else {
            return nil
        }
        for device in videoDevices {
            if device.position == position {
                return device
            }
        }
        return nil
    }
    
    func teardownAssetWriterAndInputs() {
        videoInput = nil
    }
    
    //MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        let image = CIImage(cvPixelBuffer: CMSampleBufferGetImageBuffer(sampleBuffer)!)
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setValue(2, forKey: "inputRadius")
        blurFilter.setValue(image, forKey:"inputImage")
        previewLayer.image = blurFilter.outputImage
    }
    
}
