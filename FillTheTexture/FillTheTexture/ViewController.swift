//
//  ViewController.swift
//  FillTheTexture
//
//  Created by dely on 03/07/2019.
//  Copyright © 2019 dely. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {

    @IBOutlet weak var metalView: MTKView!
    private var device: MTLDevice!
    private var commandQueue: MTLCommandQueue!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMetal()
        metalView.device = device
        metalView.delegate = self
    }

    func setMetal() {
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
    }

}

extension ViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable else {
            return
        }
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1.0, green: 1.0, blue: 0.5, alpha: 1.0)
        
        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }
        
        guard let renderEncoder = commandBuffer
            .makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                return
        }
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
