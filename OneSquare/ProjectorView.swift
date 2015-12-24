//
//  projectorView.swift
//  OneSquare
//
//  Created by 李超 on 15/12/19.
//  Copyright © 2015年 李超. All rights reserved.
//

import UIKit
import SceneKit
import SnapKit


class ProjectorView: UIView {

    //设置是否旋转以及旋转时间
    var animation: (doAnimating:Bool, duration:NSTimeInterval) {
        didSet {
            for node: SCNNode in fileNodes! {
                scene?.rootNode.addChildNode(node)
                if animation.doAnimating && animation.duration > 0 {
                    node.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 1, z: 0, duration: animation.duration)))
                } else {
                    node.removeAllActions()
                }
            }
        }
    }
    //
    var filePath: String? {
        didSet {
            let fileScene = SCNScene.init(named: filePath!)
            fileNodes = fileScene!.rootNode.childNodes
            for node: SCNNode in fileNodes! {
                scene?.rootNode.addChildNode(node)
                if animation.doAnimating {
                    node.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 1, z: 0, duration: animation.duration)))
                } else {
                    node.removeAllActions()
                }
            }
        }
    }
    //
    var lightInfoString: String?
    //
    var cameraInfoString: String?
    private var lookAtPoint: SCNNode?
    private var fileNodes: [SCNNode]?
    private var scene: SCNScene?
    private var topView: SCNView?
    private var bottomView: SCNView?
    private var leftView: SCNView?
    private var rightView: SCNView?
    private var widthMutaply: Double {
        get {
            return 0.3333333333
        }
    }
    override init(frame: CGRect) {
        animation = (true, 5)
        super.init(frame : frame)
        self.setUpSubviews();
        self.setUpScenes();
    }
    
    //接口！～～
    convenience init(frame:CGRect, filePath:String, cameraInfoString:String, lightInfoString:String?, animation:(Bool, NSTimeInterval)) {
        self.init(frame:frame)
        self.filePath = filePath
        self.cameraInfoString = cameraInfoString
        self.lightInfoString = lightInfoString
        self.animation = animation
        self.setUpCamera()
    }
    
    convenience init() {
        self.init(frame:CGRect.zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    func setUpSubviews() {
        self.backgroundColor = UIColor.blackColor()
      //  UIScreen.mainScreen().brightness = 1.0
        
        let midView = UIView.init()
        midView.backgroundColor = UIColor.whiteColor()
        midView.layer.masksToBounds = true
        midView.layer.cornerRadius = 2.5
        self.addSubview(midView)
        midView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.snp_center)
            make.size.equalTo(CGSizeMake(5, 5))
        }
        
        topView = SCNView.init()
        bottomView = SCNView.init()
        leftView = SCNView.init()
        rightView = SCNView.init()
        
        topView?.backgroundColor = UIColor.blackColor()
        bottomView?.backgroundColor = UIColor.blackColor()
        leftView?.backgroundColor = UIColor.blackColor()
        rightView?.backgroundColor = UIColor.blackColor()
        
        self.addSubview(topView!)
        self.addSubview(bottomView!)
        self.addSubview(leftView!)
        self.addSubview(rightView!)

        leftView?.snp_makeConstraints(closure: { (make) -> Void in
            make.left.equalTo(self)
            make.centerY.equalTo(self)
            make.width.equalTo(self.snp_width).multipliedBy(widthMutaply)
            make.height.equalTo((leftView?.snp_width)!)
        })
        
        rightView?.snp_makeConstraints(closure: { (make) -> Void in
            make.size.equalTo(leftView!.snp_size)
            make.centerY.equalTo(self)
            make.right.equalTo(self)
        })
        
        topView?.snp_makeConstraints(closure: { (make) -> Void in
            make.size.equalTo(leftView!.snp_size)
            make.centerX.equalTo(self)
            make.bottom.equalTo(leftView!.snp_top)
        })
        
        bottomView?.snp_makeConstraints(closure: { (make) -> Void in
            make.size.equalTo(leftView!.snp_size)
            make.centerX.equalTo(self)
            make.top.equalTo(leftView!.snp_bottom)
        })
    }
    
    func setUpScenes() {
        scene = SCNScene.init()
        
        topView?.allowsCameraControl = false
        bottomView?.allowsCameraControl = false
        leftView?.allowsCameraControl = false
        rightView?.allowsCameraControl = false
        
        topView?.scene = scene
        bottomView?.scene = scene
        leftView?.scene = scene
        rightView?.scene = scene
    }
    
    func setUpCamera() {
        let fileScene = SCNScene.init(named: filePath!)
        fileNodes = fileScene!.rootNode.childNodes
        for node: SCNNode in fileNodes! {
            scene?.rootNode.addChildNode(node)
            if animation.doAnimating && animation.duration > 0 {
                node.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(0, y: 1, z: 0, duration: animation.duration)))
            } else {
                node.removeAllActions()
            }
        }
        let cameraNodes = cameraInfoString?.convertStringToNodeInfo()?.getBaseNodeAndCameraNode()
        scene?.rootNode.addChildNode(cameraNodes!.base)
        print(cameraNodes!.base.eulerAngles)
        bottomView?.pointOfView = cameraNodes!.bottom
        topView?.pointOfView = cameraNodes!.top
        leftView?.pointOfView = cameraNodes!.left
        rightView?.pointOfView = cameraNodes!.right
        
        let lightNodeArray = lightInfoString?.convertStringToLightNodeInfoArray()
        if lightNodeArray != nil {
            for node: LightNodeInfo in lightNodeArray! {
                scene?.rootNode.addChildNode(node.node())
            }
        }
    }
}
