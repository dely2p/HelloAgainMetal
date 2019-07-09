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

    private var vertexBuffer : MTLBuffer!
    private var indicesBuffer : MTLBuffer!
    
    private var pipelineState: MTLRenderPipelineState!

    
    var indices: [UInt32] = [0, 1, 2, 2, 3, 0]

    var vertices = [
        Vertex(x:  1, y: -1, z: 0, r: 1, g: 0, b: 0, a: 1),
        Vertex(x:  1, y:  1, z: 0, r: 0, g: 1, b: 0, a: 1),
        Vertex(x: -1, y:  1, z: 0, r: 0, g: 0, b: 1, a: 1),
        Vertex(x: -1, y: -1, z: 0, r: 0, g: 0, b: 0, a: 1),
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setMetal()
        metalView.device = device
        metalView.delegate = self
    }

    func setMetal() {
        device = MTLCreateSystemDefaultDevice()
        commandQueue = device.makeCommandQueue()
        
        let vertexBufferSize = vertices.size()
        vertexBuffer = device.makeBuffer(bytes: &vertices, length: vertexBufferSize, options: .storageModeShared)
        
        let indicesBufferSize = indices.size()
        indicesBuffer = device.makeBuffer(bytes: &indices, length: indicesBufferSize, options: .storageModeShared)
        
        let defaultLibrary = device.makeDefaultLibrary()!
        let fragmentProgram = defaultLibrary.makeFunction(name: "basic_fragment")
        let vertexProgram = defaultLibrary.makeFunction(name: "basic_vertex")
        
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexFunction = vertexProgram
        pipelineStateDescriptor.fragmentFunction = fragmentProgram
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
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
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        renderEncoder.drawIndexedPrimitives(
            type: .triangle,
            indexCount: indices.count,
            indexType: .uint32,
            indexBuffer: indicesBuffer,
            indexBufferOffset: 0)

        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

extension Array {
    func size() -> Int {
        return count * MemoryLayout.size(ofValue: self[0])
    }
}
