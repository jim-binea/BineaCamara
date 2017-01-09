//
//  MainViewController.swift
//  BineaCamara
//
//  Created by binea on 2017/1/8.
//  Copyright © 2017年 binea. All rights reserved.
//

import UIKit
import CoreImage
import OpenGLES
import GLKit
import AVFoundation

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        recorder.previewView = view
//    }
    
    var source: CaptureBufferSource?
    var coreImageView: CoreImageView?
    
    var angleForCurrentTime: Float {
        return Float(NSDate.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: M_PI)*2)
    }
    
    override func loadView() {
        coreImageView = CoreImageView(frame: CGRect())
        self.view = coreImageView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupCameraSource()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        source?.running = false
    }
    
    func setupCameraSource() {
        source = CaptureBufferSource(position: .back) { [unowned self] (buffer, transform) in
            let input = CIImage(buffer: buffer).applying(transform)
            let filter = hueAdjust(self.angleForCurrentTime)
            self.coreImageView?.image = filter(input)
        }
        source?.running = true
    }
}

extension CIImage {
    convenience init(buffer: CMSampleBuffer) {
        self.init(cvPixelBuffer: CMSampleBufferGetImageBuffer(buffer)!)
    }
}
