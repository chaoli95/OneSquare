//
//  Extension.swift
//  OneSquare
//
//  Created by 李超 on 15/12/19.
//  Copyright © 2015年 李超. All rights reserved.
//

import Foundation
import SceneKit

public func SCNVector3MakeFrom(tuple:(x: Float, y: Float, z: Float)) -> SCNVector3 {
    return SCNVector3Make(tuple.x, tuple.y, tuple.z)
}

public func convert(tuple:(x: Float, y: Float, z: Float)) -> Array<Float> {
    let array = [tuple.x, tuple.y, tuple.z]
    return array
}

public func == <T:Equatable> (tuple1:(T,T,T),tuple2:(T,T,T)) -> Bool {
    return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1) && (tuple1.2 == tuple2.2)
}

extension String {
    private func convertStringToNodeInfoDictionary() -> [String:AnyObject]? {
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    func convertStringToLightNodeInfoArray() -> [LightNodeInfo]? {
        if let data = self.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [[String:AnyObject]]
                var lightNodeInfoArray = [LightNodeInfo]()
                for dic: [String:AnyObject] in json! {
                    if let lightNodeInfo = dic.convertDictionaryToLightNodeInfo() {
                        lightNodeInfoArray.append(lightNodeInfo)
                    } else {
                        return nil
                    }
                }
                return lightNodeInfoArray
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
    
    //string转nodeinfo
    func convertStringToNodeInfo() -> NodeInfo? {
        let nodeInfo = self.convertStringToNodeInfoDictionary()?.convertDictionaryToNodeInfo()
        if nodeInfo != nil {
            return nodeInfo
        } else {
            print("convert fail")
            return nil
        }
    }
}

extension Dictionary where Key: StringLiteralConvertible, Value: AnyObject {
    private func convertDictionaryToNodeInfo() -> NodeInfo? {
        var positionArray = [Float]()
        var eulerArray = [Float]()
        var lookAtArray = [Float]()
        guard let i = self["position"] as! [Float]? else {
            return nil
        }
        positionArray = i
        guard let j = self["euler"] as! [Float]? else {
            return nil
        }
        for num: Float in j {
            eulerArray.append(num)
        }
        guard let k = self["lookAtPoint"] as! [Float]? else {
            return nil
        }
        lookAtArray = k
        let nodeInfo = NodeInfo.init(position: (positionArray[0], positionArray[1], positionArray[2]), euler: (eulerArray[0], eulerArray[1], eulerArray[2]), lookAtPoint: (lookAtArray[0], lookAtArray[1], lookAtArray[2]))
        return nodeInfo
    }
    
    private func convertDictionaryToLightNodeInfo() -> LightNodeInfo? {
        var positionArray = [Float]()
        var eulerArray = [Float]()
        var lookAtArray = [Float]()
        guard let i = self["position"] as! [Float]? else {
            return nil
        }
        positionArray = i
        guard let j = self["euler"] as! [Float]? else {
            return nil
        }
        eulerArray = j
        guard let k = self["lookAtPoint"] as! [Float]? else {
            return nil
        }
        lookAtArray = k
        guard let type = self["type"] as! String? else {
            return nil
        }
        let lightType = LightNodeInfoType(rawValue: Int(type)!)
        
        let nodeInfo = LightNodeInfo.init(position: (positionArray[0], positionArray[1], positionArray[2]), euler: (eulerArray[0], eulerArray[1], eulerArray[2]), lookAtPoint: (lookAtArray[0], lookAtArray[1], lookAtArray[2]), type: lightType!)
        return nodeInfo
    }
}

extension UIView {
    class func loadFromNibNamed(nibNamed: String, bundle : NSBundle? = nil) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiateWithOwner(nil, options: nil)[0] as? UIView
    }
}

extension Array where Element:LightNodeInfo {
    func convertToLightNodeInfoString() -> String? {
        var string = "["
        for nodeInfo: LightNodeInfo in self {
            if nodeInfo.description != "lack of parameters" {
                string += nodeInfo.description + ","
            } else {
                return nil
            }
        }
        string.removeAtIndex(string.endIndex.predecessor())
        string += "]"
        return string
    }
}

extension SCNNode {
    //将scnnode 转化为model
    func nodeInfo() -> NodeInfo? {
        if self.camera != nil {
            var point = SCNNode.init()
            if let lookAtCons = self.constraints?[0] {
                let constraint = lookAtCons as! SCNLookAtConstraint
                point = constraint.target
            }
            let info = NodeInfo.init(position: (self.position.x, self.position.y, self.position.z), euler: (self.eulerAngles.x, self.eulerAngles.y, self.eulerAngles.z), lookAtPoint: (point.position.x, point.position.y, point.position.z))
            return info
        } else {
            return nil
        }
    }
    
    func lightNodeInfo() -> LightNodeInfo? {
        if self.light != nil {
            var point = SCNVector3Make(0, 0, 0)
            if let lookAtCons = self.constraints?[0] as? SCNLookAtConstraint {
                point = lookAtCons.target.position
            }
            var type:LightNodeInfoType?
            switch self.light!.type {
            case SCNLightTypeOmni:
                type = LightNodeInfoType.Omni
            case SCNLightTypeSpot:
                type = LightNodeInfoType.Spot
            case SCNLightTypeAmbient:
                type = LightNodeInfoType.Ambient
            case SCNLightTypeDirectional:
                type = LightNodeInfoType.Directional
            default:
                type = nil
            }
            let info = LightNodeInfo.init(position: (self.position.x, self.position.y, self.position.z), euler: (self.eulerAngles.x, self.eulerAngles.y, self.eulerAngles.z), lookAtPoint: (point.x, point.y, point.z), type: type!)
            return info
        } else {
            return nil
        }
    }
    
    func isEqualToLightNodeInfo(lightNodeInfo: LightNodeInfo) -> Bool {
        let info = self.lightNodeInfo()
        if info != nil {
            return (info!.position)! == lightNodeInfo.position! && (info?.euler)! == lightNodeInfo.euler! && (info?.lookAtPoint)! == lightNodeInfo.lookAtPoint! && info!.type == lightNodeInfo.type
        } else {
            return false
        }
        
    }
}