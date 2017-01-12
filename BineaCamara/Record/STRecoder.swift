//
//  AssetLoadTask.swift
//  VideoRecorder
//
//  Created by Binea on 2016/12/16.
//  Copyright © 2016年 Binea. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import GLKit

enum CameraFlashMode {
    case light
    case auto
    case off
}

protocol STRecoderDelegate: class {
    func recoder(recorder: STRecoder, didOutputSampleBuffer sampleBuffer: CMSampleBuffer)
}

class STRecoder: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var videoDevice: AVCaptureDevice?
    var videoDeviceInput: AVCaptureDeviceInput?
    var videoInput: AVAssetWriterInput?
    
    var videoOutput: AVCaptureVideoDataOutput
    
    var captureSession: AVCaptureSession
    
    weak var delegate: STRecoderDelegate?
    
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
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        if let videoDevice = STRecoder.videoDeviceForPosition(position: videoDevicePosition), let videoInput = try? AVCaptureDeviceInput(device: videoDevice){
            self.videoDevice = videoDevice
            self.videoDeviceInput = videoInput
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
        }
        
        videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
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
    
    //MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        delegate?.recoder(recorder: self, didOutputSampleBuffer: sampleBuffer)
    }
    
}

extension STRecoder {
    
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
}
