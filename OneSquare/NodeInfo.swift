//
//  nodeInfo.swift
//  OneSquare
//
//  Created by 李超 on 15/12/19.
//  Copyright © 2015年 李超. All rights reserved.
//

import UIKit
import SceneKit

class NodeInfo: NSObject {
    
    var position: (x: Float, y: Float, z: Float)?
    var euler: (x: Float, y: Float, z: Float)?
    var lookAtPoint: (x: Float, y: Float, z: Float)?
    var distance: Float {
        return sqrt((position!.x - lookAtPoint!.x)*(position!.x - lookAtPoint!.x)+(position!.y - lookAtPoint!.y)*(position!.y - lookAtPoint!.y)+(position!.z - lookAtPoint!.z)*(position!.z - lookAtPoint!.z))
    }
    override var description:String {
        if position != nil && euler != nil && lookAtPoint != nil {
            return "{\"position\": \(convert(position!)), \"euler\": \(convert(euler!)), \"lookAtPoint\": \(convert(lookAtPoint!))}"
        } else {
            return "lack of parameters"
        }
    }
    override init() {
        super.init()
    }
    convenience init(position:(x: Float, y: Float, z: Float), euler:(x: Float, y: Float, z: Float), lookAtPoint:(x: Float, y: Float, z: Float)) {
        self.init()
        self.position = position
        self.euler = euler
        self.lookAtPoint = lookAtPoint
    }
}

class LightNodeInfo: NodeInfo {
    var type: LightNodeInfoType?
    override var description:String {
        if position != nil && euler != nil && lookAtPoint != nil && type != nil {
            return "{\"position\": \(convert(position!)), \"euler\": \(convert(euler!)), \"lookAtPoint\": \(convert(lookAtPoint!)), \"type\":\"\(type!.rawValue)\"}"
        } else {
            return "lack of parameters"
        }
    }
    override init() {
        super.init()
    }
    convenience init(position:(x: Float, y: Float, z: Float), euler:(x: Float, y: Float, z: Float), lookAtPoint:(x: Float, y: Float, z: Float), type:LightNodeInfoType) {
        self.init()
        self.position = position
        self.euler = euler
        self.lookAtPoint = lookAtPoint
        self.type = type
    }
}

enum LightNodeInfoType: Int {
    case Omni = 0
    case Directional
    case Spot
    case Ambient
}

extension NodeInfo {
    //通过model获取scnnode
    func node() -> SCNNode {
        let node = SCNNode.init()
        node.position = SCNVector3MakeFrom(self.position!)
        node.eulerAngles = SCNVector3Make(self.euler!.x, self.euler!.y, self.euler!.z)
        let lookAtPoint = SCNNode.init()
        lookAtPoint.position = SCNVector3MakeFrom(self.lookAtPoint!)
        node.constraints = [SCNLookAtConstraint.init(target: lookAtPoint)]
        node.camera = SCNCamera.init()
        return node
    }
    
    //通过当前主视角camera的位置获取其他camera的node
    func getBaseNodeAndCameraNode() -> (base: SCNNode, bottom: SCNNode, top: SCNNode, left: SCNNode, right: SCNNode) {
        let base = SCNNode.init()
        base.position = SCNVector3MakeFrom(self.lookAtPoint!)
        base.eulerAngles = SCNVector3Make(self.euler!.x, self.euler!.y, self.euler!.z)
        
        let bottom = SCNNode.init()
        bottom.position = SCNVector3Make(0, 0, self.distance)
        bottom.eulerAngles = SCNVector3Zero
        bottom.camera = SCNCamera.init()
        base.addChildNode(bottom)
        
        let top = SCNNode.init()
        top.position = SCNVector3Make(0, 0, -self.distance)
        top.eulerAngles = SCNVector3Make(-Float(M_PI), 0, 0)
        top.camera = SCNCamera.init()
        base.addChildNode(top)
        
        let left = SCNNode.init()
        left.position = SCNVector3Make(-self.distance, 0, 0)
        left.eulerAngles = SCNVector3Make(-Float(M_PI)/2, 0, Float(M_PI)/2)
        left.camera = SCNCamera.init()
        base.addChildNode(left)
        
        let right = SCNNode.init()
        right.position = SCNVector3Make(self.distance, 0, 0)
        right.eulerAngles = SCNVector3Make(-Float(M_PI)/2, 0, -Float(M_PI)/2)
        right.camera = SCNCamera.init()
        base.addChildNode(right)
        
        return (base, bottom, top, left, right)
    }
}

extension LightNodeInfo {
    //通过model获取scnnode
    override func node() -> SCNNode {
        let node = SCNNode.init()
        node.position = SCNVector3MakeFrom(self.position!)
        node.eulerAngles = SCNVector3MakeFrom(self.euler!)
        let lookAtPoint = SCNNode.init()
        lookAtPoint.position = SCNVector3MakeFrom(self.lookAtPoint!)
        node.constraints = [SCNLookAtConstraint.init(target: lookAtPoint)]
        let light = SCNLight.init()
        switch self.type! {
        case LightNodeInfoType.Omni:
            light.type = SCNLightTypeOmni
        case LightNodeInfoType.Directional:
            light.type = SCNLightTypeDirectional
        case LightNodeInfoType.Spot:
            light.type = SCNLightTypeSpot
        case LightNodeInfoType.Ambient:
            light.type = SCNLightTypeAmbient
        }
        node.light = light
        return node
    }
}
