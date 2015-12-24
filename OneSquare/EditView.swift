//
//  EditView.swift
//  OneSquare
//
//  Created by 李超 on 15/12/10.
//  Copyright © 2015年 李超. All rights reserved.
//

import UIKit
import SceneKit

class EditView: UIView {
    
    var filePath: String? {
        didSet {
            let fileScene = SCNScene.init(named: filePath!)
            let fileNode = fileScene!.rootNode.childNodes
            for node: SCNNode in fileNode {
                scene?.rootNode.addChildNode(node)
//                node.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 1, z: 0, duration: 5)))
            }
            scene?.rootNode.getBoundingBoxMin(&smallestVector, max: &biggestVector)
            let cameraNode = SCNNode.init()
            cameraNode.camera = SCNCamera.init()
            cameraNode.position = self.initialCameraPosition(smallestVector, big: biggestVector)
            let lookAtNode = SCNNode.init()
            lookAtNode.position = SCNVector3Make((smallestVector.x+biggestVector.x)/2, (smallestVector.y+biggestVector.y)/2, (smallestVector.z+biggestVector.z)/2)
            cameraNode.constraints = [SCNLookAtConstraint.init(target: lookAtNode)]
            cameraInfoString = cameraNode.nodeInfo()?.description
        }
    }
    var lightInfoString: String? {
        get {
            var nodeArray = [LightNodeInfo]()
            for node: SCNNode in scene!.rootNode.childNodes {
                if node.light != nil {
                    nodeArray.append(node.lightNodeInfo()!)
                }
            }
            if nodeArray.count != 0 {
                return nodeArray.convertToLightNodeInfoString()
            } else {
                return nil
            }
        }
        set {
            for node: SCNNode in scene!.rootNode.childNodes {
                if node.light != nil {
                    node.removeFromParentNode()
                }
            }
            if newValue != nil {
                let infoArray = newValue?.convertStringToLightNodeInfoArray()
                if infoArray != nil {
                    for lightInfo: LightNodeInfo in infoArray! {
                        let node = lightInfo.node()
                        scene?.rootNode.addChildNode(node)
                    }
                }
            }
        }
    }
    //
    var cameraInfoString: String? {
        get {
            return previewView?.pointOfView?.nodeInfo()?.description
        }
        set {
            for node: SCNNode in scene!.rootNode.childNodes {
                if node.camera != nil && node.constraints?.count != 0 {
                    node.removeFromParentNode()
                }
            }
            if newValue == nil {
                let cameraNode = SCNNode.init()
                cameraNode.position = self.initialCameraPosition(smallestVector, big: biggestVector)
                let lookAtNode = SCNNode.init()
                lookAtNode.position = SCNVector3Make((smallestVector.x+biggestVector.x)/2, (smallestVector.y+biggestVector.y)/2, (smallestVector.z+biggestVector.z)/2)
                scene?.rootNode.addChildNode(lookAtNode)
                cameraNode.constraints = [SCNLookAtConstraint.init(target: lookAtNode)]
                previewView?.pointOfView = cameraNode
            } else {
                let cameraNode = newValue!.convertStringToNodeInfo()?.node()
                scene?.rootNode.addChildNode(cameraNode!)
                previewView?.pointOfView = cameraNode!
            }
        }
    }
//    private var
    private var smallestVector: SCNVector3
    private var biggestVector: SCNVector3
    private var previewView: SCNView?
    private var scene: SCNScene?
    override init(frame : CGRect) {
        smallestVector = SCNVector3Zero
        biggestVector = SCNVector3Zero
        super.init(frame : frame)
        self.setUpScene();
        self.setUpSubviews();
    }
    
    convenience init() {
        self.init(frame:CGRect.zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func getNodeBy(lightNodeInfo: LightNodeInfo) -> SCNNode? {
        for node: SCNNode in (scene?.rootNode.childNodes)! {
            if node.isEqualToLightNodeInfo(lightNodeInfo) {
                return node
            }
        }
        return nil
    }
    
    func addLightNode() -> SCNNode {
        let node = SCNNode.init()
        node.light = SCNLight.init()
        node.light?.type = SCNLightTypeOmni
        node.position = SCNVector3Make(0, 30, 0)
        scene?.rootNode.addChildNode(node)
        return node;
    }
    
    private func setUpScene() {
        scene = SCNScene.init()

    }
    
    private func setUpSubviews() {
        previewView = SCNView.init(frame: CGRectZero, options: nil)
        self.addSubview(previewView!)
        previewView?.allowsCameraControl = true
        previewView?.snp_makeConstraints(closure: { (make) -> Void in
            make.centerX.equalTo(self.snp_centerX)
            make.top.equalTo(self.snp_top).inset(100)
            make.left.equalTo(self.snp_left).inset(30)
            make.height.equalTo(250)
        })
        previewView?.scene = scene
        let recognizer = UIPanGestureRecognizer.init(target: self, action: Selector.init("log"))
        recognizer.minimumNumberOfTouches = 2
        previewView?.addGestureRecognizer(recognizer)
    }

    private func initialCameraPosition(small: SCNVector3, big: SCNVector3) -> SCNVector3 {
        let mid = SCNVector3Make((small.x+big.x)/2, (small.y+big.y)/2, (small.z+big.z)/2)
        let x = max(fabs(mid.x - small.x), fabs(mid.x - big.x))
        let y = max(fabs(mid.y - small.y), fabs(mid.y - big.y))
        let z = max(fabs(mid.z - small.z), fabs(mid.z - big.z))
        let distance = sqrt(x*x+y*y+z*z)
        return SCNVector3Make(mid.x + distance, mid.y + distance, mid.z + distance)
    }
}
