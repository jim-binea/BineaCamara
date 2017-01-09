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

class MainViewController: UIViewController {
    let recorder = STRecoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let glView = GLKView(frame: UIScreen.main.bounds)
//        view.addSubview(glView)        
//        
//        let eaglContext = EAGLContext(api: .openGLES2)!
//        let ciContext = CIContext(eaglContext: eaglContext)
//        let blurFilter = CIFilter(name: "CIGaussianBlur")!
//        blurFilter.setValue(2, forKey: "inputRadius")
//        
//        glView.context = eaglContext
//        
//        let image = CIImage(image: #imageLiteral(resourceName: "image"))!
//        blurFilter.setValue(image, forKey:"inputImage")
//        
//        ciContext.draw(blurFilter.outputImage!, in: glView.bounds, from: glView.bounds)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        recorder.previewView = view
    }
    
    
    
}

